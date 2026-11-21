# Go → Crystal Parity Plan

**Source of truth**: `vendor/rod` (go-rod) at `d38c753`
**Target**: Crystal port under `src/`, specs under `spec/`
**Language**: `go` · **Manifests**: `plans/inventory/go_*`
**Last evaluated**: 2026-11-20

## Where we are

**Current focus:** nothing in flight. The tree is clean and pushed, every gate is
green, and the last feature commit is Phase 59 (`Element#input` dispatches its
change events with go's `js.InputEvent` helper as a user gesture; the upstream
`TestSetDocumentContent` is now ported as a guard, and the last Phase 2 ledger
bullet is closed).

To confirm the baseline in a new session: `make format && make lint` (seconds),
then `make test` (~1m45s). Before a full run, clear stray headless browsers left
by an aborted run — `pgrep -f "rod/user-data" | xargs -r kill -9`; they push the
live specs into their documented load flake (see Gotchas).

Phases 23-59 all came from *auditing `vendor/rod` area by area*: both ledgers
are 100% `ported` (inventory 5607/54/15, tests 297 with four upstream `t.Skip`s),
so new work has to be found by comparing behaviour. Next up item 1 keeps the
recipes that found those 37 phases, plus the list of areas already swept, so a
fresh session can pick up without re-deriving any of it.

**Last commit:** `port: dispatch input events with go's InputEvent helper`
(Phase 59; `git log -1` for the hash).

**Gates (2026-11-20, after Phase 59):** `make format` pass · `make lint` pass
(240 files) · `make test` pass (731 examples, 0 failures) · parity checks pass
(5665 inventory rows with 10 documented divergences and 54 `skipped` legacy
protocol rows, 5368 API items, 297 tests) · upstream Go suite: 8/9 packages pass,
`go-rod/rod` main package has browser-timing failures (see Next up).

**Next up:**

1. **[code, red-green] Next parity phase — the audit queue is empty; use these
   recipes.** Both ledgers are 100% `ported` (inventory: 5607 `ported` / 54
   `skipped` / 15 `intentional_divergence`; tests: 297 `ported`, the only four
   `N/A` rows are upstream `t.Skip`s), so the next phase comes from a behaviour
   diff, not from a missing symbol. Each recipe below produced at least one
   Phase; they are ranked by hit rate:
   - **Class sweep.** Pick one Go construct and grep both trees for it:
     `defer <restore>()`, `select {`, `Unwrap()`, `<domain>.enable`,
     `Context(el.ctx)`, `gson.Int(0)`, `json:\",omitempty\"`,
     `evalHelper(js.X)`, `EnableDomain(`. Phases 23/24 (closed channels), 27/28
     (`Unwrap`/`errors.Is`), 54/55 (`bool` + `omitempty`), 56 (`Context(el.ctx)`),
     57/58 (`EnableDomain`) and 59 (helper vs hand-written JS) all came from it.
   - **Ported-test audit.** For every `vendor/rod/*_test.go` function, check the
     Crystal spec drives the same path. Stub-only ports hide real bugs: Phase 43
     (`TestHandleAuth` -> `Fetch domain is not enabled`), Phase 47
     (`Element#parents` always answered `[]`).
   - **Untested-method audit.** `def`s in `src/rod/**` that no spec names are
     cheap leads (98 of 453 at Phase 55; most are `must_*` wrappers, the rest are
     accessors and helpers).
   - **Payload round-trip.** Record a CDP request with a stub client and compare
     its bytes with what Go's `gson`/`encoding/json` would emit; that is how the
     `fromSurface`/`callFunctionOn` bugs were found.
   - **Swept so far, do not re-audit:** context/cancellation (23, 26), event hub
     (24), launcher/manager (21, 25, 29, 34), error types (27, 28), quad geometry
     (30, 49), `Element.Wait*` (31), lookup probes (32), `wait_interactable` (33),
     `ElementsByJS` (35), hijack (36), `WaitDownload` (37), input mac mode (38),
     `Pages#find` (39), `LoadResponse` (40), `SelectAllText` (41), `HandleAuth`
     (42, 43), `LoadState` + screenshot viewport (44), element queries +
     `parents` (45, 47), iframe panic handler (46), generation gate (50),
     `Search` + root-repaint rule (51), dev-helper overlays (52), `Expose` (53),
     capture flags (54), `browser.go` `Page`/`Pages`/cookies/devices table (55),
     element context (56), `EachEvent`/`WaitEvent` (57), `SetExtraHeaders` /
     `HandleDialog` (58), `Element#input` + `set_document_content` +
     `cleanupStates` + `reload`/`close` (59). All 32 `lib/js` helpers are
     byte-identical (Phase 39) and `Key.Encode` payloads match (Phase 38).
2. **[tooling] Phase 1 tooling migration:** wrap the installed skill's canonical
   parity scripts instead of the repo's copied ones (whose `tree-sitter` branch
   is a placeholder), and decide curated-status preservation. Native tree-sitter
   discovery already works via the verified Chiasmus toolchain, but its
   vocabulary (`class`/`function`/`definition.*` plus merged `const`/`type`
   declarations) cannot be mapped onto the curated ids by a kind rename, so the
   gate stays `PORT_PARSER=regex` until a reviewed id migration lands. (The last
   Phase 2 checklist bullet, `Page.cleanupStates`, is closed in Phase 59, so this
   is now tooling-only work.)
3. **[verify] Upstream Go suite flakiness:** `github.com/go-rod/rod` failed
   `TestPageElements` and `Example_basic` on 2026-11-17 while the other eight
   packages passed. Re-run before reading anything into a failure — these are
   browser-timing issues in the vendored project, not port gaps. Run with
   `GODEBUG=tracebackancestors=1000`.
4. **[verify] Generation no-op gate:** `make check-generate-crystal` regenerates
   the pinned vintage (`CDP_CHROMIUM=160.0.8168.1`, `CDP_V8=16.0.61`) into
   `temp/cdp_generated/` and diffs it against `src/cdp`; it passes with a warm
   cache and needs network on a cold one (PDL files come from googlesource.com).
   Re-run it after any template edit — Phase 30 and 59 both hand-edited generated
   output alongside its template.
5. **[optional cleanup]** The repo tracks built binaries (`rod`, `bin/pdlgen*`,
   `pdlgen*`), so local builds keep showing up as modified files. Decide whether
   to untrack them.
6. **[optional follow-up]** `spec/cdp_client_parity_spec.cr` and
   `spec/launcher_parity_spec.cr` still launch their own browsers. That is
   deliberate — they exercise the CDP client and the launcher itself
   (`TestLaunchClient`, `Browser.close` handling) — so only revisit it if a
   future spec needs a pooled page on top of its own client.

**Loop checklist** — what "done" means for every phase (AGENTS.md is the
authority):

1. red-green: the new spec fails for the intended reason before the fix (stash
   the src change and watch it fail, or write the spec first);
2. `make format`, `make lint`, `make test` (~1m45s, 731 examples) and
   `make check-go-port-inventory` / `check-go-source-parity` /
   `check-go-test-parity`;
3. `plans/parity.md`: new Phase entry + **Where we are** + **Next up** updated;
4. `CHANGELOG.md` `Unreleased` entry (`Added`/`Changed`/`Fixed`);
5. ledger rows the change touched (`crystal_refs` / notes), or an
   `intentional_divergence` row when the port deliberately differs;
6. one `port: ...` commit (what changed, divergences, gate results, upstream
   `d38c753`) and `git push` — never leave a finished phase for the next loop.

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
`Launcher#kill` cannot reap Chrome's children: go-rod starts the browser with
`Setpgid: true` so `killGroup(-pid)` reaches them, while Crystal's `Process` has
no `setpgid`, so only the browser pid is signalled. That is why leftover
headless browsers need the manual `pgrep -f "rod/user-data" | xargs kill` above.
`Launcher#launch` has no timeout on purpose: a browser that never prints a
DevTools URL now waits until the process exits or the context cancels, exactly
like go-rod, so a wedged browser hangs instead of failing fast. Do not run
`scripts/stress_live_specs.sh` (or any parallel browser work) at the same time as
`make test`: the extra load pushes the suite from ~2:00 to 5-8 minutes and makes
Chrome itself drop connections mid-example, which looks like a port bug. On
2026-11-17 three `chiasmus` runs from another checkout kept the load average
above 12 for hours; a full suite then took 12 minutes and
`TestScrollScreenshot` exhausted its compositor retries even though it passes in
isolation. Re-run before blaming a change. A killed or aborted spec run can also
leave its headless browsers behind (`pgrep -f "rod/user-data"`); they keep the
machine busy, and `TestScrollScreenshot` then fails with `-32000 Unable to
capture screenshot` even on a pristine tree — `pgrep -f "rod/user-data" | xargs
kill` clears them. Keep
browser profiles out of `./temp`: on the exFAT checkout Chrome's AppleDouble
`._*` sidecars appear in `readdir` but `FileUtils.rm_rf` cannot unlink them, so
`Launcher#cleanup` silently leaves the profile behind (use `Dir.tempdir`). The
same sidecars break naive directory traversals: `strip_first_dir` has to ignore
`._*`/`.DS_Store` or a managed download leaves `bin_path` dangling (Phase 22).
A live spec that starts a CDP flow in a detached fiber (`spawn { ... }`) must
await it before the example ends (e.g. `done.receive`), otherwise the pooled
browser can go back with a domain still enabled and the next example's
navigations stall — that is what made `spec/live_browser_pool_spec.cr` fail
after the live auth test was added (Phase 43). A stub-only upstream test can hide
a whole broken path: `TestHandleAuth` was "ported" against stubs while
`handle_auth` could never complete a real challenge (`Fetch domain is not
enabled`); port the live test first. A *vacuous* stub-only test hides one just as
well: Phase 51's `#scroll_into_view` example passed for months because its stub
element overrode the exact `evaluate` overload the buggy path used, and Phase
52's overlay examples stubbed `overlay` itself, so the missing removal was never
exercised. Assert the CDP traffic (or the returned helper), not just that no
exception was raised. Two concurrent `crystal spec` runs on this machine can
also make a run report a foreign example list (once: `4458 examples` in 24 s
including `../dataframe/spec/...`) because they share the Crystal cache binary;
re-run before reading numbers into a count.

**Porting traps found while auditing** (each cost a phase; check them when a Go
symbol "already exists" but misbehaves):

- `<-ch` on a *closed* channel is an immediately-ready branch in Go, but
  Crystal's `Channel#receive` raises `Channel::ClosedError`. Any channel that can
  be closed (a context's `done`, a subscription hub's shutdown signal) must be
  awaited with `receive?` — Phases 23 and 24 were both this bug.
- A bare `raise` (re-raise) inside a class that defines `method_missing` is
  captured by the macro and fails to compile at the *call* site
  (`undefined method 'raise'`). `Element#must_interactable` shipped unusable
  because of it (Phase 27). Name the error: `raise ex`.
- `abs` on geometric sums hides winding order: Go's `DOMQuad.Area` is signed and
  `OnePointInside` filters on `Area() >= 1` (Phase 30).
- A stub spec that only asserts *recorded options* proves nothing about real
  calls: `Element#parents` (Phase 47) and `Element#get_xpath` (Phase 48) both
  "passed" while answering `[]`/`"/"` for every real page. When a method runs JS
  that uses `this`, check that it goes through the element's `evaluate`/`wait`
  (which bind `this`) and not `@page.evaluate` — and cover it with a live spec.
- Enabling a CDP domain is state, not a call: go's `EnableDomain`
  (`states.go:60-73`) skips `*.enable` when the registry already has it and makes
  the restore a no-op. Unconditional `enable`/`disable` pairs disable a domain
  someone else still needs (Phases 57 and 58).
- Go options are `bool`/`int` with `json:",omitempty"`, so a zero never reaches
  the wire. The port's proto fields are `Bool?`, so passing an explicit `false`
  breaks any field whose CDP default is `true` (`fromSurface`, Phase 54) and
  sends noise elsewhere (`callFunctionOn`, Phase 55).
- Element operations run in the element's context (`el.page.Context(el.ctx)`,
  15 sites in `element.go`). A method that calls `@page.x` directly ignores an
  `Element#timeout`/`#context` clone (Phase 56).

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
| Crystal specs | 94 files, 715 examples, 0 failures (2026-11-20, Chromium `160.0.8168.1`) |

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
- [x] Close the `states.go::method::Page.cleanupStates` ledger row — done in
      Phase 59 without waiting for the tooling migration: go's `cleanupStates`
      deletes a `sync.Map` entry keyed by the bare `TargetID` (`states.go:117-119`)
      and nothing upstream ever stores under that key (`Browser.set` stores
      `stateKey` structs), so it is a no-op; the row is now recorded as
      `intentional_divergence` naming the port's equivalent
      (`Browser#remove_cached_page`).

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

### Phase 25 — Manager logging matches `manager.go` ✅

`Manager#logger` was a Crystal `::Log` property (not go-rod's `utils.Logger`
shape) that nothing ever wrote to, so the four management events go-rod logs
through `Manager.Logger` were missing.

- Go: `Logger utils.Logger` defaulting to `utils.LoggerQuiet` (`manager.go:118,
  141`), writing `Launch <url> <options>` then `Close <url>` around the proxied
  connection (`manager.go:190-191`) and `Killed PID: <n>` / `Removed <dir>` in
  cleanup (`manager.go:203,209`).
- [x] `src/rod/util/launcher.cr`: `Manager#logger` is now
      `Rod::Util::Utils::Log` defaulting to `Utils.logger_quiet` (the port's
      Println adapter), and the manager emits all four lines with Go's argument
      shape, including the caller's raw options JSON.
- [x] Cleanup parity while wiring the logs: `cleanup_managed_launcher` skips the
      profile removal *and* the exit wait when `--rod-keep-user-data-dir` is set
      (Go's `Manager.cleanup` only calls `l.Cleanup()` inside
      `if !KeepUserDataDir`), and the three ways a connection can end (client
      close, upstream close, the run fiber's `ensure`) funnel through one
      idempotent `shutdown`, so kill/remove/log happen once like Go's single
      `defer`.
- [x] Red-green `spec/launcher_parity_spec.cr` "logs launch, close, killed pid
      and removed dir like go's manager": red with no logger call (no `Removed`
      line within 15 s), green now; asserts the order Launch → Close → Killed
      PID → Removed, that `Close` repeats the launched URL, that `Killed PID:`
      carries a number and `Removed` names the profile dir. Stable over three
      runs.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (628 examples, 0 failures), `make check-go-*` pass.

---

### Phase 26 — Context deadlines follow Go's `context.Context` rules ✅

`Rod::Context` said it was "modeled after Go's context.Context but simplified",
and the simplification was observable: `deadline` was a plain per-instance
property, so

- a nested timeout **extended** the parent's budget instead of being capped by
  it, and
- any derived context (`with_value`, `with_cancel`, which is what
  `Page#timeout` builds on top of `with_timeout`) reported **no deadline at
  all**, so `deadline_remaining`/`timeout_remaining` — the caps used by
  `Page#retry_finding` and `Element#wait_interactable` — silently fell back to
  the caller's timeout.

Go: `context.WithTimeout` is `WithDeadline(now+d)`, and `WithDeadline` keeps the
parent deadline when it is sooner (`if cur, ok := parent.Deadline(); ok &&
cur.Before(d) { return WithCancel(parent) }`); `Context.Deadline` walks the
parent chain.

- [x] Red-green `spec/context_spec.cr`: "caps a nested timeout at the parent's
      deadline" (red: 10 s instead of 50 ms), "reports the inherited deadline
      through a derived context" (red: `deadline_remaining` nil, and
      `timeout_remaining(5.seconds)` returning 5 s), plus guards that the
      shorter of the two deadlines wins and that contexts without a deadline
      still report none.
- [x] `src/rod/context.cr`: `deadline` is now an inheriting getter over the
      parent chain (the owning instant stays in `@deadline`), `deadline_remaining`
      reads that getter, and `with_timeout` caps its deadline at the parent's and
      skips its own timer when the parent wins — the parent listener cancels the
      child with the parent's error, exactly like `WithCancel(parent)`.
- [x] Regression the change exposed: with the deadline finally visible,
      `Page#retry_finding` reported `NotFoundError "Element not found within 5s"`
      when the *context* ran out first. It now prefers the context error, which
      is what go-rod's `utils.Retry` returns through the sleeper. The existing
      `spec/page_element_timeout_parity_spec.cr` "respects context timeout while
      polling for missing elements" caught it and pins it.
- [x] `spec/page_element_timeout_parity_spec.cr`: "cannot extend an outer timeout
      with a nested one (Go WithDeadline parity)".
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (633 examples, 0 failures), `make check-go-*` pass.

---

### Phase 27 — Error matching follows `errors.Is` (`unwrap`) ✅

`error.go` defines `Unwrap()` on `TryError`, `InvisibleShapeError`,
`CoveredError` and `NoPointerEventsError`, so `errors.Is(err,
&rod.NotInteractableError{})` matches any of the three interactability errors.
The port shipped `unwrap` methods but `Rod.is?` only walked `cause`, and
`Element#must_interactable` classified with `rescue ex : NotInteractableError`,
which cannot match a *sibling* class.

- Red-green `spec/error_spec.cr`: "follows unwrap like go's errors.Is" (red:
  false for all three), "follows a chain of unwraps" (red through `TryError`),
  plus a guard that the concrete type still wins over unrelated classes.
- [x] `src/rod/error.cr`: new `Rod::Unwrappable` (Go's `Unwrap` interface),
      included by the four error classes; `Rod.is?` now checks the concrete type,
      then `unwrap`, then `cause`.
- [x] `src/rod/must.cr`: `Element#must_interactable` uses
      `Rod.is?(ex, NotInteractableError)` (`must.go:794`), so `CoveredError`,
      `InvisibleShapeError` and `NoPointerEventsError` return `false` like Go
      instead of raising.
- [x] Latent bug found while testing it: the method **could not compile at all**.
      `Element` defines `method_missing` (the `foo!` alias macro), which captures
      the bare re-`raise` at the end of the rescue chain, so any call site failed
      with `undefined method 'raise' for …`. `raise ex` fixes it; it is the only
      bare `raise` in `src/` (`src/rod/must.cr:712`) and the two other
      `method_missing` classes (Browser, Page) have none.
- [x] Red-green `spec/element_spec.cr`: "returns false for every
      not-interactable error like go-rod" (compile error before), "returns true
      when the element is interactable", and "raises other errors".
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (639 examples, 0 failures), `make check-go-*` pass.

---

### Phase 28 — Lookup misses are `ElementNotFoundError` ✅

go-rod raises `*ElementNotFoundError` (`"cannot find element"`) from every
lookup, and `query.go` classifies with `errors.Is(err, &ElementNotFoundError{})`
(`query.go:107,119,131,450,462,471,480`). The port had two unrelated classes:
`NotFoundError` (`"Element not found"`, raised by `Page#retry_finding`) and
`ElementNotFoundError`, which nothing raised outside specs — so go-rod code
matching `Rod.is?(err, Rod::ElementNotFoundError)` never fired.

- [x] Ring-fenced as Next up item 6 in Phase 27 and landed here with its own
      red-green pass, because the change moves the exception type every miss
      raises.
- [x] `src/rod/types.cr`: `ElementNotFoundError` moved next to `RodError` with a
      Go-compatible default message, and `NotFoundError` now subclasses it (the
      class had to move: `error.cr` already requires `types.cr`, so the reverse
      would be a require cycle). The port-specific detail message
      ("Element not found within 5s", `cause`) is kept — matching is by class.
- [x] `src/rod/page.cr`, `src/rod/query.cr`: every not-found classification now
      matches the base type (`has`, `has_x`, `has_r`, `element_optional`, the
      `element_by_*` pass-throughs and the query-branch retry), like Go's
      `errors.Is`.
- [x] Red-green: `spec/error_spec.cr` "is the base type of the port's lookup
      miss" (red: not an `ElementNotFoundError`) and
      `spec/page_element_timeout_parity_spec.cr` "reports a lookup miss as
      ElementNotFoundError like go-rod" (red: got `NotFoundError`), which also
      keeps `err.is_a?(NotFoundError)` for the port's own callers.
- [x] Guards: `ElementNotFoundError#is?(NotFoundError)` stays false (the base
      does not match the subclass) and the Go message is unchanged.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (641 examples, 0 failures), `make check-go-*` pass.

---

### Phase 29 — Header-less managed launches work like `manager.go` ✅

`Manager#call` answered **501** (`[rod-manager] websocket launch not
implemented`) to a websocket upgrade that carried no `Rod-Launcher` header, and
an existing spec pinned that stub. Go's `Manager.launch` treats the header as
optional: `options := r.Header.Get(HeaderName); if options != "" { l.Flags = nil;
json.Unmarshal(...) }` (`manager.go:172-178`), so a header-less upgrade launches
with `New()`'s default flags.

- [x] Red-green `spec/launcher_parity_spec.cr` "launches with the default flags
      when the caller sends no options header": the 501 spec is gone, replaced by
      a real managed launch over a header-less socket (`ws.connect(url)` with no
      headers) that runs `Browser.getVersion` through the proxy. Red before the
      change (handshake failed on the 501), green now.
- [x] `src/rod/util/launcher.cr`: the launcher is always created and only has its
      flags cleared/replaced when options are present, matching Go's guard.
      `before_launch` still runs, so the manager's path protection keeps applying.
- [x] `Launch` logging passes the (possibly empty) options straight through, as
      Go does.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (641 examples, 0 failures), `make check-go-*` pass.

---

### Phase 30 — Quad area keeps its sign like `proto.DOMQuad.Area` ✅

go-rod's `DOMQuad.Area` (`lib/proto/a_patch.go:90-100`) returns the shoelace sum
`/ 2` **without** an absolute value, and `DOMGetContentQuadsResult.OnePointInside`
only accepts quads with `q.Area() >= 1` (`a_patch.go:107-117`), so a
clockwise-wound quad is treated as having no visible shape. Both copies in the
port took `abs`: the hand-written `Rod::Util::Quad` (used by
`Element#interactable`) and the generated `Cdp::DOM` helpers, so a clockwise quad
still produced a center point.

- [x] Red-green `spec/cdp_dom_quad_parity_spec.cr`: "keeps the sign of the
      shoelace area like go's DOMQuad.Area" (red: `1.0` instead of `-1.0` for a
      clockwise unit square, in both implementations) and "skips clockwise quads
      in one_point_inside like go" (red: a point instead of `nil`).
- [x] `src/rod/util/quad.cr`, `src/cdp/dom/dom.cr` and the `pdlgen` template that
      emits the latter (`src/pdlgen/gen/crystal_extras.cr`,
      `dom_module_helpers`) drop the `abs` with matching comments, so a future
      `make generate-crystal` stays a no-op. The generation no-op check itself is
      still blocked on the Chromium PDL fetch (Next up item 3).
- [x] The ported Go cases are unchanged (`Area()` of `0` and `1`, the `rect`
      `Center`, the three-quad `OnePointInside`/`Box` example), so this only
      touches the winding case Go never tested explicitly.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (643 examples, 0 failures), `make check-go-*` pass.

### Phase 31 — `Element.Wait*` retries through the page sleeper ✅

go-rod's wait helpers are one-liners over `Element.Wait` (`element.go:608-636`):
`WaitVisible`/`WaitInvisible` pass `evalHelper(js.Visible)`/`evalHelper(js.Invisible)`,
`WaitEnabled`/`WaitWritable` pass `Eval('() => !this.disabled')`/`Eval('() => !this.readonly')`,
and `Wait` retries through `page.Context(el.ctx).Sleeper(el.sleeper).Wait(...)`, so
the context deadline and the chained sleeper decide when to stop. The port polled a
private `wait_for(timeout)` loop instead (fixed 5 s deadline, 10 ms sleep,
`Rod::TimeoutError`), ignoring both, and `visible?` used its own JS (`opacity`
check, no client-rect check) rather than `js.Visible`.

- [x] Red-green `spec/element_wait_parity_spec.cr`: ports of `TestWaitInvisible`,
      `TestWaitEnabled` and `TestWaitWritable` on the pooled browser, plus
      "matches go's js.Visible for opacity and zero-size elements" (red:
      `opacity:0` reported invisible while a zero-size fixed box reported
      visible), "retries wait_visible through the element sleeper like go's
      Element.Wait" (red: `Rod::TimeoutError` after 5 s instead of
      `MaxSleepCountError`) and "surfaces the context deadline from
      wait_visible" (go: `DeadlineExceededError`).
- [x] `src/rod/element.cr`: the four helpers lost their `timeout` argument (go has
      none), delegate to `Element#wait`, and `private wait_for` is gone.
      `visible?` now evaluates `eval_helper(JS::VISIBLE)`, so the predicate and
      the wait agree again.
- [x] `spec/element_spec.cr`: unit coverage asserts each helper's `Page#wait`
      call, the `this` binding and the exact JS predicate (`/* visible:`,
      `/* invisible:`, `() => !this.disabled`, `() => !this.readonly`); the stub
      overrides dropped the removed `timeout` parameter.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (649 examples, 0 failures), `make check-go-*` pass.

### Phase 32 — Lookup probes use `NotFoundSleeper` like go-rod ✅

go-rod separates "look once" from "wait for it": `Page#Has`, `Element#Has`,
`Element#ElementByJS` and every `RaceContext` branch go through
`NotFoundSleeper` (`error.go:63-68`, `query.go:105-138`, `query.go:460-508`,
`query.go:438-457`), so a miss fails on the first attempt instead of waiting out
the page timeout. Elements also inherit their page's `ctx` and `sleeper`
(`ElementFromObject`, `page.go:947-953`). The port retried every one of those
with the page's own sleeper, and `Element.new(obj, page)` reset the context to
`Context.background`: `page.has("#missing")` blocked for the full 5 s query
timeout, `el.has("#missing")` never returned (a 2 s element timeout did not
apply because the lookup ran on the page context), a `Race` burned 5 s per
missing branch, and `Rod.not_found_sleeper` returned a bare proc that could not
be installed through `Page#sleeper` at all.

- [x] Red-green `spec/query_probe_parity_spec.cr`: live `page.has`/`el.has` miss
      timing (red: 5 s and a `DeadlineExceededError`), an element-level lookup
      that must raise `ElementNotFoundError` instead of hanging (red: still
      running after 10 s), `Race` branch timing (red: 5.01 s), and elements
      inheriting the page deadline/sleeper; unit cases assert the probe sleeper
      (`ElementNotFoundError` after one miss), the chained sleeper on the found
      element and `elements_by_js` running in the element context.
- [x] `Rod.not_found_sleeper` is the factory shape Go's `NotFoundSleeper` has
      (`func() utils.Sleeper`), so `page.sleeper(Rod.not_found_sleeper)` works.
- [x] `Page#has`/`has_x`/`has_r` probe with it and hand the found element
      `el.sleeper(@sleeper)`; `Element#element_by_js` probes in
      `page.Context(el.ctx)` and chains `el.sleeper`;
      `Element#elements_by_js` runs in the element context;
      `RaceContext#do` gives branches the probe page and the winner the page
      sleeper.
- [x] Elements built by `element_from_object` (and `elements_by_js`,
      `refresh_iframe_element`, `Element#shadow_root`) inherit the page's `ctx`
      and `sleeper`.
- [x] `spec/query_has_parity_spec.cr` and `spec/query_race_parity_spec.cr`
      compare the returned clone's `object` (go returns `e.Sleeper(...)` too) and
      assert the chained sleeper; `spec/page_elements_query_parity_spec.cr`
      answers the per-element `jsCtxIDByObjectID` calls go makes in
      `ElementFromObject`.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (657 examples, 0 failures), `make check-go-*` pass.

### Phase 33 — `wait_interactable` retries like go's `Element.WaitInteractable` ✅

go-rod's `WaitInteractable` is `utils.Retry(el.ctx, el.sleeper(), ...)`
(`element.go:587-606`): it scrolls the element into view, calls `Interactable()`,
retries only on `CoveredError`, and stops on any other error or when the context
or sleeper gives up. The port wrapped the same retry in its own deadline
(`timeout_remaining(5s)`), so a modal that lifts after five seconds surfaced the
`CoveredError` instead of waiting, and `wait_interactable` was the last wait
helper with an invented `timeout` argument.

- [x] Red-green `spec/element_wait_interactable_parity_spec.cr`: a button under
      an overlay that jumps away after 5.6 s (red: `CoveredError` at 5.0 s),
      the fast uncover path, the element deadline
      (`DeadlineExceededError`) and a `CountSleeper` (`MaxSleepCountError`).
- [x] `src/rod/element.cr`: `wait_interactable` lost the `timeout` argument and
      the deadline bookkeeping; it is `Utils.retry(@ctx, @sleeper.call)` with
      `CoveredError` as the only retry case.
- [x] `spec/element_spec.cr`: the stub and the retry spec use the new
      signature, and a new case pins that a non-covered error stops the wait
      after one `interactable` call.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (662 examples, 0 failures), `make check-go-*` pass.

### Phase 34 — Launcher shutdown matches `Launcher.Kill`/`Cleanup` ✅

go-rod's launcher shutdown (`lib/launcher/launcher.go:544-566`, `os_unix.go:12-14`)
sleeps one second, returns when the PID is 0, then sends **SIGKILL** to the
process group (`killGroup`) and SIGKILL to the pid (`p.Kill()`) — never SIGTERM
— and `Cleanup` waits for the browser to exit and removes the `user-data-dir`
unconditionally; `--rod-keep-user-data-dir` is the Manager's concern
(`manager.go:200-208`). The port sent TERM before every KILL and skipped the
profile removal when the keep flag was set.

- [x] Red-green `spec/launcher_shutdown_parity_spec.cr`: a recording launcher
      pins the exact signal set (`[{KILL, -pid}, {KILL, pid}]`, red: four
      TERM/KILL pairs), the `pid == 0` guard, a real process that must die, and
      a profile that must be removed even with the keep flag (red: kept).
- [x] `src/rod/util/launcher.cr`: `kill` sends only `SIGKILL`, through a small
      `private def signal(sig, pid)` seam that ignores "already exited" errors
      like go's `_ = syscall.Kill(...)`; `cleanup` drops the keep-flag check.
- [x] Known limitation (recorded under Gotchas): go-rod starts the browser with
      `Setpgid: true`, so `killGroup(-pid)` reaches Chrome's children. Crystal's
      `Process` has no `setpgid`, so the group signal only lands when the
      browser already leads a group and the per-pid SIGKILL is what reaps it —
      orphaned helpers are why a killed run can leave headless browsers behind.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (666 examples, 0 failures), `make check-go-*` pass.

### Phase 35 — `ElementsByJS` reports go's `ExpectElementsError` ✅

go-rod's `Page.ElementsByJS` (`query.go:206-246`) returns
`&ExpectElementsError{res}` when the evaluated value is not an array, and
`&ExpectElementsError{val}` for an array entry that is not a DOM node — reading
`val.Subtype` unconditionally, so an accessor descriptor (no value) fails too.
Both errors carry the offending remote object so callers can match them with
`errors.Is`. The port raised plain `Exception`s with descriptive messages,
`ExpectElementsError` was never constructed anywhere in `src/`, and an array
entry without a `value` was silently skipped.

- [x] Red-green `spec/page_elements_query_parity_spec.cr` (stub) and
      `spec/query_elements_error_parity_spec.cr` (live): non-array result,
      non-node entry, and a property without a value all raise
      `ExpectElementsError` carrying that object; the array is still released;
      the success path still maps nodes to elements.
- [x] `src/rod/page.cr`: the three cases raise `ExpectElementsError.new(...)`
      (`query.go:212-235`) instead of anonymous exceptions.
- [x] `src/rod/error.cr`: `ExpectElementsError` takes a nilable remote object and
      renders it as `null`, like go's `RuntimeRemoteObject.String` for the
      accessor case.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (669 examples, 0 failures), `make check-go-*` pass.

### Phase 36 — Hijack bodies follow go's `JSONBody`/`Body` ✅

go-rod's `HijackRequest.JSONBody` is `gson.NewFrom(ctx.Body())`
(`hijack.go:290-292`), which answers a null JSON when the body is not JSON, and
`HijackResponse.Body` is `string(ctx.payload.Body)` (`hijack.go:340-343`), so the
payload is the only source of truth. The port called `JSON.parse` directly (any
plain-text POST raised `JSON::ParseException` inside the handler fiber, which
`TestHijack` would have hit with `g.True(ctx.Request.JSONBody().Nil())`), and
kept a parallel `@body_text` field that a `payload=` replacement could leave
stale.

- [x] Red-green `spec/hijack_parity_spec.cr`: a non-JSON, empty and nil body
      answer a null JSON while `[1,2]` and `{"k":"v"}` still parse (red:
      `JSON::ParseException`), and a body written straight to
      `payload.body` is visible through `response.body` (red: `""`).
- [x] `src/rod/hijack.cr`: `json_body` rescues `JSON::ParseException` into
      `JSON::Any.new(nil)`; `HijackResponse#body` base64-decodes `payload.body`
      (falling back to the raw string when it is not base64) and `set_body` only
      writes the payload, so `@body_text` is gone.
- [x] `spec/live_browser_parity_spec.cr`: the `TestHijack` port now also asserts
      go's `ctx.Request.JSONBody().Nil()` for the fixture's plain `"a"` POST.
- [x] Accepted divergences recorded here: `HijackResponse#set_header` matches
      header names case-insensitively (go's exact-name index appends a duplicate
      entry for a differently-cased name, which the port avoids), and
      `HijackRequest#set_context` is a no-op because Crystal's `HTTP::Request`
      has no context to carry.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (672 examples, 0 failures), `make check-go-*` pass.

### Phase 37 — `WaitDownload` restores the previous behavior ✅

go-rod's `Browser.WaitDownload` (`browser.go:504-538`) reads the current download
behavior back with `has := b.LoadState("", &oldDownloadBehavior)`, sets
`allowAndName` for the download directory, and on completion re-applies the saved
behavior (`oldDownloadBehavior.Call(b)`) or `default` when there was none. The
port always forced `default`, so a browser configured with `allowAndName`/`deny`
lost that configuration after every download.

- [x] Red-green `spec/browser_wait_download_parity_spec.cr`: a browser whose
      stored state is `allowAndName`/`/previous` must get it back after the wait
      (red: `default`), while the existing no-previous-state case still asserts
      the `default` fallback.
- [x] `src/rod/browser.cr`: `wait_download` captures the stored
      `Browser.setDownloadBehavior` payload, and `restore_download_behavior`
      rebuilds it through `from_json` (Crystal request types are structs, so the
      payload is read from the state store rather than mutated into the request
      like go's reflective `LoadState`), falling back to `default` when the
      payload is absent or unrebuildable.
- [x] Accepted divergence noted: the port enables Browser-domain download events
      (`eventsEnabled: true`) because it waits on `Browser.downloadWillBegin`/
      `Browser.downloadProgress`, where go waits on the Page-domain events.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (673 examples, 0 failures), `make check-go-*` pass.

### Phase 38 — Input mac mode and `macCommands` parity ✅

go-rod's `IsMac` is `runtime.GOOS == "darwin"` and `Key.Encode` looks editing
commands up with `macCommands[info.Key]` (`lib/input/mac_comands.go:5`,
`keyboard.go:108-111`). The port defaulted `mac?` to `false` on every platform
and carried a single `ArrowDown` row, so on macOS no editing command was ever
emitted and the other reachable keys lost theirs.

- [x] Red-green `spec/input_keymap_spec.cr`: `mac?` must default to the host OS
      (red: `false` on darwin), and `ArrowUp`/`ArrowLeft`/`ArrowRight`/`Escape`/
      `F5`/`Delete`/`Home`/`End`/`PageUp`/`PageDown` must carry go's command
      (red: `nil`), while character keys such as `Enter` (`"\r"`) and `KeyA`
      (`"a"`) stay command-less because go's table keys cannot match them.
- [x] `src/rod/util/input/input.cr`: `@@is_mac` is initialised from
      `flag?(:darwin)`, and `MAC_COMMANDS` is go's reachable subset verbatim
      (the combination rows are documented as unreachable in go).
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (675 examples, 0 failures), `make check-go-*` pass.

### Phase 39 — `Pages#find` reports `PageNotFoundError` ✅

go-rod's `Pages.Find`/`FindByURL` (`query.go:76-102`) propagate the per-page
errors and answer `(nil, &PageNotFoundError{})` on a miss, so callers match it
with `errors.Is`. The port returned a nilable `Page?`, which made the miss
indistinguishable from a real page result and left `PageNotFoundError` to the
`must_*` helpers only.

- [x] Red-green `spec/pages_parity_spec.cr`: a miss must raise
      `PageNotFoundError` for both `find` and `find_by_url` (red: `nil`), while
      the hit and the propagated eval-error cases keep their expectations.
- [x] `src/rod/page.cr`: `find`/`find_by_url` return `Page` and raise
      `PageNotFoundError`; `src/rod/must.cr`'s `must_find`/`must_find_by_url`
      now just delegate.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (675 examples, 0 failures), `make check-go-*` pass.

### Phase 40 — `Hijack.LoadResponse` honours `loadBody` ✅

go-rod's `Hijack.LoadResponse` (`hijack.go:224-250`) reads the proxied response
body only when `loadBody` is true (`if loadBody { io.ReadAll(res.Body) }`); the
headers, status and `RawResponse` are always taken. The port called
`HTTP::Client#exec(request)` without a block, and Crystal's non-block form
buffers the whole body before returning, so `load_body: false` downloaded
everything anyway — a hijack handler proxying a large file paid for it.

- [x] Red-green `spec/hijack_parity_spec.cr`: against a server that sends
      headers plus one chunk and then stalls 1.5 s, `load_response(client, false)`
      must return in under a second with `payload.body` nil (red: 1.50 s), while
      `load_response(client, true)` still returns `"startend"`.
- [x] `src/rod/hijack.cr`: `load_response` streams through
      `client.exec(request.req) { |res| ... }` and only drains
      `res.body_io.gets_to_end` when `load_body` is set.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (677 examples, 0 failures), `make check-go-*` pass.

### Phase 41 — `SelectAllText` selects field contents (issue `rod.004`) ✅

`temp/issues/rod.004.md` reported that `Element#select_all_text` selected a
document range (`window.getSelection()` + `range.selectNodeContents`) instead of
go-rod's `js.SelectAllText` (`function(){this.select()}`). Document ranges do not
cover `<input>`/`<textarea>` contents — those live in
`selectionStart`/`selectionEnd` — so nothing was selected and the following
`InsertText` prepended: `"hi"` became `"hello therehi"`, and clearing a field was
impossible. The shard already shipped the correct helper; the method just never
called it. `Element#select_text` had the same gap in shape (hand-written JS, no
user gesture).

- [x] Verified against `vendor/rod`: `SelectAllText` is
      `el.Evaluate(evalHelper(js.SelectAllText).ByUser())` (`element.go:241-254`)
      and `SelectText` is `evalHelper(js.SelectText, regex).ByUser()`
      (`element.go:228-239`).
- [x] Red-green `spec/element_select_all_text_parity_spec.cr` (live): a field
      with `value="hi"` must read `"hello there"` after
      `select_all_text` + `input` (red: `"hello therehi"`), a textarea must read
      `"new"` (red: `"newold"`), and `selectionEnd` must be `3` (red: `0`); the
      `select_text` case keeps its expectations as a guard.
- [x] `src/rod/element.cr`: both methods evaluate the shared helpers with
      `by_user`; the hand-written selection JS is gone.
- [x] `spec/element_spec.cr`: the unit case now pins the helper (`/* selectText:`,
      `/* selectAllText:`) and the user-gesture flag instead of the inline JS.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (682 examples, 0 failures), `make check-go-*` pass.

### Phase 42 — `HandleAuth` restores the Fetch domain like go-rod ✅

go-rod's `Browser.HandleAuth` (`hijack.go:415-455`) tears the domain down with
`disable := b.DisableDomain("", &FetchEnable{})`, turns on auth handling with
`b.EnableDomain("", &FetchEnable{HandleAuthRequests: true})`, and defers
`cancel()`, `disable()`, `enable()` — so whatever Fetch state the caller had
before the auth wait is restored. The port called `Fetch.disable` /
`Fetch.enable` directly and always disabled at the end, which stopped a hijack
router that was running before `handle_auth`.

- [x] Red-green `spec/browser_handle_auth_parity_spec.cr`: with
      `Fetch.enable` already in the browser state, the cleanup sequence must end
      with `Fetch.enable` (red: `Fetch.disable`), while the fresh-browser case
      still ends with `Fetch.disable`.
- [x] `src/rod/browser.cr`: `handle_auth` installs the two restore functions and
      runs them in go's deferred order (`cancel`, disable restore, enable
      restore) from an `ensure`, so the error path cleans up too.
- [x] Follow-up recorded: the upstream `TestHandleAuth` is still only covered by
      this stub spec. A live basic-auth port was attempted in this phase and hit
      `net::ERR_INVALID_AUTH_CREDENTIALS` with an ad-hoc fixture server, so it
      needs the fixture/server shape go-rod uses (`g.Serve` + `BasicAuth`)
      before it can replace the stub — see **Next up**.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (683 examples, 0 failures), `make check-go-*` pass.

### Phase 43 — event waits keep caller-enabled domains (live `TestHandleAuth`) ✅

Porting the live `hijack_test.go::test::TestHandleAuth` exposed a pre-existing
bug rather than a fixture problem: `Browser#wait_event_typed` re-enabled the
event's domain and **always** disabled it in its cleanup, ignoring the browser
state map — go-rod's `eachEvent` uses `b.EnableDomain(sessionID, enable)`
(`browser.go:355-375`), which only enables the domain when it is off and only
restores it then. Inside `handle_auth` that meant the paused-request wait tore
Fetch back down, so `Fetch.continueRequest` failed with
`-32000 Fetch domain is not enabled` and every live basic-auth challenge ended
as `net::ERR_INVALID_AUTH_CREDENTIALS`.

- [x] Red-green: the live `spec/browser_handle_auth_parity_spec.cr` challenge
      flow (server returns 401 + `WWW-Authenticate`, credentials must come back
      as `a:b`) failed with that CDP error before the fix and passes now — the
      initial attempt was misread as a fixture bug and reverted in Phase 42.
- [x] `spec/browser_each_event_parity_spec.cr`: a `wait_event_typed` on a domain
      the caller already enabled must issue neither `Domain.enable` nor
      `Domain.disable` (red: both were sent).
- [x] `src/rod/browser.cr`: `wait_event_typed` consults
      `StateKey(browser_context, session, "<Domain>.enable")` and only enables
      and restores when the domain was off, matching go's `EnableDomain`.
- [x] The live auth example awaits its `handle_auth` fiber before releasing the
      page (`done.receive`), so the pooled browser never goes back with Fetch
      still enabled and later examples' navigations do not stall.
- [x] `spec/live_browser_pool_spec.cr` compares the launch count *after* the
      first borrow instead of `launches_before + 1`: the old form only passed
      when the pool happened to be cold, and failed with `Expected: 8 got: 7`
      (zero new launches, i.e. the sharing it wants) once an earlier example had
      left a warm browser in the free list.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (685 examples, 0 failures), `make check-go-*` pass.

### Phase 44 — `LoadState` copies params, full-page shots restore the browser viewport ✅

`Page#screenshot(full_page: true)` restored the viewport from a page-local
`@viewport_state` that only `Page#set_viewport` wrote. go keeps the params in the
browser state map instead (`oldView := proto.EmulationSetDeviceMetricsOverride{};
set := p.LoadState(&oldView)`, `page.go:437-471`), so a viewport applied through
a raw CDP request is restored too. The port's `LoadState` could not do that: it
only reported presence, because filling a caller's struct through a method
argument loses the assignments (Crystal copies structs at call boundaries).

- [x] Red-green: `spec/live_browser_parity_spec.cr` applies a 700x500 viewport
      with a raw `Emulation.setDeviceMetricsOverride`, takes a full-page shot and
      expects `[innerWidth, innerHeight]` back (twice, so the restored viewport
      is stored again); it answered `[1280, 800]` — the pooled default device —
      before the fix.
- [x] `spec/state_management_spec.cr`: `load_state` copies the stored width,
      height, `deviceScaleFactor` and `mobile`, keeps the caller's values for
      params the payload does not carry, and answers `nil` when nothing is
      stored.
- [x] `spec/screenshot_spec.cr`: the stub page seeds the browser state map and
      asserts the restore request carries the stored params (the old code blindly
      sent `Emulation.clearDeviceMetricsOverride`).
- [x] `src/cdp/cdp.cr` + `src/pdlgen/gen/crystal_templates/root.ecr`:
      `Cdp::Request#apply_state` assigns one field per declared ivar, keyed by
      the field's `JSON::Field` key. The scan is wrapped in `{% verbatim %}`
      because the including type's instance vars are only registered after the
      `include` line. `spec/pdlgen_root_template_parity_spec.cr` pins the
      template and the generated file together.
- [x] **Intentional divergence**: go's `LoadState(sessionID, method) (has bool)`
      fills the caller's request via `reflect.Value.Set` (`states.go:43-52`).
      Crystal cannot, so `Browser#load_state(session_id, req) : T?` returns the
      loaded request and `nil` means "no state" (go's `has`); `Page#load_state`
      delegates. Recorded in the ledger notes.
- [x] `Browser#wait_download` reads the previous behavior with `load_state` and
      re-applies that request, dropping the `saved_state` JSON workaround Phase 37
      needed (`browser.go:504-538`).
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (690 examples, 0 failures), `make check-go-*` pass.

---

### Phase 45 — element queries run go's shared `lib/js` helpers ✅

`Element#element`/`#element_x`/`#element_r`/`#elements`/`#elements_x` hand-wrote
their own scripts (`this.querySelector(...)`, `document.evaluate(...)`,
`new RegExp(regex)`), while go routes the same calls through `evalHelper` and the
shared helpers (`query.go:487-499`). The drift was behavioural, not cosmetic:
`js.ElementR` parses its regex argument like a JavaScript literal
(`vendor/rod/lib/js/helper.go:40-44`), so `element_r("span", "/hello/i")` builds
`new RegExp("hello", "i")` in go, while the hand-written path handed the raw
string to `new RegExp(...)` and matched nothing.

- [x] Red-green: `spec/element_regex_query_parity_spec.cr` drives a live page and
      expects `/hello/i` and `/GOODBYE/i` to match case-insensitively, plain
      patterns to stay case sensitive, and the search to stay scoped to the
      receiver. The flag example answered `ElementNotFoundError` before the fix.
- [x] `src/rod/element.cr`: the five element-scoped queries now call
      `@page.eval_helper(Rod::JS::ELEMENT | ELEMENT_X | ELEMENT_R | ELEMENTS |
      ELEMENTS_X, ...)`, and `elements`/`elements_x` go through the element's own
      `elements_by_js` (go's `el.ElementsByJS` → `el.page.Context(el.ctx)`).
      `spec/element_spec.cr` now asserts the helper function is the first JS
      argument instead of a pinned script string.
- [x] Ledger: the five `query.go::method::Element.*` rows name the helper they
      run; `Element.ElementR` also points at the new live spec.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (693 examples, 0 failures), `make check-go-*` pass.

---

### Phase 46 — `Element#frame` keeps the page's panic handler ✅

go's `Element.Frame` clones the page by struct assignment (`clone := *el.page`,
`element.go:458-471`), then replaces only the frame id, the JS context id, the
element and the sleeper — so the iframe page keeps the page's panic function
(`e`). The port built a fresh `Page`, so `frame.must_*` raised without ever
calling the handler the page had installed (`must.go:34-40`).

- [x] Red-green: `spec/element_frame_panic_parity_spec.cr` installs a handler on
      the page, takes the frame of a stubbed iframe element and expects a failing
      `must_element` on the frame to reach that handler. It counted 0 calls
      before the fix and 1 after.
- [x] `src/rod/element.cr`: `Element#frame` copies `@page.e_handler` onto the
      clone. `src/rod/page.cr` gained the protected `e_handler` reader next to
      the writer `with_panic`/`set_panic_handler` already used.
- [x] Frame clone fields re-audited against go: frame id, element, element
      sleeper, page ctx and panic handler all match; a fresh JS context is kept
      (`element.go:466`). go's struct copy additionally shares the `helpers`
      cache, `sessionCancel` and the event hub — left as-is because no ported
      behaviour depends on the sharing; re-open if one does.
- [x] Ledger: `element.go::method::Element.Frame` records what the clone
      inherits.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (694 examples, 0 failures), `make check-go-*` pass.

---

### Phase 47 — `Element#parents` walks the receiver's ancestors again ✅

`Element#parents` was reported `ported` but did not work: it hand-wrote the walk
and ran it straight on the page (`@page.elements_by_js(opts)`) without binding
`this` to the element, so in real use `this` was the global object, the walk
never started and the method answered an empty list. go calls
`el.ElementsByJS(evalHelper(js.Parents, selector))` (`query.go:516-518`) with a
**required** selector. The stub-only spec hid it by asserting the recorded
options of the page stub.

- [x] Red-green: `spec/element_parents_parity_spec.cr` drives a live page with
      nested `div`s and expects `leaf.parents("div")` → `["middle", "outer"]`,
      selector filtering, and no self-report. All three answered `[]`/`0` before
      the fix.
- [x] `src/rod/element.cr`: `parents(selector : String)` is now required and runs
      `elements_by_js(@page.eval_helper(Rod::JS::PARENTS, selector))`, which binds
      `this` and goes through the page context like go. The non-go optional
      `selector : String?` overload is gone (`must_parents` already required it).
- [x] `spec/element_spec.cr`: the stubbed spec asserts the `parents` helper is the
      first JS argument instead of the old pinned script.
- [x] Ledger: `query.go::method::Element.Parents` records the helper path and why
      the old script answered `[]`.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (697 examples, 0 failures), `make check-go-*` pass.

---

### Phase 48 — `Element#get_xpath` evaluates on the element again ✅

`Element#get_xpath` ran its helper on the page (`@page.evaluate(opts)`), while go
evaluates it on the element (`el.Evaluate(evalHelper(js.GetXPath, optimized))`,
`element.go:747-754`) and `Element.Evaluate` binds `this` to the element's remote
object (`element.go:733-735`). With `this` unbound the helper took the document
branch, so **every element answered `/`** — another ported-but-broken path whose
only coverage was a stub asserting the recorded options.

- [x] Red-green: `spec/element_xpath_parity_spec.cr` drives a live page and
      expects `/html/body/div/span` and, optimized, `//*[@id='leaf']`, plus
      scoping when a same-tag sibling is appended. All three answered `/` before
      the fix.
- [x] `src/rod/element.cr`: `get_xpath` calls the element's `evaluate(opts)`
      (i.e. `@page.context(@ctx).evaluate(opts.this(@object))`) instead of
      `@page.evaluate(opts)`.
- [x] `spec/element_spec.cr`: the stub page overrides `context` to keep capturing
      and the spec now asserts the element's remote object is `this`, so the
      regression is caught without a browser too.
- [x] Swept the remaining `@page.evaluate`/`@page.eval_helper` call sites in
      `element.cr`: every other one already goes through the element's
      `evaluate`/`wait`, which bind `this`; `dev_helpers.cr`'s mouse tracer is
      page-scoped by design.
- [x] Ledger: `element.go::method::Element.GetXPath` records the element-scoped
      evaluation and why the page-level call failed.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (700 examples, 0 failures), `make check-go-*` pass.

---

### Phase 49 — one quad-geometry implementation ✅

Quad geometry existed twice: `Rod::Util::Quad` (used by `Element#interactable`,
`#hover`, `#move_mouse_out`, `#screenshot`) re-implemented the shoelace area,
vertex average, first-quad-with-area and bounding box that the generated
`Cdp::DOM` helpers already carry as the port of go's `DOMQuad` patch methods
(`lib/proto/a_patch.go:70-120`). Phase 30 had to fix the same bug in both copies
when they drifted.

- [x] Characterization first: `spec/quad_util_equivalence_spec.cr` pins the util
      module against the generated helpers over whole-number, sub-pixel,
      counter-clockwise, go-fixture, degenerate and sliver quads, plus the
      multi-quad box and "first quad with area >= 1" rules. It passed before the
      change — the two copies agree today — so this phase is a refactor plus a
      guard, not a bug fix (unlike Phases 47/48).
- [x] `src/rod/util/quad.cr` now delegates `len`/`each`/`center`/`area`/
      `one_point_inside`/`box` to `::Cdp::DOM` (the `::` prefix is required:
      inside `Rod::Util`, bare `Cdp` does not resolve to the top-level module) and
      only adapts the result types to `Rod::Point`/tuples.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (704 examples, 0 failures), `make check-go-*` pass.

---

### Phase 50 — generation no-op gate ✅

`docs/generation.md` claims a regeneration of the pinned vintage is byte-for-byte
reproducible, but nothing enforced it: the claim was last checked by hand, and
Phase 30 had to edit a template *and* its generated file together.

- [x] Verified the claim: `make generate-crystal CDP_CHROMIUM=160.0.8168.1
      CDP_V8=16.0.61` on a clean tree leaves `git status --short src/cdp` empty
      (all 154 generated `.cr` files reproduce exactly).
- [x] `scripts/check_generate_crystal.sh` + `make check-generate-crystal`:
      regenerate the pinned vintage into `temp/cdp_generated/`, format it like
      `make generate-crystal` does, and `diff -r` it against `src/cdp` (ignoring
      `._*`/`.DS_Store` sidecars). Red-green: a planted hand edit in
      `src/cdp/cdp.cr` failed the gate naming that file; the clean tree passes.
- [x] `docs/generation.md` documents the gate and its network requirement.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (704 examples, 0 failures), `make check-go-*` pass.

### Phase 51 — `ScrollIntoView` waits for the root repaint ✅

The `query.go` lead (candidate e) came back clean, but the element it returns for
an iframe hit is a JS-context clone, and that clone exposed two older drifts:

- `Element#scroll_into_view` was defined **twice** in `src/rod/element.cr`. The
  later, JS-only definition (`this.scrollIntoView({behavior: 'instant', ...})`)
  silently replaced the faithful one, so go's repaint wait, the
  `DOM.scrollIntoViewIfNeeded` call and the trace/slow-motion hooks never ran.
  The existing `#scroll_into_view` spec passed vacuously because its stub element
  overrode the string `evaluate` overload the JS version used.
- `Page#wait_repaint` evaluated the `requestAnimationFrame` promise on the frame
  itself. go evaluates it on `p.root` with the comment "iframe doesn't trigger
  requestAnimationFrame" (`page.go:849-853`), and the port re-derived the root by
  walking `@element` — which answers the page itself for a JS-context clone, so
  `WaitStableRAF` on an element found by `Page#search` inside an iframe blocked
  forever on a throttled frame (measured: `setTimeout` resolved, `rAF` did not).

- [x] Red-green, live: the ported `TestSearchIframes`/`TestSearchIframesAfterReload`
      and `TestIframes` examples hung (>2 min, aborted) once `ScrollIntoView`
      waited for a repaint; they pass in 0.8 s / 0.4 s now.
- [x] Red-green, unit: `spec/element_spec.cr` asserts the CDP sequence
      (`DOM.getContentQuads` then `DOM.scrollIntoViewIfNeeded` with the element
      object id) — the vacuous version let the JS scroll through its stub.
- [x] `spec/element_spec.cr` `#focus/#blur`: both run as user gestures
      (`EvalOptions#user_gesture?`), like go's `Eval(...).ByUser()`.
- [x] `spec/page_misc_parity_spec.cr`: `wait_repaint` evaluates on the root page,
      and `root_page` survives `context`/`dup` clones.
- [x] `src/rod/page.cr`: `Page#root` follows go — set to the page itself in
      `Browser#page_from_target`/`#page_from_session`, inherited by
      `Element#frame` and by every `dup`/`context` clone; `root_page` reads it.
      `src/rod/dev_helpers.cr` had a private `root_page` walking only one level;
      it is gone, so trace overlays draw on the real root
      (`dev_helpers.go:114-124`).
- [x] `src/rod/element.cr`: duplicate `scroll_into_view` removed, the remaining
      one waits `wait_stable_raf` then calls `DOM.scrollIntoViewIfNeeded`;
      `focus`/`blur` pass `user_gesture: true`.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (708 examples, 0 failures), `make check-go-*` pass.

---

### Phase 52 — dev-helper trace overlays are drawn and removed ✅

Auditing `dev_helpers.go` (candidate h) showed `ExposeHelpers` matches go but the
trace overlays did not: `Page#overlay` and `Element#overlay` returned an empty
proc ("avoid teardown eval"), and `try_trace_req` never drew its overlay at all.
go returns a remove function that evaluates `js.RemoveOverlay` with the same id
(`dev_helpers.go:114-131`, `198-211`) and its tracer goroutine removes the
wait-requests overlay when the page context ends (`dev_helpers.go:157-195`), so
the port leaked one overlay div per traced operation, plus `elementOverlay`'s
100 ms reposition timer (which keeps firing against the stale div).

- [x] Red-green: `spec/dev_helpers_parity_spec.cr` asserts the draw and remove
      evals for `Page#overlay` (on `root_page`), `Element#overlay` (on the
      element) and `try_trace_req` (draw for includes/excludes, remove after the
      page context is cancelled). All three failed before the fix: the remove
      evals did not exist and `try_trace_req` drew nothing.
- [x] `src/rod/dev_helpers.cr`: both overlays now return `-> { remove_overlay(id) }`,
      a best-effort `js.removeOverlay` eval like go's `_, _ =`; `try_trace_req`
      draws with the includes/excludes payload and its fiber selects on
      `@ctx.done.receive?` (a closed channel is immediately ready in Go but
      raises in Crystal) to remove it.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (711 examples, 0 failures), `make check-go-*` pass.

---

### Phase 53 — `Page#expose` listens for its binding ✅

Candidate (g) (`page_eval.go`) is mostly equal, but its ledger row for
`TestPageExpose` cited only stub specs of the *error* paths. Porting the upstream
*live* test found a broken feature: `expose` builds `each_event`'s **wait**
function and only called it inside `stop`, so nothing listened for
`Runtime.bindingCalled`. Calling an exposed function hung until the context
deadline (the JS promise never resolved) and `stop` blocked forever in the
listener loop. go starts it with `go p.EachEvent(...)` (`page_eval.go:214`).

- [x] Red-green, live: `spec/live_browser_parity_spec.cr` ports `TestPageExpose`
      — expose a function, call it twice concurrently after a reload, then
      `stop()` (a second `stop()` must fail) and reload so the function is
      unbound. It hung (>3 min, aborted) before the fix and passes in ~0.6 s now.
- [x] Red-green, stub: `spec/page_eval_parity_spec.cr` asserts `must_expose`
      exists with expose's function shape. It did not compile before the fix:
      `must_expose` declared `Proc(JSON::Any, JSON::Any)` but handed it to
      `expose`, and `Rod::Page`'s `method_missing` reported the overload mismatch
      as `undefined method 'must_expose'`.
- [x] `src/rod/page.cr`: the listener runs in a fiber on the expose context and
      is torn down by cancelling that context; `stop` follows go's order (remove
      the new-document script, `Runtime.removeBinding`, then `cancel`); the
      callback eval runs on the expose context like go's `p.Evaluate`; `expose`
      accepts a nil function like go's `Expose(name, nil)`.
- [x] `src/rod/must.cr`: `must_expose` takes expose's tuple-returning proc and a
      nilable one, wrapping `stop` errors through the panic hook like go's
      `p.e(s())` (`must.go:479-484`).
- [x] Spec hygiene: `make test` runs `crystal spec spec` with
      `CRYSTAL_CACHE_DIR` pinned to the git-ignored `.crystal-cache/`, so a
      concurrent run from another checkout cannot make this repo execute that
      checkout's example list (it happened once: `../dataframe/spec/...`).
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (715 examples, 0 failures), `make check-go-*` pass.

---

### Phase 54 — `ScrollScreenshot` capture flags match go's `omitempty` ✅

The Phase 53 gate run failed `TestScrollScreenshot` with
`-32000 Unable to capture screenshot`, deterministically (HEAD failed too, so it
was not the change under test). go's own `TestScrollScreenshot` passed on the
same machine, so the requests differed: the port sent `"fromSurface": false`
with a `clip`, and go does not — its proto field is
`FromSurface bool` with `json:"fromSurface,omitempty"`
(`vendor/rod/lib/proto/page.go:1745-1746`), so the `FromSurface: false` literal in
`ScrollScreenshot` is dropped and CDP keeps its documented default (`true`).
Chrome rejects `fromSurface: false` for clipped captures.

- [x] Red-green: `spec/screenshot_spec.cr` captures the `Page.captureScreenshot`
      payload and asserts `fromSurface`/`captureBeyondViewport`/`optimizeForSpeed`
      are absent (the first two failed before the fix); the live
      `TestScrollScreenshot` example went from a deterministic
      `-32000 Unable to capture screenshot` to passing in ~6 s.
- [x] `src/rod/page.cr`: the scroll loop builds the request with format, quality
      and clip only, exactly what go puts on the wire.
- [x] The same commit pins `CRYSTAL_CACHE_DIR` to the git-ignored
      `.crystal-cache/` and runs `make test` as `crystal spec spec`, so a
      concurrent run from another checkout cannot make this repo execute that
      checkout's examples (it did once: `../dataframe/spec/...`).
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (715 examples, 0 failures), `make check-go-*` pass.

---

### Phase 55 — Eval requests omit false flags like go's `omitempty` ✅

Same class as Phase 54, one request further: go's `RuntimeCallFunctionOn` fields
are `bool` with `json:",omitempty"` (`vendor/rod/lib/proto/runtime.go`), so
`ReturnByValue: false` / `AwaitPromise: false` / `UserGesture: false` never reach
the wire. `Page#evaluate_internal` mapped `EvalOptions`' plain `Bool`s straight
into the `Bool?` proto fields, so the port always sent all three — including in
the helper-registration requests, where go sends nothing.

- [x] Red-green `spec/eval_request_payload_parity_spec.cr` (new): captures the
      `Runtime.callFunctionOn` payload from `Page#evaluate` and asserts the three
      false flags are absent while `returnByValue: true` is present (red: all
      three present as `false`), plus the inverse case (all three `true` when the
      options ask for them; red: `returnByValue` present as `false`).
- [x] `src/rod/page.cr`: `evaluate_internal` passes `nil` for false options, and
      the three helper-building requests (`() => window`, `functions`, per-helper
      factory) stop sending explicit `false`.
- [x] This closes the last CDP-default lead from Phase 54: only four proto fields
      document "Defaults to true", and `src/rod` constructs none of them with an
      explicit `false` (verified: `fromSurface` was the only one, fixed in 54).
      Phase 55 also closed the `browser.go` lead (`Page`/`Pages` close-on-error
      and ordering match) and the devices table (`lib/devices/list.go`, all 36
      entries byte-equal to `src/rod/util/devices.cr`).
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (717 examples, 0 failures), `make check-go-*` pass.

---

### Phase 56 — Element operations run in the element's context ✅

go-rod re-contexts the page for element operations:
`el.page.Context(el.ctx)` appears **15 times** in `element.go` (lines 88-734) —
`Mouse.MoveTo`/`Click`, `Touch.Tap`, `Keyboard.Type`, `KeyActions`, `InsertText`,
`ElementFromPoint`, `ElementFromObject`, `WaitRepaint`, `Wait`, `GetResource` ×2,
`Screenshot`, `Release`, `Evaluate`. The port already re-contexted 7 of them
(interactable's `element_from_point`, `wait`, `wait_repaint`, `resource`,
`background_image`, `release`, `element_from_object`), but **8 still went straight
to `@page`**: `click`, `hover`, `tap`, `type`, `key_actions`, `input`'s
`insert_text`, `screenshot` and `evaluate`. An element cloned by
`Element#timeout`/`Element#context` therefore ignored its own deadline for every
input action, screenshot and JS evaluation.

- [x] Red-green `spec/element_context_parity_spec.cr` (new): a recording page
      stub plus a spy mouse/keyboard/touch, and an element stub with
      `scroll_into_view`/`wait_*`/`shape` faked, asserts every one of the eight
      paths runs with the *element's* context (six examples: evaluate, click +
      hover, type + key actions, tap, input, screenshot). All six failed before
      the fix; the screenshot case drives a cancelled element context and
      expects `ContextCanceledError`.
- [x] `src/rod/element.cr`: the eight call sites now use `@page.context(@ctx)`,
      matching go's pattern. `move_mouse_out` deliberately stays on `@page` —
      go's `MoveMouseOut` is the one site that does *not* re-context
      (`element.go:656-664`).
- [x] `spec/element_spec.cr`: `ScreenshotStubPage` records its calls through a
      shared array, because `Page#context(ctx)` dups the page and an `Int32`
      counter would be lost on the clone.
- [x] Note on the cached input objects: go's `Page.Mouse`/`Keyboard`/`Touch` are
      lazily created (`newMouse()`), so a cloned page that has not built them yet
      binds them to the clone — the port's `@mouse ||=` behaves identically.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (723 examples, 0 failures), `make check-go-*` pass.

---

### Phase 57 — Event waits restore domains through `EnableDomain` ✅

go's `eachEvent` enables the callback's domains through `Browser.EnableDomain`
(`browser.go:364-371`), which consults the state registry (`states.go:60-73`): if
the domain is already enabled it sends nothing, and its restore function is a
no-op. The port called `*.enable`/`*.disable` directly, so a wait that ended
**disabled a domain someone else had enabled** — e.g. `page.enable_domain(Network)`
followed by `wait_request_idle` left `Network` off, silently killing network
events for every later wait.

- [x] Red-green `spec/each_event_domain_parity_spec.cr` (new):
      `Browser#enable_domain(Network)` (restore still held) then an `each_event`
      wait on `Network` events with an already-cancelled context, so its restores
      run inside the example. Red before the fix:
      `["Network.enable", "Network.disable"]` recorded; green now: neither. A
      second example pins the normal path (nobody else enabled it → both calls
      happen).
- [x] `src/rod/browser.cr`: new `Browser#enable_domain_by_name(session_id,
      method_name, params)` holds the state-aware enable/restore logic and
      `#enable_domain` delegates to it. `each_event` uses it, and
      `wait_event_typed` drops its own copy of the same logic (Phase 35 had fixed
      `WaitEvent` inline; both now share one primitive).
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (725 examples, 0 failures), `make check-go-*` pass.

---

### Phase 58 — Page domain enablement goes through `EnableDomain` ✅

Two more sites of the Phase 57 class, both in `page.go`:

- `Page.SetExtraHeaders` returns `p.EnableDomain(&proto.NetworkEnable{})` as its
  cleanup (`page.go:139-147`).
- `Page.HandleDialog` keeps the restore from `p.EnableDomain(&proto.PageEnable{})`
  and calls it when the dialog is handled (`page.go:613-631`).

The port called `Network.enable`/`Network.disable` and `Page.enable`/`Page.disable`
unconditionally, so both turned the domain off for whoever had enabled it before
(e.g. `page.enable_domain(Network)` followed by `set_extra_headers` killed network
events, and a dialog handled while someone held the Page domain disabled it).

- [x] Red-green `spec/page_extra_headers_domain_parity_spec.cr` (new): a
      recording client shows `["Network.enable", "Network.setExtraHTTPHeaders",
      "Network.disable"]` before the fix and only
      `Network.setExtraHTTPHeaders` after it when the domain was already on;
      `["Page.enable", "Page.handleJavaScriptDialog", "Page.disable"]` versus
      only `Page.handleJavaScriptDialog` for `handle_dialog`. Two companion
      examples pin the normal path (nobody else enabled it → enable and disable).
- [x] `src/rod/page.cr`: both methods use `Page#enable_domain` (which is
      `browser.context(@ctx).enable_domain(@session_id, ...)`, like
      `Page.EnableDomain` in `states.go:108-110`) and return/call its restore.
- [x] `spec/page_wait_parity_spec.cr`: `DialogStubBrowser` records through the
      page's list, because the enable now goes through the browser (as in go).
      `HijackRouter#stop` is *not* in this class — go's `Stop` calls
      `FetchDisable` unconditionally (`hijack.go:189-192`), so the port matches.
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (729 examples, 0 failures), `make check-go-*` pass.

---

### Phase 59 — Input events use go's `js.InputEvent` helper as a user gesture ✅

`Element.Input` ends with `_, _ = el.Evaluate(evalHelper(js.InputEvent).ByUser())`
(`element.go:278`). The port hand-wrote the same two `dispatchEvent` calls inline
and *without* `.by_user`, so the `input`/`change` events were dispatched outside a
user gesture and the shared helper (byte-identical in `src/rod/util/js.cr` since
Phase 39) was never reused.

- [x] Red-green `spec/element_input_parity_spec.cr` (new): a page stub records the
      `EvalOptions` of the dispatch; red before the fix
      (`user_gesture? == false`, no `inputEvent` helper argument), green after.
- [x] `src/rod/element.cr`: the dispatch is
      `evaluate(@page.eval_helper(Rod::JS::INPUT_EVENT).by_user)`, still wrapped in
      the `rescue` that mirrors go's `_, _ =`.
- [x] `spec/element_spec.cr`: the two `#input` examples now assert the recorded
      dispatch options (helper name + user gesture) instead of matching the
      hand-written JavaScript text, which also stops them passing when the
      dispatch silently fails.
- [x] Ported upstream `TestSetDocumentContent` as
      `spec/page_document_content_parity_spec.cr`: it was already green (Chrome
      does the work), so it is a characterization guard for the document-swap
      path rather than a bug fix — recorded here so the next session does not
      mistake it for an untested area.
- [x] Closed the last Phase 2 bullet: `Page.cleanupStates` (see the Phase 2
      checklist) is a no-op upstream, so the ledger row is now
      `intentional_divergence` (inventory: 11 documented divergences).
- [x] Gates: `make format`, `make lint` (240 files), full `make test`
      (731 examples, 0 failures), `make check-go-*` pass.

---

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
