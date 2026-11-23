# Resuming Work

This is the first thing to read in a new session. It takes a few minutes to get
back to a known-good state.

## 1. Read where we are

- `plans/parity.md` — start at the **Where we are** block. It names the current
  focus, the ordered "Next up" list, per-phase status, and the last commit and
  gate results. Do not re-derive state from git history. The ledger is fully
  `ported`, so when Next up is down to tooling/verification items, take the next
  parity phase from Next up item 1 ("audit queue"): pick an unswept area, diff it
  against `vendor/rod`, and land one red-green commit.
- `plans/inventory/go_port_inventory.tsv` — the per-symbol ledger (status +
  `crystal_refs`). Use it to see what is left inside the current chunk:

  ```bash
  tail -n +2 plans/inventory/go_port_inventory.tsv | cut -f3 | sort | uniq -c
  ```

- `plans/inventory/go_false_positive_notes.md` — Go↔Crystal naming notes for
  items discovery reports but the port already covers under another name.

## 2. Confirm the working tree

```bash
git log --oneline -10
git status
```

The last commit should be the previous feature (`port: ...`), committed
atomically. If the tree is dirty, finish or stash before starting.

## 3. Confirm a clean baseline

```bash
make lint
make test
```

Both must pass before changing anything. When parity manifests changed, also
run:

```bash
make check-go-port-inventory
make check-go-source-parity
make check-go-test-parity
```

These run tree-sitter discovery through the installed
`cross-language-crystal-parity` skill's Chiasmus toolchain (the `Makefile` pins
`PORT_PARSER=tree-sitter`, and `scripts/*.sh` forward to the skill). A first run
on a cold cache downloads the verified toolchain; a tree-sitter failure must be
fixed, never bypassed with `PORT_PARSER=regex`.

## 4. Pick the next feature

Take the first unchecked item in the **Next up** list (or the next `[ ]` item in
the current phase). For each feature:

1. Read the upstream source under `vendor/rod` and the nearest upstream tests.
2. Port the tests first (red → green); never weaken assertions.
3. Satisfy the **Definition of done** in `AGENTS.md` (API, tests, gates,
   inventory rows, `plans/parity.md` status + **Where we are** refresh,
   divergences).
4. Commit atomically with the `port: ...` message format from `AGENTS.md`.

## If the plan is split

When `plans/parity.md` grows too large it is split into `plans/<area>.md` files.
In that case every split file is linked from `plans/parity.md`, and
`plans/parity.md` marks each file complete/in-progress and names the file being
worked on plus the next file/phase to start.

## Environment notes

- Upstream is pinned at `vendor/rod` commit `d38c753`; upstream has no release
  tags.
- Parity discovery is tree-sitter, pinned with `PORT_PARSER=tree-sitter` in the
  `Makefile` and run through the installed `cross-language-crystal-parity`
  skill's verified Chiasmus toolchain. `scripts/*.sh` forward to that skill (no
  copied implementation); set `PARITY_SKILL_DIR` if the install moves. The
  curated ledger is never regenerated in place — see AGENTS.md > Parity tooling.
- Live specs borrow one pooled Chrome (`spec/support/live_browser_pool.cr`), so
  `make test` launches a handful of browsers instead of one per example and
  removes their profiles on exit. `ROD_POOL_STATS=1 make test` prints the launch
  count; `ROD_CHROME_BIN` overrides the Chrome path. No spec may hide behind
  `ROD_REAL_BROWSER` (`spec/live_spec_gating_parity_spec.cr` enforces that).
- Crystal caches belong in `.crystal-cache/` (git-ignored):

  ```bash
  CRYSTAL_CACHE_DIR=$PWD/.crystal-cache crystal run \
    examples/compare-chromedp/download_file/main.cr -- \
    -rod "bin=/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  ```

- Use `./temp` for scratch files; `make clean` empties it.
