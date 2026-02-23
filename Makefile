.PHONY: install update format lint test clean generate generate-crystal generate-go-ref build-pdlgen-crystal build-pdlgen-go

install:
	shards install

update:
	shards update

format:
	crystal tool format --check

lint:
	ameba --fix
	ameba

test:
	crystal spec

clean:
	rm -rf ./temp/*

# Build Crystal pdlgen binary
build-pdlgen-crystal:
	crystal build src/pdlgen.cr -o bin/pdlgen-crystal

# Build Go pdlgen binary (for reference generation)
build-pdlgen-go:
	cd vendor/pdlgen && go build -o ../../bin/pdlgen-go .

# Generate Crystal CDP code using Crystal pdlgen
generate-crystal: build-pdlgen-crystal
	./bin/pdlgen-crystal --latest --out src/cdp

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