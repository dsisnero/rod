.PHONY: install update format lint test clean generate

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

generate:
	cd vendor/pdlgen && go build -o ../../bin/pdlgen ./cmd/pdlgen
	./bin/pdlgen -out src/cdp vendor/rod/lib/proto/browser_protocol.json vendor/rod/lib/proto/js_protocol.json