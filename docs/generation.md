# Protocol Generation in rod

This document explains how Chrome DevTools Protocol (CDP) code generation works in the rod project.

## Overview

There are three different generation systems involved:

1. **Go rod's built-in generator** (`vendor/rod/lib/proto/generate`) - Fetches protocol from a running Chrome instance
2. **cdproto-gen (Go pdlgen)** (`vendor/pdlgen`) - Fetches `.pdl` files from Chromium source tree
3. **Crystal pdlgen** (`src/pdlgen`) - Crystal port of cdproto-gen

## Go rod's Built-in Generator

### Location
`vendor/rod/lib/proto/generate/`

### Usage
Triggered by `go:generate` directive in `vendor/rod/browser.go`:
```go
//go:generate go run ./lib/proto/generate
```

### How it Works
1. Launches a Chrome/Chromium browser using rod's launcher
2. Fetches protocol JSON from `http://<debugger-url>/json/protocol`
3. Parses the JSON schema and generates Go structs in `vendor/rod/lib/proto/*.go`
4. Applies patches and fixups for compatibility

### Key Characteristics
- Fetches protocol from **actual Chrome instance**, ensuring compatibility with the Chrome version being used
- Generates Go code optimized for rod's internal use
- Does not use `.pdl` files (uses JSON protocol description)
- Used by the original Go rod project

## cdproto-gen (Go pdlgen)

### Location
`vendor/pdlgen/` (git submodule from https://github.com/chromedp/cdproto-gen)

### Usage
Can be run manually:
```bash
cd vendor/pdlgen && go build -o ../../bin/pdlgen .
./bin/pdlgen -out src/cdp vendor/rod/lib/proto/browser_protocol.json vendor/rod/lib/proto/js_protocol.json
```

### How it Works
1. Fetches `.pdl` files from Chromium source tree:
   - `browser_protocol.pdl` from Chromium repository
   - `js_protocol.pdl` from V8 repository
2. Parses PDL (Protocol Description Language) format
3. Generates Go packages in a structured hierarchy
4. Applies fixups and cleanups
5. Runs `goimports`, `easyjson`, and `gofmt` on generated code

### Key Characteristics
- Fetches protocol from **Chromium source code**, not from running browser
- Generates comprehensive Go packages for all CDP domains
- Used by `chromedp` project and other Go CDP clients
- Outputs idiomatic Go code with proper JSON marshaling

## Crystal pdlgen

### Location
`src/pdlgen/`

### Usage
```bash
crystal run src/pdlgen.cr -- --pdl <file.pdl> --out src/cdp
```

### How it Works
1. Port of cdproto-gen from Go to Crystal
2. Same PDL parsing logic and fixups as Go version
3. Generates Crystal modules and structs instead of Go packages
4. Outputs Crystal code with `JSON::Serializable` support

### Key Characteristics
- **Logic matches Go cdproto-gen exactly** (per porting guidelines)
- Generates Crystal code for the Crystal port of rod
- Uses Crystal idioms (modules, structs, `JSON::Serializable`)
- Same domain structure and organization as Go version

## Current Setup in This Repository

### Makefile Rules
The current `Makefile` has:
```makefile
generate:
	cd vendor/pdlgen && go build -o ../../bin/pdlgen ./cmd/pdlgen
	./bin/pdlgen -out src/cdp vendor/rod/lib/proto/browser_protocol.json vendor/rod/lib/proto/js_protocol.json
```

**Issue**: This uses Go pdlgen to generate Go code into `src/cdp`, but `src/cdp` should contain Crystal code.

### Desired Setup

1. **Go pdlgen** → Generate Go code in `temp/cdp_go/` for reference
2. **Crystal pdlgen** → Generate Crystal code in `src/cdp/` for actual use
3. **Reference generation** → Use Go output to verify Crystal port correctness

### Updated Makefile Plan
```makefile
generate-go-ref:  # Generate Go code for reference
	cd vendor/pdlgen && go build -o ../../bin/pdlgen .
	./bin/pdlgen -out temp/cdp_go --pdl temp/protocol.pdl

generate-crystal:  # Generate Crystal code for use
	crystal run src/pdlgen.cr -- --out src/cdp --pdl temp/protocol.pdl

generate: generate-go-ref generate-crystal
```

## Protocol Source Files

### Where to Get Protocol Definitions

1. **From running Chrome**: `http://<debugger-url>/json/protocol`
2. **From Chromium source**:
   - `https://chromium.googlesource.com/chromium/src/+/master/third_party/blink/renderer/core/inspector/browser_protocol.pdl`
   - `https://chromium.googlesource.com/v8/v8/+/master/src/inspector/js_protocol.pdl`
3. **Local cached files**: In `temp/` directory after first fetch

### File Formats
- **.pdl**: Protocol Description Language (text-based, human-readable)
- **.json**: JSON representation (used by Chrome DevTools)

## Verification

To verify Crystal pdlgen works correctly:

1. Generate Go code with Go pdlgen
2. Generate Crystal code with Crystal pdlgen
3. Compare structure, domain names, type definitions
4. Ensure Crystal code compiles and passes tests

## Maintenance

When updating protocol definitions:

1. Update cached `.pdl` files from Chromium source
2. Run both generators
3. Compare outputs for any discrepancies
4. Update fixups if needed for Crystal-specific issues
5. Run Crystal tests to ensure compatibility

## See Also

- [Chromium Protocol Documentation](https://chromedevtools.github.io/devtools-protocol/)
- [cdproto-gen README](vendor/pdlgen/README.md)
- [rod Proto Generation](vendor/rod/lib/proto/generate/)