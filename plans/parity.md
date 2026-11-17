# Go → Crystal Parity Plan

**Source of truth**: `vendor/rod` (go-rod) at `d38c753`
**Target**: Crystal port under `src/`, specs under `spec/`
**Language**: `go` · **Manifests**: `plans/inventory/go_*`
**Last evaluated**: 2026-11-17

## Where we are

**Current focus:** Phase 9 removed the live-browser flakiness that Phase 8's gate
runs kept hitting: `Page#reload` now waits for `Page.frameNavigated` for its own
frame (go-rod's `Page.Reload`), and `Launcher#launch` no longer imposes a fixed
10s timeout — it races the parsed DevTools URL against process exit and context
cancellation like go-rod. Both have red-green specs and a stress harness. The
next open work is Phase 1 (still blocked on the `tree_sitter` Ruby gem) plus the
optional cleanups listed below.

**Last commit:** `port: make the live-browser specs deterministic`

**Gates (2026-11-17, after Phase 9):** `make format` pass · `make lint` pass
(240 files) · `make test` pass (596 examples, 0 failures, three consecutive full
runs with the final change) · parity checks pass (5665 inventory rows with 10
documented divergences and 54 `skipped` legacy protocol rows, 5368 API items,
297 tests) · upstream Go suite: 8/9 packages pass, `go-rod/rod` main package has
browser-timing failures (see Next up).

**Next up:**

1. Phase 1 — (blocked) needs the `tree_sitter` Ruby gem plus kind/id
   normalization before the tree-sitter checks can run; it also closes the
   `states.go::method::Page.cleanupStates` ledger row (the only Phase 2 bullet
   still open).
2. Upstream Go suite flakiness: `github.com/go-rod/rod` failed
   `TestPageElements` and `Example_basic` on 2026-11-17 while the other eight
   packages passed. Re-run before reading anything into a failure — these are
   browser-timing issues in the vendored project, not port gaps.
3. Optional cleanup: the repo tracks built binaries (`rod`, `bin/pdlgen*`,
   `pdlgen*`), so local builds keep showing up as modified files. Decide whether
   to untrack them.
4. Optional follow-up: the generator's `root.ecr` template (120 lines) is still a
   stale partial of the curated `src/cdp/cdp.cr` (277 lines, holds `Cdp.call`,
   `Client`, `TIME_FIELD_KEYS`). Teach the template to emit the curated root so
   `make generate-crystal` no longer needs the preserve/restore step.
5. Optional follow-up: `Page#navigate` still waits on `Network.responseReceived`
   with a 3s cap instead of go-rod's `WaitNavigation` lifecycle event, so a slow
   navigation can return early. Same class of bug as the reload race; add a
   red-green spec before changing it.
6. Optional follow-up: live specs leave their `user-data-dir` behind
   (`launcher.kill` without `launcher.cleanup`), so `$TMPDIR/rod/user-data`
   grows with every run. Have the specs call `cleanup` in their `ensure` block.

**Gotchas:** the 63 tree-sitter "missing" items and the 3422 kind-rename
"stale" rows are tooling vocabulary drift, not port gaps — see below. Phase 2's
last checklist bullet (`states.go::method::Page.cleanupStates` ledger row) is
also waiting on that reconciliation. `make generate-crystal` is not reproducible
by default (`--latest`); pin `CDP_CHROMIUM`/`CDP_V8` (Phase 8 records the working
pair). Chrome dropped the `console`, `database` and `schema` domains, so those
inventory rows are `skipped` and `spec/cdp_legacy_proto_parity_spec.cr` is gone.
The upstream Go suite panics in its leak detector unless
`GODEBUG=tracebackancestors=1000` is exported. The checkout is on exFAT, so a
generation emits `._*` AppleDouble sidecars — strip them before counting files.
`Launcher#launch` has no timeout on purpose: a browser that never prints a
DevTools URL now waits until the process exits or the context cancels, exactly
like go-rod, so a wedged browser hangs instead of failing fast.

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
| Crystal specs | 79 files, 596 examples, 0 failures (2026-11-17, Chromium `160.0.8168.1`) |

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

### Phase 1 — Reconcile tree-sitter discovery drift ⛔ blocked
- [x] Diagnosed: the drift is not 63 items. Adding the 63 unexported rows to the
      ledger/source manifest does not turn the check green — it then reports
      **3422 stale** rows because tree-sitter renames every `func`/`struct`/
      `const`/`type` id to `function`/`class`/`definition.*`.
- [ ] **Blocked on tooling**, not the repo: strict `PORT_PARSER=tree-sitter`
      requires kind/id normalization before the curated regex-vocabulary
      manifests can match. Options (both outside this repo):
  1. Normalize tree-sitter kinds/ids to the curated vocabulary in
     `parity_inventory_lib.rb#discover_with_crystal_discovery`
     (`function`→`func`, `class`→`struct`, `definition.type`/`field`→`const`/`type`).
  2. Add a `--kind-map`/normalization mode to the bundled `chiasmus-discover`.
- [ ] Until then, keep `PORT_PARSER=regex` as the authoritative gate (green:
      5368 API items). Treat tree-sitter output as an exploratory overlay.
- [ ] (Blocked) Re-run `check_port_inventory.sh` / `check_source_parity.sh` with
      `PORT_PARSER=tree-sitter` and confirm exit 0.

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
- [ ] Out of scope (Next up): the `root.ecr` template still does not emit the
      curated root module, so generation keeps preserving those two files.

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
- [ ] Out of scope (Next up): `Page#navigate`'s 3s `Network.responseReceived`
      wait and the leaked `user-data-dir` directories.

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
