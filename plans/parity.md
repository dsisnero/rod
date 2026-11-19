# Go → Crystal Parity Plan

**Source of truth**: `vendor/rod` (go-rod) at `d38c753`
**Target**: Crystal port under `src/`, specs under `spec/`
**Language**: `go` · **Manifests**: `plans/inventory/go_*`
**Last evaluated**: 2026-11-17

## Where we are

**Current focus:** Phase 24 closed the last crash of the "closed channel" class:
the event hub's `Pipe#write` selected on the subscriber's `done` channel with a
bare `receive`, so a publish racing a shutdown raised `Channel::ClosedError` into
`Browser#init_events` and stopped event delivery. It now uses `receive?`, like
`IdleCounter#wait` (Phase 23) and the rest of the port. The next open work is the
Phase 1 tooling migration plus the optional cleanups listed below.

**Last commit:** `port: keep the event hub alive when a done channel closes`

**Gates (2026-11-19, after Phase 24):** `make format` pass · `make lint` pass
(240 files) · `make test` pass (627 examples, 0 failures) · parity checks pass
(5665 inventory rows with 10 documented divergences and 54 `skipped` legacy
protocol rows, 5368 API items, 297 tests) · upstream Go suite: 8/9 packages pass,
`go-rod/rod` main package has browser-timing failures (see Next up).

**Next up:**

1. Phase 1 tooling migration: wrap the installed skill's canonical parity
   scripts instead of the repo's copied ones (whose `tree-sitter` branch is a
   placeholder), and decide curated-status preservation. Native tree-sitter
   discovery already works via the verified Chiasmus toolchain, but its
   vocabulary (`class`/`function`/`definition.*` plus merged `const`/`type`
   declarations) cannot be mapped onto the curated ids by a kind rename, so the
   gate stays `PORT_PARSER=regex` until a reviewed id migration lands. It also
   closes the `states.go::method::Page.cleanupStates` ledger row (the only
   Phase 2 bullet still open).
2. Upstream Go suite flakiness: `github.com/go-rod/rod` failed
   `TestPageElements` and `Example_basic` on 2026-11-17 while the other eight
   packages passed. Re-run before reading anything into a failure — these are
   browser-timing issues in the vendored project, not port gaps.
3. Re-run the end-to-end generation no-op check when the Chromium PDL fetch
   works again: `make generate-crystal CDP_CHROMIUM=160.0.8168.1
   CDP_V8=16.0.61` must leave a clean `git diff`. The `temp/cdproto-gen` cache
   was rebuilt on demand and the fetch failed with `504`s / connection resets at
   the end of Phase 11, so only the root file's byte-equality was re-verified
   (via `spec/pdlgen_root_template_parity_spec.cr`) after the last template
   tweak.
4. Optional cleanup: the repo tracks built binaries (`rod`, `bin/pdlgen*`,
   `pdlgen*`), so local builds keep showing up as modified files. Decide whether
   to untrack them.
5. Optional cleanup: `Launcher::Manager#logger` is still an unused `::Log`
   property. go-rod's `Manager.Logger` defaults to `utils.LoggerQuiet`
   (`manager.go:141`) and only ever prints `Launch`/`Close`/`Killed PID`/
   `Removed`, so either port those four lines behind the quiet default or drop
   the dead property.
6. Optional follow-up: `spec/cdp_client_parity_spec.cr` and
   `spec/launcher_parity_spec.cr` still launch their own browsers. That is
   deliberate — they exercise the CDP client and the launcher itself
   (`TestLaunchClient`, `Browser.close` handling) — so only revisit it if a
   future spec needs a pooled page on top of its own client.

**Gotchas:** the 63 tree-sitter "missing" items and the 3422 kind-rename
"stale" rows are tooling vocabulary drift, not port gaps — see Phase 1 and the
"Parity tooling" section of `AGENTS.md`. Phase 2's last checklist bullet
(`states.go::method::Page.cleanupStates` ledger row) is also waiting on that
reconciliation. `make generate-crystal` is not reproducible by default
(`--latest`); pin `CDP_CHROMIUM`/`CDP_V8` (Phase 8 records the working pair).
Chrome dropped the `console`, `database` and `schema` domains, so those
inventory rows are `skipped` and `spec/cdp_legacy_proto_parity_spec.cr` is gone.
The upstream Go suite panics in its leak detector unless
`GODEBUG=tracebackancestors=1000` is exported. The checkout is on exFAT, so a
generation emits `._*` AppleDouble sidecars — strip them before counting files.
`Launcher#launch` has no timeout on purpose: a browser that never prints a
DevTools URL now waits until the process exits or the context cancels, exactly
like go-rod, so a wedged browser hangs instead of failing fast. Do not run
`scripts/stress_live_specs.sh` (or any parallel browser work) at the same time as
`make test`: the extra load pushes the suite from ~2:00 to 5-8 minutes and makes
Chrome itself drop connections mid-example, which looks like a port bug. On
2026-11-17 three `chiasmus` runs from another checkout kept the load average
above 12 for hours; a full suite then took 12 minutes and
`TestScrollScreenshot` exhausted its compositor retries even though it passes in
isolation. Re-run before blaming a change. Keep
browser profiles out of `./temp`: on the exFAT checkout Chrome's AppleDouble
`._*` sidecars appear in `readdir` but `FileUtils.rm_rf` cannot unlink them, so
`Launcher#cleanup` silently leaves the profile behind (use `Dir.tempdir`).

This is a curated feature roadmap, not a generated dump. Generated manifests
(`go_source_parity.tsv`, `go_test_parity.tsv`) are reference snapshots;
`go_port_inventory.tsv` is the day-to-day ledger.

---

## Baseline

| Metric | Value |
|---|---|
| Port inventory rows | 5665 discovered + 10 documented divergences (5,601 `ported` + 54 `skipped` + 10 `intentional_divergence`) |
| Source parity (regex backend) | 5368 API items, check PASS (authoritative) |
| Source parity (tree-sitter backend) | incompatible with curated manifests: 63 missing + 3422 stale (kind vocab mismatch) |
| Test parity | 297 tests tracked, check PASS |
| Crystal specs | 86 files, 619 examples, 0 failures (2026-11-18, Chromium `160.0.8168.1`) |

The port is at **functional parity** for all exported Go APIs and all Go tests.

The tree-sitter backend (new in the parity skill) discovers Go **unexported**
methods, but it also uses a **different kind vocabulary** than the regex backend
that generated the curated manifests:

| regex kind (manifests) | tree-sitter kind | example id change |
|---|---|---|
| `func` | `function` | `browser.go::func::New` → `browser.go::function::New` |
| `struct` | `class` | `browser.go::struct::Browser` → `browser.go::class::Browser` |
| `const` / `type` | `definition.type`, `field` | `...::const::X` → `...::definition.type::X` |
| `method` | `method` | matches (only unexported extras differ) |

Consequence with `PORT_PARSER=tree-sitter` on the current curated manifests:
**63 "missing"** (unexported methods the regex backend never emitted) **plus
3422 "stale"** (every regex `func`/`struct`/`const`/`type` row, which
tree-sitter renames). The checker exits on "missing" first, so the 63 masked the
larger mismatch. The regex backend therefore remains **authoritative** for the
curated manifests until the tooling normalizes kinds.

---

## Evaluation of the 63 tree-sitter findings

The 63 items are the tree-sitter `missing` set (the check exits before it would
report the 3422 `stale` kind-rename rows above). All 63 are unexported
implementation details, code-generation tooling, or platform shims. **62 map to
an existing Crystal equivalent** (renamed, restructured, or inlined); **1 is a
genuine minor gap**. Full list:
`plans/inventory/go_tree_sitter_drift_notes.txt`.

| Category | Count | Verdict |
|---|---|---|
| Browser / page / element unexported helpers | 8 | False positive — snake_case equivalents |
| `page_eval.go` internals | 9 | False positive — `page.cr` equivalents |
| `dev_helpers.go` tracers | 7 | False positive — `dev_helpers.cr` equivalents |
| `input.go` keyboard/mouse/touch internals | 6 | False positive — renamed accessors |
| `states.go` browser state cache | 4 | False positive — restructured (`@targets` / `set_state`) |
| `states.go` `Page.cleanupStates` | 1 | Ported — cache eviction on close (Phase 2) |
| `lib/launcher` internals | 10 | False positive — inlined / renamed / platform flags |
| `lib/cdp` client + websocket internals | 5 | False positive — `util/cdp/*` equivalents |
| `lib/utils` `IdleCounter.reset` | 1 | False positive — inlined in `done` / `wait` |
| `lib/docker` release tooling | 5 | Intentional divergence — recorded in the ledger (Phase 4) |
| `lib/proto/generate` codegen tooling | 5 | Intentional divergence — recorded in the ledger (Phase 4); Crystal `pdlgen` |
| `page.go` `getWindowID` / `initEvents` | 2 | `get_window_id`; `initEvents` -> `Page#init_events` (Phase 3) |

### Genuine missing functionality

1. **`Page.cleanupStates` — target-cache eviction on page close.** ✅ resolved
   Go `Page.Close` calls `cleanupStates()` → `Browser.RemoveState(TargetID)`,
   evicting the cached `*Page`. Crystal caches pages in `@targets`
   (`src/rod/browser.cr:36`). Ported in Phase 2: `Browser#remove_cached_page`
   (`src/rod/browser.cr:413`) is called from `Page#close` only on success
   (`src/rod/page.cr:1400`), matching Go's `if success { cleanupStates() }`.
   Covered by specs in `spec/page_settings_parity_spec.cr`.

### Structural divergences (accepted idioms, no action)

- Go `Browser.cachePage/loadCachedPage` store `*Page` in the same `sync.Map` as
  CDP state; Crystal uses a dedicated `@targets : Hash(String, TargetInfo)`
  with the page on `TargetInfo` (`browser.cr:225-250`).
- Go `Page.initEvents` creates a per-page event bus that calls `sessionCancel`
  on detach; Crystal exposes `Page#event` (`page.cr:537`) which ends the stream
  on detach/destroy and filters by session.
- Go `Launcher.getBin/getURL/hasLaunched/setupCmd/osSetupCmd` are inlined into
  Crystal `Launcher#launch` / `kill` (`launcher.cr:855-1000`, `@is_launched`
  at `launcher.cr:549`).
- Go `KeyActions.balance` → Crystal `balanced_actions` (`keyboard.cr:126`);
  `Keyboard.getModifiers` → `modifiers_unlocked` (`keyboard.cr:164`).
- Go `lib/docker` and `lib/proto/generate` are repo-local tooling; the Crystal
  port has its own generator (`src/pdlgen/`) and no Docker release script.
  Recorded as `intentional_divergence` in `go_port_inventory.tsv` (Phase 4),
  not ported.

---

## Phases

Legend: `[ ]` open · `[x]` done · `[~]` in progress · `[-]` not applicable

### Phase 1 — Tree-sitter discovery: exploratory overlay, not a gate ⚠️
- [x] Diagnosed the original "63 missing / 3422 stale" numbers: they come from
      `chiasmus-discover` (native tree-sitter labels) compared against the curated
      regex-vocabulary manifests, not from `make check-go-*`.
- [x] Corrected the earlier "blocked on the Ruby `tree_sitter` gem" note. The gem
      only feeds the placeholder tree-sitter branch in the repo's copied
      `scripts/parity_inventory_lib.rb`, which still calls `discover_with_regex`;
      `PORT_PARSER=tree-sitter` therefore warns and exits 0 by falling back to
      regex. Installing the gem changes the warning, not extraction.
- [x] Verified a real tree-sitter backend *is* available here:
      `verify_skill_install.sh . go tree-sitter` resolves a verified Chiasmus
      toolchain and reports `PARITY_DISCOVERY_BACKEND=chiasmus-tree-sitter`.
- [x] Measured the native vocabulary over `vendor/rod` with that verified binary:
      1416 `class`, 551 `function`, 2841 `method`, 1689 `const`, plus auxiliary
      `definition.method`/`field`/`params`/`return_type`/`reference.class` kinds.
      The curated ledger uses `func`/`struct`/`const`/`type`/`method`, and Go
      native discovery also merges standalone `const`/`type` declarations, so a
      kind rename alone cannot reconstruct the curated ids.
- [x] Decision (per the cross-language parity skill): keep `PORT_PARSER=regex`
      authoritative for the curated ledger (green: 5368 API items) and treat
      native discovery as an exploratory overlay. Never copy native ids or
      statuses into `go_port_inventory.tsv`.
- [ ] Optional tooling migration (Next up): adopt the installed skill's canonical
      scripts as forwarding wrappers. The canonical generator refuses to
      overwrite an existing manifest and emits `baseline`/`missing` rows, while
      the repo's copy forked to preserve curated status/refs/notes, so the
      refresh semantics have to be decided explicitly before switching. A
      tree-sitter *gate* additionally needs a reviewed id migration plus
      source-aware classification/dedup — not a gem install.

### Phase 2 — Page target-cache lifecycle parity ✅
- [x] Port `Page.cleanupStates`: evict the page's `@targets` entry on successful
      `Page#close` (mirror Go `RemoveState(TargetID)`), guarding the lock.
      Added `Browser#remove_cached_page` (`src/rod/browser.cr:413`), called from
      `Page#close` only on success (`src/rod/page.cr:1400`).
- [x] Add parity specs in `spec/page_settings_parity_spec.cr` asserting the
      cache entry is evicted after a successful close and retained when close is
      canceled (Go `if success { cleanupStates() }`).
- [x] Red-green TDD: spec failed before the change, green after. Full suite
      `571 examples, 0 failures`.
- [ ] Close the `states.go::method::Page.cleanupStates` ledger row — the row is
      absent from `go_port_inventory.tsv` (tree-sitter-only discovery); covered
      by the Phase 1 manifest reconciliation.

### Phase 3 — Per-page detach / event lifecycle verification ✅
- [x] Ported Go `Page.initEvents` as `Page#init_events` (`src/rod/page.cr:331`),
      started from `Browser#page_from_target` (`src/rod/browser.cr:236`). It
      cancels the page session context on `TargetDetachedFromTarget` (session
      match) or `TargetTargetDestroyed` (target match), so pending page
      operations fail fast. `Page#event` (`page.cr:565`) still ends the stream
      on the same events for consumers.
- [x] `Page#close` now drains the event channel with `receive?` and breaks on
      close (`src/rod/page.cr:1414`), matching Go's `for msg := range messages`
      tolerant shutdown when `initEvents` cancels the session first.
- [x] Specs added in `spec/page_event_lifecycle_parity_spec.cr`: context is
      canceled on detach and on target destroyed, and is left intact for
      another session's detach. Red-green TDD. Full suite
      `574 examples, 0 failures`.
- [x] Reconciled the `page.go::method::Page.initEvents` row (see category table).

### Phase 4 — Dev-tooling divergence sign-off ✅
- [x] Recorded `lib/docker/*` and `lib/proto/generate/*` as
      `intentional_divergence` in `go_port_inventory.tsv` (14 rows: 5
      `lib/docker` release-tooling helpers, 5 `lib/proto/generate` codegen
      internals, 4 generator template strings). Notes point at `src/pdlgen/`
      and `make generate-crystal`.
- [x] `scripts/check_port_inventory.rb` accepts `intentional_divergence` as a
      status, requires an explanatory note for it (and for `skipped`), and
      allows divergence rows that discovery never reports to stay in the ledger
      instead of failing as stale. Any other undiscovered row still fails.
- [x] Exercised `make generate-crystal` end to end. Outcome: generation runs,
      but a clean regeneration is **not expected** — `src/cdp` is a curated
      snapshot and the protocol vintage has moved. Evidence recorded in
      [docs/generation.md](generation.md): 57→59 domain dirs (adds `ads`,
      `crashreportcontext`, `digitalcredentials`, `findinpage`, `webmcp`;
      drops `console`, `database`, `schema`) plus 5 syntax errors from two
      emitter gaps (both fixed in Phase 6).
- [x] Fixed two real `pdlgen` bugs found by that exercise (both diverged from
      Go `cdproto-gen`): `get_dep_version` searched `Bytes` with a `String`
      needle and never matched (Go uses `bytes.Index`), and `get_refs` raised
      on gitiles entries without a `target` (Go decodes a missing field to the
      zero value). Covered by `spec/pdlgen_util_parity_spec.cr` (red-green).
- [x] Made the generation path reproducible: `make generate-crystal` takes
      `CDP_CHROMIUM`/`CDP_V8` pins (empty = `--latest`), and
      `make generate-crystal-scratch` runs the same generation into
      `temp/cdp_generated/` for toolchain checks without touching `src/cdp`.
- [x] CDP parity specs still pass against the committed tree (`make test`:
      579 examples, 0 failures).

### Phase 5 — Continuous parity gates & adversarial signoff ✅
- [x] Refreshed the generated manifests the safe way: the source/test generators
      now preserve the curated `status`/`crystal_refs`/`notes` columns and row
      order for known ids, drop ids discovery no longer reports, and append new
      ids as `missing` baseline rows (`--reset` still rebuilds from scratch).
      Red-green evidence: before the change a refresh rewrote all 5368 source +
      297 test rows to `missing\t-\tbaseline`; after it, regenerating an in-sync
      tree produces a byte-identical file. `ensure_parity_plan.sh . vendor/rod
      go regex 1` then passed with zero churn, so the snapshots are in sync with
      discovery at `vendor/rod` commit `d38c753`.
- [x] Adversarial pass — `scripts/verify_parity_adversarial.sh . vendor/rod go
      'crystal spec'`: manifest empty-field and row-quality checks pass, no
      placeholder specs in `spec/`, and the full Crystal suite is green. Fixed a
      false positive in that gate along the way: it scanned `src/` for the bare
      word `pending`, which matches the CDP client's `@pending` request map, so
      it now anchors the spec-DSL patterns (`pending`/`xit`/`xdescribe`/`xcontext`
      at line start) and scans `spec/` only. A planted `pending "..."` is still
      caught. The upstream side was executed directly rather than through the
      script: `GODEBUG=tracebackancestors=1000 go test -count=1 ./...` in
      `vendor/rod` passes 8 of 9 packages; `github.com/go-rod/rod` fails
      `TestPageElements` (fixture assertion) and `Example_basic` (page-init hang).
      Both live in the unmodified vendor tree and are environment/browser-timing
      issues, so they are recorded as upstream flakiness in Next up, not as port
      gaps. The `GODEBUG=tracebackancestors=1000` export is mandatory — rod's
      goroutine-leak detector panics without it.
- [x] Keep `go_port_inventory.tsv` curated; never regenerate it in place.

---

### Phase 6 — CDP emitter support for current protocol constructs ✅
- [x] Red-green specs in `spec/pdlgen_emitter_parity_spec.cr`: lifted inline-enum
      types must emit exactly one alias without a domain qualifier, and command
      constructors must put required parameters before optional ones. Both failed
      before the change (dotted `alias Fetch.AuthChallengeSource` emitted
      alongside the plain alias; `@required` after `@optional = nil`).
- [x] `fixup.cr`: added `strip_domain_prefix` and used it for lifted enum type
      names; `fixup_enum_parameter` now normalizes `ENUM_REF_MAP` refs before
      building raw names, so the lifted type merges with the domain fixup's type
      instead of creating a second, dotted one. Also removed two leftover
      `DEBUG:` puts that polluted generator output.
- [x] `crystal_templates/domain_module.ecr`: command constructors go through
      `ordered_parameters`, so required parameters precede optional ones.
- [x] Verified at Chromium `160.0.8168.1` / V8 `16.0.61`: generation succeeds,
      `crystal tool format` parses all 154 generated files with 0 syntax errors,
      and no alias carries a domain prefix.
- [ ] Out of scope (tracked in Next up): adopting that vintage — the domain set
      changes and the post-generation curation must be re-applied.

---

### Phase 7 — Generated JSON wire keys ✅
- [x] Red-green specs in `spec/pdlgen_json_key_parity_spec.cr`: every emitted
      field must carry `@[JSON::Field(key: "<protocol name>", emit_null: false)]`,
      and the key must be the camelCase protocol name rather than the underscored
      Crystal property. All three examples failed before the change (bare
      `emit_null: false` annotations everywhere) and pass after.
- [x] `crystal_template_generator.cr`: added `json_field_annotation(name)` and
      used it in the four emission sites — domain types, event parameters,
      command parameters and command returns — so the camelCase-key curation
      (`bd31de8`) is generator behaviour instead of a manual post-step.
- [x] Verified at Chromium `160.0.8168.1` / V8 `16.0.61`: 4005 keyed annotations,
      zero bare ones, the generated tree still parses with 0 syntax errors, and
      stable types match the committed style exactly (e.g.
      `Network.ResourceTiming`). Remaining diffs are vintage drift such as
      `remoteIpAddress` → `remoteIPAddress`.
- [ ] Still curated by hand: typed result decoding (`cc3717f`).

---

### Phase 8 — CDP protocol vintage adoption ✅
- [x] Red-green spec `spec/cdp_protocol_vintage_parity_spec.cr`: the pinned
      vintage's domain set (adds `ads`, `crashreportcontext`,
      `digitalcredentials`, `findinpage`, `webmcp`; drops `console`, `database`,
      `schema`), the `remoteIPAddress` wire key, typed `Cdp.call` result
      decoding, and enum serialization as wire integers. Failed before the
      regeneration and passes after.
- [x] Regenerated `src/cdp` at Chromium `160.0.8168.1` / V8 `16.0.61`: 59 domain
      directories, 306 `.cr` files. `console`/`database`/`schema` are retired
      from Chromium (go-rod's own generator drops them against a current
      browser), so their 54 ledger rows are `skipped` with a note and
      `spec/cdp_legacy_proto_parity_spec.cr` was removed with them.
- [x] Emitter work turned the last hand-curation into generator behaviour:
      recursive types emit `class` (a Crystal struct cannot contain itself;
      go-rod uses pointers), value types get constructors with required
      parameters first, `no_expose` runtime fields emit
      `@[JSON::Field(ignore: true)]` plus their initializer default, `extra`
      blocks can be member-scoped (`Input.TouchPoint#move_to`), `DOM.Point` is
      generated (Go declares it in its patch file), enums serialize as integers
      (`@[Flags]` enums also decode from an integer), and `Network.Request` gets
      go-rod's `post_data` back by decoding `postDataEntries`.
- [x] Per-domain alias targets preserved from the committed tree:
      `Network.TimeSinceEpoch`/`MonotonicTime` are `Time | Float64`,
      `Runtime.Timestamp` stays `Float64` (events are not normalized by
      `Cdp.call`), and `Network.CookieParam#expires` stays `Time`.
- [x] `Fixup.fix_domains` is idempotent (`Pdl::Domain#fixed?`): the CLI and the
      emitter both call it, which previously duplicated fused extras such as
      `enum FrameState`.
- [x] `make generate-crystal` is reproducible: it preserves the curated
      `src/cdp/cdp.cr` and `src/cdp/cdp/types.cr`, strips `._*` sidecars, drops
      directories left empty, and formats the tree. Running it twice produces an
      identical tree.
- [x] `src/rod` drift fixups: `Input.Modifier` is now a `$ref` bitmask, so
      mouse/touch/keyboard call sites build
      `Cdp::Input::Modifier.new(bits)`; `Network.Request.postData` is gone, so
      the hijack spec feeds base64 `postDataEntries`.
- [x] Gates: `make format`, `make lint` (240 files), `make test` (592 examples,
      0 failures) and `make check-go-*` all pass.
- [x] Superseded by Phase 11: the root was still emitted by a stale partial
      template, so generation preserved `cdp.cr`/`cdp/types.cr` by hand.

---

### Phase 9 — Deterministic live-browser specs ✅
- [x] Red-green `spec/page_reload_parity_spec.cr`: `Page#reload` must subscribe to
      `Page.frameNavigated` *before* triggering `location.reload()`, must ignore
      other frames' navigations, and must not return until its own frame
      navigates. Failed before the change (`reload` returned as soon as the JS
      call was accepted).
- [x] Red-green `spec/launcher_launch_parity_spec.cr`: a browser that takes 11s
      to print its DevTools URL must still launch (the port failed at the 10s
      timeout), and a browser that exits silently must still raise
      `Failed to get the debug url`.
- [x] `src/rod/page.cr`: `Page#reload` now matches go-rod's `Page.Reload` — it
      registers the frame-navigated wait first, evaluates `location.reload()`,
      then waits and unsets the JS context. This closed both flake shapes:
      `Rod::ObjectNotFoundError` on a stale `HTMLButtonElement` handle and
      `-32000 Cannot find context with specified id` from
      `DOM.getContentQuads`.
- [x] `src/rod/util/launcher.cr`: dropped the 10s launch timeout; `launch` races
      the parsed URL against process exit and context cancellation, as go-rod
      does. A loaded machine no longer turns a slow Chrome cold start into
      `[launcher] Failed to get the debug url`.
- [x] `src/rod/util/url_parser.cr`: `close` no longer closes the URL channel
      (go-rod's `URLParser` does not either), so the launcher's exit branch
      reports the parser error instead of `Channel::ClosedError`.
- [x] `spec/cdp_client_parity_spec.cr`: the `TestCrash` example crashed the
      browser after a fixed `sleep 1.second`, so on a loaded machine the
      `Runtime.evaluate` request could still be unsent when the browser died and
      the failure surfaced as "not connected" (write side) instead of
      "eof"/"closed" (read side) — the last flake, observed once in a full run
      with 3:50 wall time. It now wraps the websocket in a `SentFrameSpy` and
      crashes only after the evaluate frame is on the wire, which is the ordering
      go-rod's timer approximates. Both call assertions are also bounded
      (`failure_within`), so a call that stops failing fails the spec instead of
      hanging the suite.
- [x] Evidence: `scripts/stress_live_specs.sh` (8 concurrent workers × 5 rounds
      mixing `TestSearchIframes` and `TestCrash`, documented in
      `docs/testing.md`) went from 8-9 failures per 40 runs before the fixes to 0
      after; `TestCrash` alone passed 60/60 at 12-way parallelism; the suite
      passed three consecutive full runs (596 examples each) with the final
      change in place.
- [x] Out of scope at the time: `Page#navigate`'s 3s `Network.responseReceived`
      wait and the leaked `user-data-dir` directories. The navigation wait was
      removed in Phase 10; the iframe JS-context unset landed in Phase 12 and
      the profile cleanup in Phase 13.

---

### Phase 10 — `Page#navigate` parity ✅
- [x] Red-green `spec/page_navigate_parity_spec.cr`: `navigate` must return
      without waiting for network events (the port blocked for 3s), must raise
      `NavigationError` from `Page.navigate`'s `errorText`, and must not turn
      another document response's HTTP status into a navigation error. The first
      two failed before the change (3.003s elapsed; the stray 404 raised
      `NavigationError`).
- [x] Verified Chrome's own behavior with a local 404/500 server:
      `Page.navigate` returns `errorText = net::ERR_HTTP_RESPONSE_CODE_FAILURE`
      for empty-body error responses, which is why go-rod needs no response
      watcher (`TestPageNavigateErr` relies on exactly that).
- [x] `src/rod/page.cr`: `navigate` is now go-rod's sequence — ignore
      `stopLoading` errors, call `Page.navigate`, raise `NavigationError` on a
      non-empty `errorText`, unset the JS context. Removed the
      `Network.responseReceived` subscription, its 3s `timeout` and the
      `net::ERR_HTTP_RESPONSE_CODE_FAILURE` synthesis.
- [x] `spec/live_browser_parity_spec.cr` `TestBlockingNavigation`: dropped the
      artificial `.timeout(800.milliseconds)` around the blocked navigation and
      the `must_close` that raced it. go-rod's test never bounds that call —
      `MustNavigate` returns once Chrome accepts the navigation — so the ported
      spec no longer depends on the removed wait.
- [x] `spec/live_browser_parity_spec.cr` `TestScrollScreenshot`: a gate run hit
      Chrome's transient `-32000 Unable to capture screenshot` (the compositor
      has no frame to grab). go-rod surfaces that error unchanged, so the spec
      retries only that message (5 attempts, 200ms apart) and every other
      failure still surfaces immediately — verified with a stub page.
- [x] Gates: `make format`, `make lint` (240 files), `make test` (599 examples,
      0 failures, three consecutive full runs) and `make check-go-*` all pass.
- [x] Follow-up from this phase — navigating an iframe page used to unset the
      JS context on that page instead of go-rod's root page — closed in
      Phase 12.

---

### Phase 11 — The generator owns the whole CDP tree ✅
- [x] Red-green `spec/pdlgen_root_template_parity_spec.cr`: the rendered
      `cdp.cr` must equal the committed `src/cdp/cdp.cr` byte for byte, and the
      template must carry the curated root surface (`TIME_FIELD_KEYS`, both
      `Cdp.call` overloads, the timestamp transforms, `normalize_incoming`,
      `pattern_to_reg`, the `JSON::Serializable#from_json` helper, and the
      `Error`/`Err*` helpers with `data` and `is?`). Both examples failed first:
      the old 120-line template emitted a two-field `Error` and no call helpers.
- [x] `src/pdlgen/gen/crystal_templates/root.ecr` is now the single source of
      truth for the root module: it renders the curated API and interpolates
      `base_pkg`, so the generator no longer needs a side copy of the file.
- [x] `Makefile`: `generate-crystal` no longer saves/restores
      `src/cdp/cdp.cr` and `src/cdp/cdp/types.cr`. Running it at the pinned
      vintage (`CDP_CHROMIUM=160.0.8168.1 CDP_V8=16.0.61`) now produces a
      `git diff`-clean tree, including the shared `NodeType` alias, `._*`
      sidecar stripping and formatting.
- [x] `src/cdp/cdp.cr` needed one follow-up: the curated root annotated
      `Error#data` as `@[JSON::Field(emit_null: false)]` without a wire key, and
      `spec/pdlgen_json_key_parity_spec.cr` rejects that. The template and the
      committed file now both carry `key: "data"`, and the byte-equality spec
      pins them together.
- [x] `docs/generation.md`: `src/cdp` is described as generated end to end, with
      the root template and the parity spec cited.
- [x] Gates: `make format`, `make lint` (240 files), `make test` (601 examples,
      0 failures) and `make check-go-*` pass.

---

### Phase 12 — Shared JS-context cache, unset on the root page ✅
- [x] Red-green `spec/page_js_ctx_cache_parity_spec.cr`: navigating an iframe
      page must clear the *root* page's cached execution context (go
      `page.go:188` `p.root.unsetJSCtxID()`), and a page clone must observe a
      navigation performed on the page it was cloned from. Both examples failed
      first (one `Runtime.evaluate` instead of two).
- [x] `src/rod/page.cr`: the context id lives in `Page::JsCtxCache`, a mutable
      holder that `dup`-based clones share, reproducing go-rod's "use pointer so
      that page clones can share the change" (`page.go:70`). `navigate` unsets
      `root_page`'s cache (`page.cr:912`), and `unset_js_ctx_id` is `protected`
      so a page can clear its root's cache.
- [x] `js_ctx_id_cache=` still installs a *fresh* holder, matching Go's
      `new(...)` in `Element.Frame` (`element.go:466`) and
      `ElementFromObject` (`page.go:943`): iframe and iframe-context clones keep
      an independent cache.
- [x] Ledger: `page.go::method::Page.Navigate` now references the new spec and
      notes the root-page eviction.
- [x] Gates: `make format`, `make lint` (240 files), `make test` (603 examples,
      0 failures) and `make check-go-*` pass.
- Documented divergence (kept, no action): go-rod's `unsetJSCtxID` only clears
  the id, while the port also drops the cached helper functions. It costs one
  helper re-injection per navigation and changes no API behavior.

---

### Phase 13 — Browser profile cleanup ✅
- [x] Specs: live launch helpers now shut the browser down through the shared
      `shutdown_launcher` (`spec/spec_helper.cr`), which kills the process and
      then calls `Launcher#cleanup`, exactly like go-rod's `defer
      launcher.Cleanup()`. Previously only `kill` ran, so
      `$TMPDIR/rod/user-data` kept one profile per example (it had grown to
      thousands of directories).
- [x] Library: `Manager` now mirrors Go's `Manager.cleanup`
      (`manager.go:200`) — a managed browser is killed *and* its user-data-dir
      removed when the proxied socket closes. The port used to call only
      `launcher.kill`, leaking a profile (and its Chrome children) per managed
      launch.
- [x] Red-green `spec/launcher_parity_spec.cr` "removes the managed browser's
      user data dir when the client disconnects": failed with the profile still
      on disk, green after the change. `TestLaunchClient` now closes its proxy
      socket and waits for the profile to disappear, matching Go's teardown.
- [x] `eventually` moved to `spec/spec_helper.cr` (it was private to
      `spec/page_event_lifecycle_parity_spec.cr`) so teardown assertions can
      poll for fiber-driven state.
- [x] Gates: `make format`, `make lint` (240 files), `make test` (604 examples,
      0 failures) and `make check-go-*` pass.
- Go's `Manager.launch` also forces `leakless(true)` (`manager.go:181`); ported
  in Phase 14.

- Documented divergence (Next up): Go's `Manager.cleanup` only kills the
  managed browser on disconnect when the caller asked for `leakless`; the port
  always kills so it can always remove the profile.

---

### Phase 14 — Manager-launched browsers are always leakless ✅
- [x] Red-green `spec/launcher_parity_spec.cr` "forces leakless on the managed
      browser like go's manager": the `before_launch` hook disables leakless,
      and the spec asserts the launcher the manager actually uses has the
      `leakless` flag set once the client reaches `Browser.getVersion`. It
      failed first (`has(LEAKLESS)` was `false`).
- [x] `src/rod/util/launcher.cr`: `Manager#call` now forces
      `launcher.leakless(true)` after `before_launch` and before launching,
      matching Go `Manager.launch` (`manager.go:181`: "Always enable leakless so
      that if the Manager process crashes all the managed browsers will be
      killed"). The caller's flag is deliberately overridden, exactly like Go.
- [x] The two managed-browser specs keep their profiles on `Dir.tempdir` and
      assert cleanup, so the phase also guards against re-introducing profile
      leaks on the leakless launch path.
- [x] Gates: `make format`, `make lint` (240 files), `make test` (605 examples,
      0 failures) and `make check-go-*` pass.

---

### Phase 15 — Manager kill decision matches go-rod ✅
- [x] Red-green `spec/launcher_parity_spec.cr` "leaves the managed browser
      running when the caller disabled leakless": a managed client that sends
      `leakless(false)` must survive the proxy socket closing, because go-rod
      computes `kill := l.Has(flags.Leakless)` before forcing leakless
      (`manager.go:181`) and only then runs `cleanup`. It failed first (the port
      killed the browser: `Process.exists?(pid)` was false).
- [x] `src/rod/util/launcher.cr`: `Manager#call` reads the caller's leakless
      intent before `launcher.leakless(true)` and hands it to
      `cleanup_managed_launcher(launcher, kill)`, which kills only when the
      caller asked for a managed browser and otherwise just waits for the
      browser's own exit before removing its profile.
- [x] Specs that expect a manager teardown now ask for it explicitly
      (`TestLaunchClient` and the profile-cleanup example call `.leakless(true)`
      on the managed launcher), so no example leaves a Chrome process or a
      profile behind: a full `make test` run adds none.
- [x] Gates: `make format`, `make lint` (240 files), `make test` (606 examples,
      0 failures) and `make check-go-*` pass.
- Documented divergence: Go blocks its proxy handler on `<-l.exit` inside
  `Manager.cleanup`, which parks the handler's goroutine when it deliberately
  leaves a browser running. The port spawns that wait instead, so the handler
  returns while the profile is still removed once the browser exits.

---

### Phase 16 — Live-browser pool (harness infrastructure) ✅
- [x] Red-green `spec/live_browser_pool_spec.cr`: the pool must reuse one
      browser across examples (go-rod's `testerPool`, `setup_test.go:41`), blank
      the page the next example inherits (`tester.page.MustNavigate("")`,
      `setup_test.go:124`) and close the extra targets, return the browser when
      an example raises, run isolated examples in their own browser, and close
      everything on cleanup. A first pass with launch-per-call and no reset
      failed four of the five examples (`Expected: 1, got: 2` launches; the
      inherited page was still on `https://example.com/left-behind`), then the
      pool implementation made them green.
- [x] `spec/support/live_browser_pool.cr`: `RodSpec::LiveBrowserPool` with
      `with` (acquire → reset → block → release), `with_isolated`,
      `close_all` and a `launches` counter, plus the shared
      `RodSpec.live_browser_pool` singleton. It launches one headless Chrome per
      borrower, tracks each browser's launcher so the profile is removed on
      shutdown, and closes every pooled browser from an `at_exit` hook (go-rod
      does the same in `TestMain`, `setup_test.go:51`).
- [x] The pool spec also drives a real browser: two consecutive borrows return
      the same instance, the second sees exactly one page (the extra target was
      closed) already blanked to `about:blank`, and `launches` stays at 1.
- [x] `spec/spec_helper.cr` requires the support file; no library code changed.
- [x] Specs only: the live spec files still launch per example. Migrating them
      is Phase 17 (Next up), one file per commit with a state audit, because a
      few examples kill the connection or swap the browser's client and need
      `with_isolated`.
- [x] Gates: `make format`, `make lint` (240 files), `make test` (612 examples,
      0 failures) and `make check-go-*` pass.

---

### Phase 17 — Live-browser parity spec on the pooled harness ✅
- [x] Red-green `spec/live_browser_pool_spec.cr` "shares one browser between the
      live examples that use the harness": a first cut of
      `RodSpec.with_live_browser` delegated to `with_isolated`, so two borrows
      launched two browsers (`Expected: 1, got: 2`); delegating to the pool's
      `with` made it green.
- [x] `spec/support/live_browser_pool.cr`: added `RodSpec.with_live_browser` and
      `RodSpec.with_isolated_browser`, made `with` drop a browser whose reset
      fails (a crashed or disconnected browser no longer poisons the pool for
      the next example), and added an opt-in `ROD_POOL_STATS=1` launch counter.
- [x] `spec/live_browser_parity_spec.cr`: the local helper delegates to the
      pool, and the six examples that change browser-wide state or kill the
      browser use `with_isolated_browser` (`TestPageWaitRequestIdle`'s logger and
      trace, `TestBrowserCrash`, `TestElementTracing`, `TestTrace`,
      `TestTraceLogs`, `TestMonitor`). Launches: 56 → 7, file wall time ~3 min →
      50 s. The two examples that need their own launcher before connecting
      (`TestBrowserLostConnection`, `TestMonitorErr`) keep it.
- [x] Re-ran the file and the pool spec three times each: no cross-example
      contamination, and `Target.closeTarget` settling is polled instead of
      sampled once.
- [x] Gates: `make format`, `make lint` (240 files), `make test` (613 examples,
      0 failures), wall time down from 3:01 to 1:46 and `make check-go-*` pass.

---

### Phase 18 — Pooled harness: leftover contexts + calculator e2e ✅
- [x] Red-green `spec/live_browser_pool_spec.cr` "disposes the incognito
      contexts an example created": after an example worked in an incognito
      context, the next borrower still saw it
      (`Expected: ["62AB77…"] to be empty`). `LiveBrowserPool#reset` now calls
      `Target.disposeBrowserContext` for every context the browser does not own
      (the default context is not listed by `Target.getBrowserContexts`), so a
      shared browser no longer accumulates the contexts incognito-based examples
      create.
- [x] `spec/examples_e2e_calculator_parity_spec.cr`: the file-local helper
      delegates to `RodSpec.with_live_browser`, so both examples share one
      browser (2 → 1 launch, `ROD_POOL_STATS=1` shows `launches=1`) while each
      keeps its own incognito context, now disposed between examples.
- [x] Left per-example on purpose: `page_navigation_error_parity_spec.cr` and
      `page_iframe_reload_parity_spec.cr` (Phase 19), and the launcher/client
      specs which test the launcher and client themselves.
- [x] Gates: `make format`, `make lint` (240 files), `make test` (614 examples,
      0 failures, 1:30 wall time) and `make check-go-*` pass.

---

### Phase 19 — Remaining live specs by default, stale-node retries ✅
- [x] Red-green `spec/live_spec_gating_parity_spec.cr`: no spec may hide behind
      `ROD_REAL_BROWSER`, because a gated ported test never runs (go-rod runs
      every test in `go test ./...`). It failed with the two gated files listed.
      Both now guard on the machine capability (`RodSpec.chrome_available?`)
      instead of a per-run opt-in.
- [x] `spec/page_iframe_reload_parity_spec.cr` and
      `spec/page_navigation_error_parity_spec.cr`: local launchers replaced with
      `RodSpec.with_live_browser`, so they share the pooled browser.
- [x] Un-gating exposed a real port gap: the iframe-reload example failed about
      one run in three with `Element not found: iframe` /
      `{-32000 No node with given id found }`. Chrome uses that phrasing when the
      cached document root belongs to the previous document, and
      `stale_document_root_error?` only knew "Could not find node with given id"
      and "Node with given id does not belong to the document".
- [x] Red-green `spec/page_stale_node_retry_parity_spec.cr`: one example per
      stale-node phrasing, plus one where the document is replaced more than
      twice. Before the fix the first phrasing escaped as `NotFoundError` and the
      multi-attempt case failed; `src/rod/page.cr` now recognizes all three
      phrasings and `retry_finding` keeps retrying stale document roots until the
      query deadline (go-rod's element lookup does the same). Eight consecutive
      runs of the two migrated files are green.
- [x] Gates: `make format`, `make lint` (240 files), `make test` (619 examples,
      0 failures, 2:00 wall time) and `make check-go-*` pass.

---

### Phase 20 — Docs, changelog, comments and example refresh ✅
- [x] `CHANGELOG.md` (new): Keep-a-Changelog format, `Unreleased` section covering
      the JS-context sharing, stale-node retries, manager lifecycle, profile
      cleanup and the pooled harness, plus a `0.8.0` section reconstructed from
      the commits between the `v0.7.0` and `v0.8.0` tags. `docs/pr-workflow.md`
      now requires an `Unreleased` entry.
- [x] `docs/testing.md`: new "Live browser specs" section (pool contract,
      `with_live_browser` / `with_isolated_browser`, context disposal,
      `ROD_POOL_STATS`, `ROD_CHROME_BIN`), the no-env-gate rule, and the
      stale-node retry example added to the flakiness section.
- [x] `docs/architecture.md`: spec harness location, the shared `Page::JsCtxCache`
      invariant (with the Go pointers), and the launcher/manager lifecycle.
- [x] `docs/development.md`, `docs/resuming.md`, `docs/coding-guidelines.md`,
      `README.md`, `AGENTS.md`: `spec/support/` layout, pooled-browser env notes,
      the "never gate a ported example" rule, and links to the changelog. The
      suite-time gotcha now says ~2:00 instead of ~2:20.
- [x] Code comments: the harness header described the per-example launches it was
      written to remove; both it and the pool spec's "Phase 17 is removing"
      comment now describe the steady state, and the pool's comments document the
      context-disposal and dead-browser rules.
- [x] `examples/e2e-testing/`: the calculator example now closes each page
      (`ensure`, mirroring `g.Cleanup(page.MustClose)`), closes the shared browser
      and its incognito contexts at the end, and cites the Go files it ports.
      `crystal build --no-codegen` passes.
- [x] Gates: `make format`, `make lint` (240 files) and `make test` (619 examples,
      0 failures, 1:53) pass; no library behavior changed.

---

### Phase 21 — Launcher output contract (issue `rod.003`) ✅

Verified both claims in the reported issue against `vendor/rod` and the port:

- **Launch logging (true).** `Launcher#launch` emitted
  `@logger.info { "Launching browser: ..." }` through a
  `Log.for("rod.launcher")` whose default backend writes INFO to stdout, and the
  launcher carried a `::Log` logger with no upstream counterpart. go-rod's
  launcher logger is `io.Discard` (`launcher.go:120`), filled only by
  `Launcher.Logger(w)` (`launcher.go:403`), which `setupCmd` wires as
  `io.MultiWriter(l.logger, l.parser)` for stdout *and* stderr
  (`launcher.go:514-515`), so `rodney start` prints only its own two lines.
  `Browser`'s download logging is *not* a divergence: go-rod's
  `Browser.Logger` defaults to stdout (`browser.go:107`) and `fetchup` prints
  progress there, so the port keeps its `Log.for("rod.launcher")` download
  lines.
- **Managed-download `bin_path` on macOS (false).** `Browser#download` already
  ends with `strip_first_dir` (go `browser.go:150`), and the existing
  "downloads and extracts browser archive, stripping top-level directory" spec
  covered it, so `<dir>/Chromium.app/Contents/MacOS/Chromium` is correct and no
  download-then-`File::NotFoundError` exists. A new spec now pins that claim
  end to end instead of leaving it implicit.
- [x] `src/rod/util/launcher.cr`: dropped the launch INFO line and the
      launcher's `::Log` logger; `Launcher#logger(io)` stores a sink and
      `output_sinks` builds one `IO::MultiWriter` per stream, so the parser
      always sees the DevTools URL and the caller's IO sees browser output only
      when set.
- [x] `src/rod/util/leakless.cr`: `Launcher#command` takes an `output` sink and
      wires both streams instead of leaving the browser's stdout on an unread
      pipe, which would block the browser once the pipe buffer filled.
- [x] Red-green `spec/launcher_parity_spec.cr`: "forwards browser stdout and
      stderr to the logger sink without logging the launch" (fails while the old
      INFO line exists), "forwards browser output to the logger sink on the
      leakless path", and "resolves bin_path inside the stripped
      managed-download layout" (fails when `strip_first_dir` is removed).
- [x] Gates: `make format`, `make lint` (240 files), `make test` (622 examples,
      0 failures) and `make check-go-*` pass.

**Intentional divergence:** `Launcher#logger=(::Log)` was removed together with
the logging it fed — go-rod's API is `Logger(io.Writer)` only. A consumer that
silenced the line (`launcher.logger = Log.new(...)`, the reported
`Webb::CLI.cmd_start` workaround) must delete that workaround; there is nothing
left to silence.

---

### Phase 22 — Issue triage: `wait_stable` request idle + exFAT strip ✅

Triaged every file in `temp/issues/` against `vendor/rod` and the port:

- **rod.001 (Crystal `HTTP::Server` has no CONNECT upgrade) — not actionable
  here.** The report is about `webb _proxy` (go-rod's `rodney` `proxyConnect`,
  `main.go:1895-1946`). This repo does not port `rodney` — the ledger has no
  `rodney` rows and `src/` has no proxy server — so the gap lives in the
  consumer's CLI plus Crystal stdlib, not in `dsisnero/rod`.
- **rod.002 (`wait_stable` waits a duration instead of the request queue) —
  true.** go-rod's `WaitStable` runs `WaitLoad`, `WaitRequestIdle(d, nil, nil,
  nil)()` and `WaitDOMStable(d, 0)` concurrently (`page.go:821`); the port
  spawned `wait_duration(d)` for the middle branch, and `wait_request_idle`
  existed but was never called.
- **rod.003 item 1 (launch log on stdout) — resolved by Phase 21 (`1f7636a`).**
  Its "remaining" claim is wrong: go-rod's `Browser.Logger` defaults to
  `log.New(os.Stdout, "[launcher.Browser]", ...)` (`browser.go:107`) and is
  handed to `fetchup` (`browser.go:140`), so download progress on stdout is
  upstream behavior. The port keeps its download INFO lines; only the
  launcher's own launch line was spurious.
- **rod.003 item 2 (exFAT skips `strip_first_dir`) — true and reproduced on this
  checkout.** On the exFAT volume `unzip` writes AppleDouble sidecars next to
  every extracted entry (`._chrome-mac`, `._Chromium.app`, `._Contents`), so
  `Dir.children(dir)` returns two entries and the single-entry guard skipped the
  strip, leaving `bin_path` dangling. The sidecars are readdir phantoms: a
  `File.rename` of one fails with `File::NotFoundError`, and they disappear with
  the entry they describe.

- [x] `src/rod/page.cr`: `Page#wait_stable` calls
      `wait_request_idle(d).call` instead of `wait_duration(d)`, matching
      `page.go:821`.
- [x] `src/rod/util/launcher.cr`: `strip_first_dir` ignores AppleDouble
      (`._*`) and `.DS_Store` entries when counting *and* moving children, and
      keeps the strict single-real-entry guard otherwise.
- [x] Red-green `spec/page_wait_parity_spec.cr` ("waits for load, request idle,
      and DOM stability like go-rod" fails on the old `wait_duration` branch) and
      `spec/launcher_parity_spec.cr` ("strips the top-level directory even when
      macOS sidecars sit next to it" fails with the strict guard; "does not strip
      when the download directory holds several real entries" keeps the guard
      honest).
- [x] End-to-end on this exFAT checkout (local zip server, `root_dir` under
      `temp/`): before the fix the download dir held `["._chrome-mac",
      "chrome-mac"]` and `bin_path` did not exist; after the fix it holds
      `["._Chromium.app", "Chromium.app"]` and the binary is there.
- [x] Gates: `make format`, `make lint` (240 files), `make test` and
      `make check-go-*` pass.

**Intentional divergence:** `fetchup.StripFirstDir` is strict about
`len(entries) == 1`; ignoring macOS metadata is a host-environment shim for this
exFAT checkout, not a behavior go-rod has. It is inert on APFS/HFS+ and on Linux,
where no `._*` entries are produced.

---

### Phase 23 — `IdleCounter#wait` observes cancellation ✅

Reviewed `7356dd8` ("port: let IdleCounter#wait observe cancellation") against
`vendor/rod`:

- Go's `IdleCounter.Wait` selects on `<-ctx.Done()` / `<-de.tmr.C`
  (`lib/utils/utils.go:218-229`). A cancelled Go context's `Done()` is a
  **closed** channel: the receive returns immediately, no panic. Crystal's
  `Rod::Context#cancel` closes `@done` (`context.cr:79`) and `Channel#receive`
  on a closed channel **raises** `Channel::ClosedError`, so the port's bare
  `receive` was a translation bug, not a parity difference. `receive?` (nil on
  close) is the faithful mapping and is already what `page.cr`, `browser.cr`,
  `cdp/client.cr` and `context.cr` use for the same channel.
- `spec/utils_sleeper_spec.cr` already covered Go's `ctx.Cancel();
  ct.Wait(ctx)` case, but only through the `cancelled?` pre-check before the
  select; the new example covers the cancel-while-blocked race, which is the
  path that raised.

- [x] `src/rod/util/utils.cr`: `wait` selects on `ctx.done.receive?`.
- [x] Red-green `spec/utils_sleeper_spec.cr` "returns without raising when the
      context is cancelled while waiting": with `receive` it fails with
      `Channel::ClosedError`; green now, and stable over five runs.
- [x] Gates re-run here: `make format`, `make lint` (240 files), full
      `make test` (626 examples, 0 failures), `make check-go-*` pass.

**Latent, not reachable today:** `Goob::Pipe#write` (`src/rod/goob.cr:24`) also
selects on a *closed* done channel with a bare `receive`. Its only caller
(`Browser#init_events`, `browser.cr:438`) rescues `Channel::ClosedError` and
breaks, so it was contained; Phase 24 fixed it.

---

### Phase 24 — Event hub survives a closed `done` channel ✅

Last item of the "closed channel" class found in Phase 23. `Goob` ports
`github.com/go-rod/goober`, which rod pulls in as a module dependency rather than
a vendored package, so there is no `vendor/rod` file to pin against; its
`pipe.Write` is `select { case p.wait <- struct{}{}: case <-p.done: }`, and Go's
`<-p.done` is an immediately-ready branch that simply returns once `done` closes.

- Red-green `spec/goob_observable_spec.cr` (new): publish once to fill the pipe's
  one-slot signal buffer, close `done`, then publish again. With the buffer full
  the done branch is the only ready one, so the old code raised deterministically
  (8/8 runs) at `src/rod/goob.cr:22`; the spec is green now.
- [x] `src/rod/goob.cr`: `Pipe#write` and both `Pipe#run_loop` selects use
      `done.receive?`; `Observable#subscribe`'s cleanup awaits `done.receive?`
      instead of rescuing `Channel::ClosedError`.
- [x] `docs/coding-guidelines.md`: records the trap — Go's `<-ch` returns on a
      closed channel, Crystal's `Channel#receive` raises, so closed-capable
      channels need `receive?`; bare `receive` stays where a close must fail
      loudly (Go panics on a send to a closed channel).
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (627 examples, 0 failures), `make check-go-*` pass. Two
      `spec/live_browser_parity_spec.cr` examples failed once under load and pass
      in isolation (56/56 twice) and in the following full run — the documented
      Chrome-timing flakiness, not a port defect.

---

## Guardrails

- Generated manifests are disposable; `go_port_inventory.tsv` and this file are
  curated. Regenerate freely, re-curate deliberately.
- Do not weaken Go tests or fixtures to make Crystal green.
- Do not add ledger rows for Go-only tooling as `ported`; use
  `intentional_divergence` or `skipped` with a note.
- Ledger statuses accepted by `scripts/check_port_inventory.rb`: `missing`,
  `in_progress`, `ported`, `partial`, `skipped`, `intentional_divergence`.
  `skipped` and `intentional_divergence` require a note, and their rows may name
  Go items that discovery never reports (documented divergences do not fail the
  stale check); every other undiscovered row still fails.
- Commit each completed phase as one atomic `port:` change.
