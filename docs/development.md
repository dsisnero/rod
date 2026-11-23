# Development

## Upstream source of truth

This repository is a Crystal port of
[go-rod/rod](https://github.com/go-rod/rod). The Go source is vendored at
`vendor/rod` and pinned at commit `d38c753` (upstream has no release tags).

Rules that follow from that:

- Treat `vendor/rod` as the source of truth; when in doubt, read the Go code.
- Logic must match Go exactly; only syntax and library choices differ.
- Use Crystal idioms only after behavioral equivalence is verified.
- Port tests alongside code: every Go test should have a Crystal spec.
- `must_*` and `!` aliases map one-to-one (`page!` → `must_page`,
  `element!` → `must_element`).

For parity tracking and validation, use the curated plan in `plans/parity.md`
and the manifests under `plans/inventory/` with the helper scripts in
`scripts/`.

## Project structure

- `src/rod/` — Crystal implementation (browser, page, element, states, input)
- `src/rod/util/` — launcher, CDP transport, utilities
- `src/cdp/` — generated Chrome DevTools Protocol bindings
- `src/pdlgen/` — Crystal code generator for `src/cdp` (see
  [generation.md](generation.md))
- `spec/` — Crystal specs, including parity specs mapped from upstream Go tests
- `spec/support/` — spec harness code (the pooled live browser; see
  [testing.md](testing.md))
- `vendor/rod/` — upstream Go source (reference only)
- `plans/` — parity plan and generated/curated inventories
- `scripts/` — inventory generation and parity check tooling
- `examples/` — runnable examples, including end-to-end browser checks
- `temp/` — git-ignored scratch space (`make clean` empties it)

## Local workflow

```bash
make install     # shards install
make update      # shards update
make format      # crystal tool format --check src spec examples bin
make lint        # ameba --fix, then ameba
make test        # crystal spec
make check-examples  # compile every example with `crystal build --no-codegen`
make examples        # build example binaries into temp/examples, incrementally
make clean       # rm -rf ./temp/*
```

`make test` does not load `examples/`, and `make format` only parses them, so
`make check-examples` is the gate that keeps them compiling: seven examples still
used the pre-port `Rod::Lib` namespace and had silently stopped compiling. Each
example under `examples/` mirrors a file in `vendor/rod/lib/examples`, so port
them together with their upstream counterpart. Example call sites use the `!`
aliases of the `must_*` helpers (`connect!`, `page!`, `element!`, `click!`,
`Rod::Util::Launcher.new_managed!`, `pool.get! { … }`), so they read shorter
than the Go source while calling the same ported helpers.

`make examples` builds one binary per entry point (`*/main.cr` plus
`e2e-testing/calculator.cr`) under the git-ignored `temp/examples/`, and only
rebuilds a binary when that example's own `.cr` files or any `src/**/*.cr` file
is newer. After a `src/rod` change every example rebuilds; after an example
change only that one does, including `e2e-testing/calculator.cr` when its shared
`setup.cr` helper changes; a repeat run does nothing. The shard manifest and
`lib/` are not prerequisites, so `shards install`/`update` does not force a
rebuild — `make clean` first when a dependency change needs fresh binaries.
Build just one with `make example EXAMPLE=compare-chromedp/click`, and run it
from `temp/examples/compare-chromedp/click/main`. A first full build takes a few
minutes; `make check-examples` is the fast, timestamp-independent typecheck.

Parity gates (tree-sitter discovery through the installed
`cross-language-crystal-parity` skill; `scripts/*.sh` are forwarding wrappers):

```bash
make check-go-port-inventory
make check-go-source-parity
make check-go-test-parity
```

`make` pins `PORT_PARSER=tree-sitter`; the first run resolves the skill's
verified Chiasmus toolchain into `~/.cache/chiasmus/toolchains` (override the
skill location with `PARITY_SKILL_DIR` if it moves). The source/test parity
files are disposable discovery snapshots: the canonical generators write
baseline rows (`status=missing`, refs `-`) and overwrite in place, which is why
the Makefile passes `PORT_FORCE_OVERWRITE=1`:

```bash
make generate-go-source-parity
make generate-go-test-parity
```

Never regenerate `go_port_inventory.tsv` in place: it is the hand-curated
ledger. `make generate-go-port-inventory` writes a candidate to
`temp/go_port_inventory.candidate.tsv`; a re-base matches identity (file + name)
and carries `status`/`crystal_refs`/`notes` over by hand.

Live browser checks need a local Chrome/Chromium binary. The suite borrows one
pooled Chrome (`spec/support/live_browser_pool.cr`), so a full `make test` run
launches a handful of processes instead of one per example and removes their
profiles on exit. Set `ROD_CHROME_BIN` to point at a non-default Chrome, and
`ROD_POOL_STATS=1` to print the launch count:

```bash
ROD_POOL_STATS=1 make test
CRYSTAL_CACHE_DIR=$PWD/.crystal-cache crystal run \
  examples/compare-chromedp/download_file/main.cr -- \
  -rod "bin=/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
```

## Work tracking

There is no external issue tracker. `plans/parity.md` is the work queue: its
**Where we are** block names the current focus and the ordered "Next up" list,
and per-symbol status lives in `plans/inventory/go_port_inventory.tsv`. See
[resuming.md](resuming.md) for the full resume checklist and `AGENTS.md` for
the definition of done.

## CDP bindings

`src/cdp` is generated from the protocol definitions, not hand-written.
Run `make generate` (Crystal `pdlgen`) after bumping the vendor tree, and keep
the CDP parity specs green. Details: [generation.md](generation.md).
