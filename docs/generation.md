# Protocol Generation in rod

This document explains how Chrome DevTools Protocol (CDP) code generation works
in the rod project.

## Overview

There are three different generation systems involved:

1. **Go rod's built-in generator** (`vendor/rod/lib/proto/generate`) - Fetches
   protocol from a running Chrome instance
2. **cdproto-gen (Go pdlgen)** (`vendor/pdlgen`) - Fetches `.pdl` files from
   Chromium source tree
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
3. Parses the JSON schema and generates Go structs in
   `vendor/rod/lib/proto/*.go`
4. Applies patches and fixups for compatibility

### Key Characteristics

- Fetches protocol from **actual Chrome instance**, ensuring compatibility with
  the Chrome version being used
- Generates Go code optimized for rod's internal use
- Does not use `.pdl` files (uses JSON protocol description)
- Used by the original Go rod project

## cdproto-gen (Go pdlgen)

### Location

`vendor/pdlgen/` (git submodule from <https://github.com/chromedp/cdproto-gen>)

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

The `Makefile` wires the two generators together:

```makefile
CDP_CHROMIUM ?=   # empty = upstream latest
CDP_V8 ?=         # empty = derive from Chromium DEPS (pinned Chromium only)
CDP_PROTOCOL_ARGS = $(if $(CDP_CHROMIUM),--chromium=$(CDP_CHROMIUM),--latest) $(if $(CDP_V8),--v8=$(CDP_V8),)

build-pdlgen-crystal:
	crystal build src/pdlgen.cr -o bin/pdlgen-crystal

build-pdlgen-go:
	cd vendor/pdlgen && go build -o ../../bin/pdlgen-go .

generate-crystal: build-pdlgen-crystal
	./bin/pdlgen-crystal $(strip $(CDP_PROTOCOL_ARGS)) --out src/cdp

generate-crystal-scratch: build-pdlgen-crystal
	rm -rf temp/cdp_generated
	mkdir -p temp/cdp_generated
	./bin/pdlgen-crystal $(strip $(CDP_PROTOCOL_ARGS)) --out temp/cdp_generated

generate-go-ref: build-pdlgen-go
	mkdir -p temp/cdp_go
	./bin/pdlgen-go -out temp/cdp_go --latest

generate: generate-crystal
```

So `make generate` writes Crystal code into `src/cdp/`, and
`make generate-go-ref` writes Go reference output into `temp/cdp_go/`. The
legacy `generate-legacy` target is deprecated: it runs the Go generator against
`src/cdp`.

## Reproducing a generation

`--latest` resolves the newest Chromium tag at run time, so the same command
produces different output on different days. Pin the vintage instead:

```bash
# Chromium only: pdlgen reads Chromium's DEPS file to derive the V8 version.
make generate-crystal CDP_CHROMIUM=160.0.8168.1

# Both explicitly (no DEPS lookup).
make generate-crystal CDP_CHROMIUM=160.0.8168.1 CDP_V8=16.0.61
```

`make generate-crystal-scratch` runs the same generation into
`temp/cdp_generated/` so the toolchain can be exercised without touching
`src/cdp/`.

`make check-generate-crystal` proves the committed tree still matches that
generation: it regenerates the pinned vintage into `temp/cdp_generated/`, formats
it the way `make generate-crystal` formats `src/cdp`, and diffs the two trees
(ignoring the AppleDouble sidecars an exFAT checkout emits). A planted hand edit
in a generated file fails the gate with the offending paths. The first run needs
network access — the PDL files are fetched from googlesource.com and cached under
`temp/cdproto-gen`.

## `src/cdp` is generated end to end

The committed tree is generated at Chromium `160.0.8168.1` / V8 `16.0.61`: 59
domain directories (306 `.cr` files). The generator owns the whole tree,
including the root module: `src/pdlgen/gen/crystal_templates/root.ecr` emits
`src/cdp/cdp.cr` (`Cdp.call`, the `Client` interface, `TIME_FIELD_KEYS` and the
timestamp normalization applied on the wire) and `src/cdp/cdp/types.cr` (the
shared `NodeType` alias). Nothing is preserved across a regeneration, and
`spec/pdlgen_root_template_parity_spec.cr` pins the rendered root against the
committed file.

Curation that used to be applied by hand after a generation is now emitted by
the generator itself, so a regeneration is byte-for-byte reproducible
(`make generate-crystal CDP_CHROMIUM=160.0.8168.1 CDP_V8=16.0.61` twice leaves an
identical tree):

- JSON `camelCase` keys on every field (`bd31de8`) and typed result decoding
  through `Cdp.call` (`cc3717f`).
- Lifted inline-enum types are named once and without a domain qualifier (no
  `alias Fetch.AuthChallengeSource`).
- Value types get a constructor with required parameters first; `JSON::Serializable`
  alone does not provide one.
- CDP enums serialize as their integer value and `@[Flags]` enums also *decode*
  from an integer; Crystal's defaults emit/expect member names.
- go-rod's struct-only fields (channels, mutexes, state flags added by the
  `Fixup` step, e.g. `DOM.Node#invalidated`) are `@[JSON::Field(ignore: true)]`
  with an initializer default instead of being decoded from the wire.
- Types that reference themselves (directly or through another type) are emitted
  as `class`, not `struct`: a Crystal struct has no finite size when it contains
  itself, while go-rod models those fields as pointers. `Runtime.StackTrace`,
  `DOM.Node`, `Page.FrameTree` and friends are covered by
  `spec/pdlgen_emitter_parity_spec.cr`.
- go-rod's hand-written extras are emitted verbatim: `DOM` quad geometry
  (`center`/`area`/`each_point`, `GetContentQuadsResult#box`/`#one_point_inside`),
  `DOM.Point`, `Input.TouchPoint#move_to`, `Network` timestamp/cookie helpers and
  `Network.Request#post_data` (decoded from `postDataEntries`, since Chrome
  removed the plain `postData` field).
- Wire-name drift between vintages is real, not a generator bug: e.g.
  `Network.Response.remoteIpAddress` became `remoteIPAddress`, and
  `Input.Modifier` became a `$ref` bitmask instead of a plain integer.

The protocol itself changed shape for the pinned vintage: it adds `ads`,
`crashreportcontext`, `digitalcredentials`, `findinpage` and `webmcp`, and drops
`console`, `database` and `schema`. Those three domains are gone from Chromium
(go-rod's own generator drops them when run against a current browser), so they
are recorded as `skipped` in the inventory and
`spec/cdp_legacy_proto_parity_spec.cr` was removed with them.

Adopting a newer protocol is its own work item: pick the vintage, bump
`CDP_CHROMIUM`/`CDP_V8`, run `make generate-crystal`, then `make format` and
`crystal spec` (the CDP parity specs under `spec/cdp_*_parity_spec.cr` plus
`spec/cdp_protocol_vintage_parity_spec.cr`) before committing.

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

For a toolchain smoke check that leaves the repository untouched:

```bash
make generate-crystal-scratch              # writes temp/cdp_generated/
crystal tool format temp/cdp_generated     # parses every generated file
crystal spec                               # committed src/cdp still green
```

`crystal tool format` fails loudly on syntax errors, so a clean run over the
scratch tree proves the emitter still produces parseable Crystal for the
selected protocol vintage.

## Maintenance

When updating protocol definitions:

1. Update cached `.pdl` files from Chromium source (pin `CDP_CHROMIUM`)
2. Run both generators
3. Compare outputs for any discrepancies
4. Update fixups if needed for Crystal-specific issues
5. Run Crystal tests to ensure compatibility

## See Also

- [Chromium Protocol Documentation](https://chromedevtools.github.io/devtools-protocol/)
- [cdproto-gen (Go pdlgen)](https://github.com/chromedp/cdproto-gen)
- [rod protocol generator sources](https://github.com/go-rod/rod/tree/main/lib/proto/generate)
  (vendored at `vendor/rod/lib/proto/generate/`)
