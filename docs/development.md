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
make clean       # rm -rf ./temp/*
```

Parity gates:

```bash
make check-go-port-inventory
make check-go-source-parity
make check-go-test-parity
```

Live browser checks need a local Chrome/Chromium binary:

```bash
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
