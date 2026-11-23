.PHONY: install update format lint test check-examples examples example clean generate generate-crystal generate-crystal-scratch generate-go-ref build-pdlgen-crystal build-pdlgen-go \
	check-generate-crystal check-go-port-inventory check-go-source-parity check-go-test-parity \
	generate-go-port-inventory generate-go-source-parity generate-go-test-parity

GO_PORT_SOURCE_DIR ?= vendor/rod

# Pin the Crystal compiler cache to this workspace. Crystal writes one
# `crystal-run-<program>.tmp` per program name into the cache directory, so with
# the shared default (`~/.cache/crystal`) a concurrent `crystal spec` from a
# different checkout overwrites `crystal-run-spec.tmp` and the next run here
# executes that checkout's example list (seen once as `../dataframe/spec/...`
# inside this repo's run). `.crystal-cache/` is git-ignored.
export CRYSTAL_CACHE_DIR := $(CURDIR)/.crystal-cache

# CDP protocol vintage for `make generate-crystal`. Empty means "upstream
# latest" (`--latest`), which is not reproducible; set the versions to pin a
# generation, e.g. `make generate-crystal CDP_CHROMIUM=160.0.8168.1`.
CDP_CHROMIUM ?=
CDP_V8 ?=
CDP_PROTOCOL_ARGS = $(if $(CDP_CHROMIUM),--chromium=$(CDP_CHROMIUM),--latest) $(if $(CDP_V8),--v8=$(CDP_V8),)


install:
	shards install

update:
	shards update

# Formatter gate runs on explicit roots: generated scratch trees live under
# temp/ (see docs/generation.md), which `crystal tool format` would otherwise
# descend into and fail on.
format:
	crystal tool format --check src spec examples bin

lint:
	ameba --fix
	ameba

test:
	crystal spec spec

# Gate: every example must at least compile. Examples are not part of
# `make test`, so without this they rot silently (7 of them referenced the
# pre-port `Rod::Lib` namespace and had not compiled for a long time).
check-examples:
	@status=0; for f in $$(find examples -name '*.cr' ! -name '._*' ! -name '.DS_Store' | sort); do \
		crystal build --no-codegen "$$f" >/dev/null || { echo "FAIL $$f"; status=1; }; \
	done; \
	if [ $$status -eq 0 ]; then echo "All examples compile."; else exit 1; fi

# Incremental example binaries under temp/examples/, one per entry point. A
# binary is rebuilt only when the example's own `.cr` files or any `src/**/*.cr`
# file is newer than it: `make examples` after a `src/rod` edit rebuilds
# everything, after an example edit rebuilds just that one, and a repeat run does
# nothing. The shard manifest and `lib/` are deliberately not prerequisites, so
# `shards install`/`update` does not force a full rebuild; run `make clean` first
# if a dependency change needs fresh binaries.
#
#   make examples                                  # build/refresh all binaries
#   make example EXAMPLE=compare-chromedp/click    # build just one
#   make check-examples                            # fast typecheck, no binaries
#
# Binaries land in temp/examples/ (git-ignored) and `make clean` removes them.
# Builds are real (no `--no-codegen`): a typecheck-only pass emits no file, so it
# could never be tracked by timestamp. This checkout is on exFAT, whose
# timestamps have 2-second granularity, so an edit made within the same 2-second
# window as a build may not be noticed; `make check-examples` is the
# timestamp-independent gate. The `find` calls skip `._*`/`.DS_Store` because the
# exFAT checkout surfaces AppleDouble sidecars in `readdir`.
#
# An entry point's own sources are every `.cr` file in its directory, so a shared
# helper such as `examples/e2e-testing/setup.cr` rebuilds the example requiring
# it (`calculator.cr`), not every example.
EXAMPLE_ENTRY ?= $(shell find examples -name 'main.cr' ! -name '._*' | sort) examples/e2e-testing/calculator.cr
EXAMPLE_SRC_DEPENDS ?= $(shell find src -name '*.cr' ! -name '._*' | sort)
EXAMPLE_BUILD_FLAGS ?=
example_bin = temp/examples/$(patsubst examples/%.cr,%,$(1))
example_sources = $(shell find $(dir $(1)) -name '*.cr' ! -name '._*' | sort)

# A failed build must not leave a binary that make then treats as up to date.
.DELETE_ON_ERROR:

.PHONY: examples example
examples: $(foreach e,$(EXAMPLE_ENTRY),$(call example_bin,$(e)))

# `EXAMPLE` is a path under examples/: either the directory of a `main.cr` or a
# `.cr` entry point like `e2e-testing/calculator`.
example:
	@test -n "$(EXAMPLE)" || { echo "usage: make example EXAMPLE=<path under examples/, e.g. compare-chromedp/click>" >&2; exit 2; }
	@src="$(or $(firstword $(wildcard examples/$(EXAMPLE)/main.cr)),examples/$(EXAMPLE).cr)"; \
	 if [ ! -f "$$src" ]; then echo "no such example: $(EXAMPLE)" >&2; exit 2; fi; \
	 bin="temp/examples/$${src#examples/}"; bin="$${bin%.cr}"; \
	 $(MAKE) --no-print-directory "$$bin"

define EXAMPLE_RULE
$(call example_bin,$(1)): $(call example_sources,$(1)) $(EXAMPLE_SRC_DEPENDS)
	@mkdir -p $$(dir $$@)
	crystal build $(EXAMPLE_BUILD_FLAGS) $(1) -o $$@
endef
$(foreach e,$(EXAMPLE_ENTRY),$(eval $(call EXAMPLE_RULE,$(e))))

# Gate: the committed src/cdp must still be exactly what the pinned protocol
# generates (Chromium CDP_CHROMIUM / V8 CDP_V8).
check-generate-crystal:
	./scripts/check_generate_crystal.sh .

check-go-port-inventory:
	./scripts/check_go_port_inventory.sh . plans/inventory/go_port_inventory.tsv $(GO_PORT_SOURCE_DIR)

check-go-source-parity:
	./scripts/check_go_source_parity.sh . plans/inventory/go_source_parity.tsv $(GO_PORT_SOURCE_DIR)

check-go-test-parity:
	./scripts/check_go_test_parity.sh . plans/inventory/go_test_parity.tsv $(GO_PORT_SOURCE_DIR)

generate-go-port-inventory:
	./scripts/generate_go_port_inventory.sh . plans/inventory/go_port_inventory.tsv $(GO_PORT_SOURCE_DIR)

generate-go-source-parity:
	./scripts/generate_go_source_parity_manifest.sh . plans/inventory/go_source_parity.tsv $(GO_PORT_SOURCE_DIR)

generate-go-test-parity:
	./scripts/generate_go_test_parity_manifest.sh . plans/inventory/go_test_parity.tsv $(GO_PORT_SOURCE_DIR)

clean:
	rm -rf ./temp/*
	mkdir -p ./temp

# Build Crystal pdlgen binary
build-pdlgen-crystal:
	crystal build src/pdlgen.cr -o bin/pdlgen-crystal

# Build Go pdlgen binary (for reference generation)
build-pdlgen-go:
	cd vendor/pdlgen && go build -o ../../bin/pdlgen-go .

# Generate Crystal CDP code using Crystal pdlgen.
#
# The generator owns the whole tree, including the root module
# (src/pdlgen/gen/crystal_templates/root.ecr emits `Cdp.call`, the client
# interface, the timestamp normalization and the shared types). A regeneration
# of the pinned vintage is therefore a no-op; `spec/pdlgen_root_template_parity_spec.cr`
# pins the root output. Drop the AppleDouble sidecars an exFAT checkout produces
# and remove directories left empty by domains the pinned vintage no longer
# defines.
generate-crystal: build-pdlgen-crystal
	./bin/pdlgen-crystal $(strip $(CDP_PROTOCOL_ARGS)) --out src/cdp
	-find src/cdp -name '._*' -delete
	-find src/cdp -mindepth 1 -type d -empty -delete
	crystal tool format src/cdp

# Generate into scratch space instead of src/cdp: the non-destructive toolchain
# check (see docs/generation.md).
generate-crystal-scratch: build-pdlgen-crystal
	rm -rf temp/cdp_generated
	mkdir -p temp/cdp_generated
	./bin/pdlgen-crystal $(strip $(CDP_PROTOCOL_ARGS)) --out temp/cdp_generated

# Generate Go CDP code using Go pdlgen (for reference only)
generate-go-ref: build-pdlgen-go
	mkdir -p temp/cdp_go
	./bin/pdlgen-go -out temp/cdp_go --latest

# Default generate target: generate Crystal code
generate: generate-crystal

# Legacy generate using Go pdlgen (deprecated - generates Go code, not Crystal)
generate-legacy:
	cd vendor/pdlgen && go build -o ../../bin/pdlgen ./cmd/pdlgen
	./bin/pdlgen -out src/cdp vendor/rod/lib/proto/browser_protocol.json vendor/rod/lib/proto/js_protocol.json
