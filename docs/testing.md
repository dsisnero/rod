# Testing

## Gates

Run all of these before committing:

```bash
make format   # crystal tool format --check
make lint     # ameba --fix, then ameba
make test     # crystal spec
```

## Targeted specs

```bash
crystal spec spec/must_bang_alias_spec.cr
crystal spec spec/browser_wait_download_parity_spec.cr
crystal spec spec/page_query_api_parity_spec.cr
crystal spec spec/page_settings_parity_spec.cr
crystal spec spec/page_event_lifecycle_parity_spec.cr
```

Some parity specs start a real browser and need a local Chrome/Chromium binary.

## Parity manifests

```bash
make check-go-port-inventory
make check-go-source-parity
make check-go-test-parity
```

The same checks can be run directly:

```bash
./scripts/check_go_port_inventory.sh . plans/inventory/go_port_inventory.tsv vendor/rod
./scripts/check_go_source_parity.sh . plans/inventory/go_source_parity.tsv vendor/rod
./scripts/check_go_test_parity.sh . plans/inventory/go_test_parity.tsv vendor/rod
```

## Porting Go tests to Crystal specs

1. **Port the logic exactly** — do not adjust assertions or expected values.
2. **Use Crystal idioms for structure** — turn Go test tables into `it` blocks;
   keep the same cases and edge conditions.
3. **Mark unavailable functionality `pending`** — never delete a case because
   the Crystal side is not implemented yet.
4. **Follow the Go test's intent** — same coverage, same failure modes.
5. **Verify against the Go implementation** — when output differs (for example
   compressed bytes), still assert the upstream property (size, shape,
   invariants) rather than weakening the check.

Red → green is expected: write or port the failing spec first, then make it
pass without relaxing the assertion.
