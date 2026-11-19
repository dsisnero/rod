# Changelog

All notable changes to this project. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project aims to
follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Behavior is pinned to `go-rod/rod` at `vendor/rod` commit `d38c753`; entries
below describe the Crystal port, not upstream changes.

## [Unreleased]

### Added

- `spec/support/live_browser_pool.cr`: pooled live-browser harness
  (`RodSpec.with_live_browser`, `RodSpec.with_isolated_browser`), the Crystal
  port of go-rod's `testerPool`. It reuses one Chrome per concurrent example,
  blanks the page the next example inherits, closes the extra targets and browser
  contexts an example leaves behind, drops a browser whose reset fails, and
  shuts every browser down (removing its profile) on exit. `ROD_POOL_STATS=1`
  prints the launch count and `ROD_CHROME_BIN` overrides the Chrome path.
- `spec/live_spec_gating_parity_spec.cr`: invariant that no ported live example
  hides behind an env flag, so every ported check actually runs.
- `spec/page_stale_node_retry_parity_spec.cr`: pins the stale-document retry
  behavior for all three node-id error phrasings Chrome uses.
- `spec/launcher_parity_spec.cr`: launcher output contract coverage — the
  browser's stdout/stderr reach `Launcher#logger(io)` on both the direct and
  leakless paths, the launcher itself logs nothing, and a managed download's
  `bin_path` resolves inside the stripped archive layout.
- `CHANGELOG.md`, and docs for the pooled harness, launcher/manager lifecycle and
  shared JS-context state (`docs/testing.md`, `docs/architecture.md`,
  `docs/development.md`, `docs/resuming.md`).

### Changed

- `Rod::Context` now follows Go's `context.Context` deadline rules: `deadline`
  is inherited through the parent chain (`Context.Deadline`), and
  `with_timeout` keeps the parent's sooner deadline (`context.WithDeadline`), so
  a nested `Page#timeout`/`Browser#timeout`/`Element#timeout` can only shorten
  the budget. Previously a nested timeout could extend it, and contexts derived
  with `with_value` (which is what `Page#timeout` returns) reported no deadline,
  so `deadline_remaining`/`timeout_remaining` fell back to the caller's timeout.
- `Rod::Util::Launcher::Manager#logger` is now `Rod::Util::Utils::Log` (go-rod's
  `utils.Logger` shape) defaulting to `Utils.logger_quiet`, and the manager
  actually writes go-rod's four management lines: `Launch <url> <options>`,
  `Close <url>`, `Killed PID: <n>` and `Removed <dir>` (`manager.go:190-209`).
  The property previously held a Crystal `::Log` that was never used. Managed
  cleanup now runs once per connection and, like Go's `Manager.cleanup`, skips
  the profile removal *and* the exit wait when `--rod-keep-user-data-dir` is set.
- `Page#wait_stable` now waits on the page's request queue
  (`wait_request_idle(d)`, go `WaitRequestIdle(d, nil, nil, nil)`,
  `page.go:821`) instead of sleeping for `d`, so a page with slow background
  requests stays unstable until they finish, like go-rod.
- `Rod::Util::Launcher::Launcher` no longer logs the launch. go-rod's launcher
  logger is `io.Discard` (`launcher.go:120`) and only `Launcher.Logger(w)`
  fills it, so `rodney start`-style commands print just their own output.
  `Launcher#logger(io)` now actually forwards the browser's stdout and stderr
  (`io.MultiWriter(l.logger, l.parser)`, `launcher.go:514-515`) on both the
  direct and the leakless path; `Launcher#logger=(::Log)` — which had no
  upstream counterpart — was removed, so the workaround that silenced the old
  INFO line can be deleted.
- `Page#navigate` clears the *root* page's JavaScript execution-context cache
  (go `p.root.unsetJSCtxID()`, `page.go:188`) instead of the navigated page's, and
  that cache is now shared between page clones (`Page::JsCtxCache`), matching
  go-rod's `jsCtxID` pointer semantics (`page.go:70`). Iframe pages and
  iframe-context elements still get their own cache, like Go's `new(...)`.
- `Page#element` (and every lookup that uses `retry_finding`) keeps retrying a
  stale document root until the query deadline, and recognizes Chrome's
  `No node with given id found` phrasing. Previously that error escaped as
  `Element not found`, which made post-navigation lookups flaky.
- `Rod::Util::Launcher::Manager` now matches go-rod's manager lifecycle
  (`manager.go:181-207`): managed browsers are forced `leakless(true)`, killed on
  disconnect only when the caller asked for a managed (leakless) browser, and
  their `user-data-dir` is always removed. The port previously killed
  unconditionally and never removed the profile.
- Specs shut browsers down through the shared `shutdown_launcher` helper, which
  kills the process and then runs `Launcher#cleanup`; a full `make test` run no
  longer leaves profiles in `$TMPDIR/rod/user-data`.
- Every live spec file now runs on the pooled browser, including the calculator
  e2e example; `spec/live_browser_parity_spec.cr` went from 56 browser launches
  to 7, and the whole suite from ~3:20 to ~2:00.

### Fixed

- `Page#retry_finding` returns the context's error (deadline exceeded or
  cancelled) when the lookup runs out of context, instead of
  `NotFoundError "Element not found within ..."`. go-rod's `utils.Retry` surfaces
  the sleeper's `ctx.Err()`.
- The event hub (`Goob::Observable`/`Pipe`) no longer raises
  `Channel::ClosedError` when a subscriber's `done` channel closes during a
  publish. Go's `<-p.done` returns on a closed channel while Crystal's
  `Channel#receive` raises, and the raise escaped `Observable#publish` into
  `Browser#init_events`, whose rescue then stopped delivering browser events for
  the rest of the session.
- `IdleCounter#wait` no longer raises `Channel::ClosedError` when the context is
  cancelled while it is blocked in its select. `Rod::Context#cancel` closes the
  `done` channel, and Crystal raises on `receive` from a closed channel where
  Go's `<-ctx.Done()` just returns, so `wait_request_idle`/`wait_stable` fibers
  leaked `Unhandled exception in spawn: Channel is closed` to stderr on
  cancellation.
- `Browser#download` no longer leaves `bin_path` dangling after a managed
  download on an exFAT volume. There, `unzip` writes AppleDouble `._*` sidecars
  next to the extracted top-level folder, so the single-entry guard in
  `strip_first_dir` skipped the strip; it now ignores filesystem metadata when
  counting and moving entries. This is a host-environment shim: upstream
  `fetchup.StripFirstDir` is strict, and the behavior is unchanged on
  APFS/HFS+/Linux.
- `Rod::Util::Leakless::Launcher#command` left the browser's stdout on a pipe
  nobody read, which could block the browser once the pipe buffer filled; the
  launcher now wires both streams to the logger sink and the URL parser.
- Live specs leaked a Chrome process and a user-data profile per managed
  launcher and per example; both are cleaned up now.
- `TestPageIframeReload` no longer needs `ROD_REAL_BROWSER=1` and no longer fails
  intermittently on a stale document root.
- `Target.closeTarget` settling is polled in the harness instead of sampled
  once, removing a flake in the pooled-browser specs.

## [0.8.0]

### Added

- `must_*` wrappers and `!` aliases, plus `MaxSleepCountError#is?`.
- `try_trace` / `try_slow_motion` parity across page, element and input methods.
- Full CDP surface loaded from rod with accessibility parity coverage; generated
  bindings decode typed results.

### Changed

- CDP generator parity for typed results and deprecated types; generated
  structs gained zero-argument constructor defaults.
- `Touch#start` activates `WaitRepaint` like Go.

### Fixed

- `GetRootAXNodeResult#node` is nilable to match Go pointer semantics.
- Zero-argument constructors for accessibility result structs.

## [0.7.0]

Earlier history lives in the git log; this file starts at 0.7.0 because the
project does not keep release notes before that point.
