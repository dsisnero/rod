# Rod Crystal

> **How to resume:** read `plans/parity.md` first and use its **Where we are**
> block (current focus + ordered "Next up"), then run `make lint` and
> `make test`. Details: [docs/resuming.md](docs/resuming.md). Do not re-derive
> state from git history.

Crystal port of [go-rod/rod](https://github.com/go-rod/rod) (Go), a high-level
browser automation library, vendored at `vendor/rod` (commit `d38c753`; upstream
has no release tags). The upstream Go code is the source of truth: all logic
must match Go, differing only in Crystal idioms and libraries.

## Commands

```bash
make install   # shards install
make update    # shards update
make format    # crystal tool format --check src spec examples bin
make lint      # ameba --fix, then ameba
make test      # crystal spec
make check-examples  # compile every example (they are not part of `make test`)
make clean     # rm -rf ./temp/*
```

Parity gates (manifests in `plans/inventory/`):

```bash
make check-go-port-inventory
make check-go-source-parity
make check-go-test-parity
```

Specs that drive a real browser borrow one pooled Chrome
(`spec/support/live_browser_pool.cr`, go-rod's `testerPool`), so `make test`
launches a handful of browsers rather than one per example. Use
`ROD_POOL_STATS=1 make test` to see the launch count, `ROD_CHROME_BIN` to point at
a different Chrome, and `RodSpec.with_isolated_browser` for examples that change
browser-wide state or kill the browser. No spec may hide behind an env flag
(`spec/live_spec_gating_parity_spec.cr`). Details:
[docs/testing.md](docs/testing.md).

CDP bindings are generated, not hand-written: `make generate` (Crystal
`pdlgen`). See [docs/generation.md](docs/generation.md).

## Docs

- [Resuming work](docs/resuming.md)
- [Architecture](docs/architecture.md)
- [Development](docs/development.md)
- [Coding Guidelines](docs/coding-guidelines.md)
- [Testing](docs/testing.md)
- [CDP generation](docs/generation.md)
- [PR Workflow](docs/pr-workflow.md)
- [Changelog](CHANGELOG.md)

> Parity status, next work and known gotchas live in
> [plans/parity.md](plans/parity.md).

## Principles

1. Upstream behavior is the source of truth; `vendor/rod` wins over local
   preference.
2. Port behavior, not style. Use Crystal idioms only after behavioral
   equivalence is verified.
3. Port upstream tests early and never weaken assertions to make Crystal green.
4. Track parity in `plans/parity.md` and `plans/inventory/`.
5. Commit one completed feature at a time.

## Work tracking

There is no external issue tracker. `plans/parity.md` is the work queue:
its **Where we are** block holds the current focus and the ordered "Next up"
list, and per-symbol port status lives in
`plans/inventory/go_port_inventory.tsv`.

- Add follow-up work to **Next up** as you discover it, instead of silently
  widening scope.
- Do not create ledger rows for Go-only tooling as `ported`; use
  `intentional_divergence` or `skipped` with a note.
- Keep `plans/inventory/go_port_inventory.tsv` curated; regenerate the
  `go_source_parity.tsv` / `go_test_parity.tsv` snapshots freely.

### Parity tooling

- Parser mode for the curated ledger: **`regex`** (`PORT_PARSER=regex`). It is
  the authoritative gate; `tree-sitter` is an exploratory overlay only.
- Inventory command: `make check-go-port-inventory` (plus `make
  check-go-source-parity` / `make check-go-test-parity`).
- The repo's `scripts/` are copied from the installed
  `cross-language-crystal-parity` skill (currently
  `/Users/dominic/.config/opencode/skills/cross-language-crystal-parity`) and
  have drifted: their `tree-sitter` branch is a placeholder that still calls
  `discover_with_regex`, so `PORT_PARSER=tree-sitter` warns and exits 0 without
  ever using tree-sitter. Do not report that gate as blocked, and do not install
  the Ruby `tree_sitter` gem expecting a different result.
- A real tree-sitter backend needs the skill's verified Chiasmus toolchain
  (`verify_skill_install.sh . go tree-sitter`) *and* a reviewed id migration,
  because native labels (`class`/`function`/`definition.*`, plus merged
  `const`/`type` declarations) do not match the curated vocabulary. See Phase 1
  in `plans/parity.md` before touching either.

## Session continuity (read this first)

`plans/parity.md` is the single source of truth for where we are. At the start
of every session:

1. Read `plans/parity.md` and use its **Where we are** block to find the current
   focus, the ordered "Next up" list, and per-phase status.
2. Skim `git log --oneline -10` and `git status` to confirm the working tree.
3. Run `make lint` and `make test` before changes to confirm a clean baseline.

See [docs/resuming.md](docs/resuming.md) for the full resume checklist.

### Keeping `plans/parity.md` resumable

- `plans/parity.md` starts with a **Where we are** block (`Current focus`,
  `Next up`, last commit, gate results). Keep it accurate after every feature.
- Work items are feature-sized (roughly one branch/commit). Per-symbol state
  lives in `plans/inventory/go_port_inventory.tsv`, not in the plan.
- If `plans/parity.md` grows too large, split it into `plans/<area>.md` files,
  link each from `plans/parity.md`, and mark each split file
  complete/in-progress plus the file being worked on next.

### Definition of done for every feature (required)

A feature is complete only when all of the following are true, and all of it
must be committed as **one** atomic commit before starting the next feature:

1. the API surface is implemented and behavior matches `vendor/rod`;
2. upstream tests (or equivalent characterization specs) exist and pass;
3. gates pass: `make format`, `make lint`, `make test`;
4. relevant parity rows are updated in `plans/inventory/go_port_inventory.tsv`
   and the parity checks (`make check-go-*`) pass;
5. `plans/parity.md` status is updated and the **Where we are** block refreshed
   (current focus + next up);
6. any intentional divergence is documented (in `plans/parity.md` and/or the
   commit message).

### Commit message

Start with `port:` and a one-line feature name, then bullets for what changed
(files, divergences, spec coverage), then the gate results and the upstream
revision (`go-rod/rod d38c753`). Keep one feature per commit so a new session
can resume from the commit alone.

## File system guidelines

- Use `./temp` for temporary files created during testing or development; it is
  git-ignored and `make clean` empties it.
- Never commit temporary files, generated binaries, or `.crystal-cache/`.

## Landing the plane (session completion)

When ending a work session, complete ALL steps below. Work is NOT complete until
`git push` succeeds.

1. **Record remaining work** — leave the follow-ups in `plans/parity.md`'s
   **Next up** list so nothing depends on memory.
2. **Run quality gates** (if code changed) — `make format`, `make lint`,
   `make test`, plus the parity checks under `make check-go-*`.
3. **Update the plan** — tick finished items in `plans/parity.md` and refresh
   the **Where we are** block.
4. **Push to remote** — mandatory:

   ```bash
   git pull --rebase
   git push
   git status  # MUST show "up to date with origin"
   ```

5. **Clean up** — clear stashes, prune remote branches, empty `./temp`.
6. **Verify** — all changes committed AND pushed.
7. **Hand off** — leave `plans/parity.md`'s **Where we are** block current so
   the next session can resume from it.

Never stop before pushing, and never leave the hand-off as "ready to push" —
push it.
