# Testing

## Gates

Run all of these before committing:

```bash
make format   # crystal tool format --check src spec examples bin
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

## Live browser specs

Parity specs that drive a real browser borrow it from a pool instead of
launching one per example (`spec/support/live_browser_pool.cr`), mirroring
go-rod's `testerPool` (`vendor/rod/setup_test.go:41`):

```crystal
RodSpec.with_live_browser do |browser|   # shared browser, reset between examples
  page = browser.must_page("https://example.com/")
  page.must_wait_load
end

RodSpec.with_isolated_browser do |browser|   # own browser, closed afterwards
  Cdp::Browser::Crash.new.call(browser)
end
```

What the harness does, per borrow:

- hands back the same Chrome instance, blanking the page the next example
  inherits (`navigate("")`) and closing the extra targets it left open;
- disposes browser contexts an example created (an incognito context per
  example would otherwise accumulate);
- drops a browser whose reset fails, so a crashed or disconnected browser cannot
  poison the next example;
- closes every pooled browser and removes their profiles from an `at_exit` hook.

Use `with_isolated_browser` when an example changes browser-wide state (trace,
logging, slow motion), stops the connection, or crashes the browser. Never gate
a ported example behind an env flag: `spec/live_spec_gating_parity_spec.cr`
fails if a spec hides behind `ROD_REAL_BROWSER`. Examples that need Chrome skip
themselves with `RodSpec.chrome_available?` instead, so the suite is green on a
machine without it and still runs the check on a machine that has it.

`ROD_POOL_STATS=1` prints how many browsers the run launched:

```bash
ROD_POOL_STATS=1 crystal spec spec/live_browser_parity_spec.cr
# [rod pool] launches=7
```

## Reproducing browser flakiness

A real-browser spec is only as deterministic as the browser it drives. When one
fails intermittently, reproduce it under load before touching the assertions:

```bash
./scripts/stress_live_specs.sh 5 8   # 5 rounds, 8 concurrent workers
```

The script builds `spec/live_browser_parity_spec.cr` and
`spec/cdp_client_parity_spec.cr` once, then mixes the heavy examples that used to
expose the `Page#reload` stale-context race and the launcher timeout (Phase 9 in
`plans/parity.md`). A flake is only fixed when the harness is clean and the fix
has a red-green spec of its own; a green rerun in isolation proves nothing.

Recent example: un-gating `TestPageIframeReload` exposed a stale document root
(`-32000 No node with given id found`) that `Page#stale_document_root_error?`
did not recognize; the fix has its own spec in
`spec/page_stale_node_retry_parity_spec.cr`.

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
