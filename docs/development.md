# Development

Common local workflow:

```bash
crystal tool format --check
ameba --fix
ameba
crystal spec
```

Useful live checks while porting/parity testing:

```bash
CRYSTAL_CACHE_DIR=$PWD/.crystal-cache crystal run examples/compare-chromedp/download_file/main.cr -- -rod "bin=/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
```

Behavior parity rules:

- Treat `vendor/rod` as source of truth.
- Keep Crystal API semantics aligned with Go Rod.
- `must_*` and `!` aliases should map one-to-one (`page!` -> `must_page`).

For parity tracking and validation, use manifests in `plans/inventory/` and helper scripts in `scripts/`.
