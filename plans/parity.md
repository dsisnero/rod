# Go → Crystal Parity Plan

**Source of truth**: `vendor/rod` (go-rod) at `d38c753`
**Target**: Crystal port under `src/`, specs under `spec/`
**Language**: `go` · **Manifests**: `plans/inventory/go_*`
**Last evaluated**: 2026-11-17

## Where we are

**Current focus:** Phase 5 — refresh the generated `go_source_parity.tsv` /
`go_test_parity.tsv` snapshots and run the adversarial signoff pass. Phase 4
(dev-tooling divergence sign-off) is done: `lib/docker/*` and
`lib/proto/generate/*` are recorded as `intentional_divergence`, and the CDP
generation path was exercised end to end. Phase 1 (tree-sitter kind
normalization) remains blocked on tooling outside this repo, so
`PORT_PARSER=regex` stays the authoritative parity gate.

**Last commit:** `port: sign off dev-tooling divergence and harden CDP generation`

**Gates (baseline, 2026-11-17):** `make format` pass · `make lint` pass (233
files) · `make test` pass (579 examples, 0 failures) · parity checks pass (5665
inventory rows with 10 documented divergences, 5368 API items, 297 tests).

**Next up:**

1. Phase 5 — refresh the `go_source_parity.tsv` / `go_test_parity.tsv`
   snapshots with `ensure_parity_plan.sh . vendor/rod go regex 1`; never
   regenerate `go_port_inventory.tsv` in place. **Careful:** the refresh
   rewrites source-parity notes from `plans/inventory/go_source_notes.tsv`,
   which does not exist — a refresh would replace the curated per-row notes
   with `baseline`. Recreate the notes overrides file first (or teach
   `generate_source_parity_manifest.rb` to preserve existing notes).
2. Phase 5 — adversarial pass:
   `verify_parity_adversarial.sh . vendor/rod go 'crystal spec' '<go test cmd>'`.
3. Phase 1 — (blocked) re-run the tree-sitter checks once kinds/ids are
   normalized.
4. Tame full-suite browser flakiness: two consecutive full runs on 2026-11-17
   each had one failure, different specs, both green in isolation —
   `spec/cdp_client_parity_spec.cr:483` (Go `TestCrash`) and
   `spec/live_browser_parity_spec.cr:747` (`TestSearchIframes*`). Likely
   resource/timing under load; a rerun should not be the only safety net.
5. CDP protocol upgrade (new, from Phase 4): teach the Crystal emitter the two
   constructs the current protocol uses — enum aliases must not be emitted twice
   with a dotted name (`alias Fetch.AuthChallengeSource`), and required
   constructor parameters must precede optional ones. Evidence and file/line
   references live in [docs/generation.md](generation.md). Then regenerate with
   `make generate-crystal CDP_CHROMIUM=<ver>`, re-apply the post-generation
   curation (camelCase keys, typed decoding) and run the CDP parity specs.
6. Optional cleanup: the repo tracks built binaries (`rod`, `bin/pdlgen*`,
   `pdlgen*`), so local builds keep showing up as modified files. Decide
   whether to untrack them.

**Gotchas:** the 63 tree-sitter "missing" items and the 3422 kind-rename
"stale" rows are tooling vocabulary drift, not port gaps — see below. Phase 2's
last checklist bullet (`states.go::method::Page.cleanupStates` ledger row) is
also waiting on that reconciliation. `make generate-crystal` is not
reproducible by default (`--latest`); pin `CDP_CHROMIUM`/`CDP_V8`.

This is a curated feature roadmap, not a generated dump. Generated manifests
(`go_source_parity.tsv`, `go_test_parity.tsv`) are reference snapshots;
`go_port_inventory.tsv` is the day-to-day ledger.

---

## Baseline

| Metric | Value |
|---|---|
| Port inventory rows | 5665 discovered + 10 documented divergences (5,655 `ported` + 10 `intentional_divergence`) |
| Source parity (regex backend) | 5368 API items, check PASS (authoritative) |
| Source parity (tree-sitter backend) | incompatible with curated manifests: 63 missing + 3422 stale (kind vocab mismatch) |
| Test parity | 297 tests tracked, check PASS |
| Crystal specs | 77 files, 579 examples, 0 failures (2026-11-17) |

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
      emitter gaps.
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

### Phase 5 — Continuous parity gates & adversarial signoff
- [ ] Refresh generated manifests after the vendor bump:
      `ensure_parity_plan.sh . vendor/rod go tree-sitter 1`.
- [ ] Run the adversarial pass:
      `verify_parity_adversarial.sh . vendor/rod go 'crystal spec' '<go test cmd>'`.
- [ ] Keep `go_port_inventory.tsv` curated; never regenerate it in place.

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
