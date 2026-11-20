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

- `Browser#wait_download` restores the download behavior that was active before
  the call, like go-rod's `has := b.LoadState("", &oldDownloadBehavior)` /
  `oldDownloadBehavior.Call(b)` (`browser.go:504-538`), and only falls back to
  `default` when there was none. A browser already configured with
  `allowAndName` (or `deny`) keeps that configuration instead of being reset.
- `HijackRequest#json_body` answers a null `JSON::Any` for a body that is not
  valid JSON, like go's `gson.NewFrom` (`hijack.go:290-292`); it used to raise
  `JSON::ParseException`, so a hijack handler that inspected a plain-text POST
  body blew up. `HijackResponse#body` now decodes `payload.body`, so the payload
  is the single source of truth like go's `string(ctx.payload.Body)`
  (`hijack.go:340-343`) instead of a parallel `@body_text` field that a
  `payload=` replacement could leave stale.
- `Page#elements_by_js` reports go-rod's `ExpectElementsError`
  (`query.go:206-246`) instead of a plain `Exception`: a non-array result, an
  array entry that is not a DOM node, and a property without a value (an
  accessor descriptor) all raise it while carrying the offending remote object,
  so `Rod.is?(err, Rod::ExpectElementsError)` matches. `ExpectElementsError`
  accepts a nil object and renders it as `null`, like go's
  `RuntimeRemoteObject.String`.
- `Launcher#kill` now sends only `SIGKILL`, to the process group and to the pid,
  exactly like go-rod's `Launcher.Kill` (`killGroup` + `p.Kill()`,
  `lib/launcher/launcher.go:544-558`, `os_unix.go:12-14`); the extra `SIGTERM`
  the port sent first is gone. `Launcher#cleanup` also removes the
  `user-data-dir` unconditionally, like `Launcher.Cleanup`
  (`launcher.go:560-566`) — `--rod-keep-user-data-dir` is honoured by
  `Manager.cleanup` (`manager.go:200-208`), which the port already does.
- `Element#wait_interactable` takes no `timeout` argument and is now
  `utils.Retry(el.ctx, el.sleeper(), ...)` like go-rod's `WaitInteractable`
  (`element.go:587-606`): only a `CoveredError` retries, any other error stops
  the wait, and the element/page context and chained sleeper decide how long it
  keeps trying. The private 5 s deadline is gone, so a slow overlay no longer
  surfaces a `CoveredError` after five seconds.
- Lookup probes follow go-rod's `NotFoundSleeper` split between "look once" and
  "wait for it": `Page#has`/`has_x`/`has_r` (`query.go:105-138`),
  `Element#element_by_js` (`query.go:501-508`) and every `RaceContext` branch
  (`query.go:438-457`) now fail the first attempt instead of retrying with the
  page sleeper, and the element they find keeps the caller's sleeper
  (`el.Sleeper(...)`). `Rod.not_found_sleeper` is now the factory shape Go's
  `NotFoundSleeper` has (`func() utils.Sleeper`), so it can be installed with
  `Page#sleeper`/`Element#sleeper`.
- Elements inherit their page's `ctx` and `sleeper` (`ElementFromObject`,
  `page.go:947-953`), so `page.timeout(...)` and
  `page.sleeper(-> { ... })` now bound element lookups and waits the way
  go-rod's do; `Element#elements_by_js` also runs in the element context
  (`query.go:540-543`).
- `Element#wait_visible`, `Element#wait_enabled`, `Element#wait_writable` and
  `Element#wait_invisible` now take no timeout argument and delegate to
  `Element#wait`/`Page#wait`, like go-rod's
  `Wait(evalHelper(js.Visible))` family (`element.go:608-636`). The page or
  element context and the chained `sleeper` decide how long and how often the
  predicate is retried; the port's private `wait_for(timeout)` poll loop (fixed
  5s deadline, 10 ms poll, `Rod::TimeoutError`) is gone. `visible?` answers
  go-rod's `js.Visible` (`element.go:501`): display, visibility and a non-empty
  client rect, with no `opacity` check.
- `Rod::NotFoundError` (the port's lookup miss) now derives from
  `Rod::ElementNotFoundError`, which also moved next to `RodError` in
  `src/rod/types.cr`. Every element lookup therefore raises an
  `ElementNotFoundError` subclass like go-rod's
  `errors.Is(err, &rod.ElementNotFoundError{})` contract expects, while
  `rescue Rod::NotFoundError` keeps working. The port-specific detail message
  (`Element not found within 5s`, `cause`) is unchanged; matching is by class.
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

- `ctx.request.json_body` raised `JSON::ParseException` inside a hijack handler
  for any non-JSON request body (the common plain-text POST), aborting the
  handler fiber; go-rod's `JSONBody()` answers a null JSON there, and so does
  the port now.
- `Element#elements_by_js` silently skipped array entries without a `value`
  instead of reporting `ExpectElementsError`, so a page whose lookup returned a
  getter produced a short element list rather than an error.
- `element.wait_interactable` gave up after a private 5 s deadline with the
  `CoveredError` it was retrying, even when the page or element context allowed
  more time (a modal or overlay that lifts after five seconds failed). It now
  keeps retrying while the element is covered, and surfaces the context's
  `DeadlineExceededError` or the sleeper's error when the budget runs out —
  the same stop conditions as go-rod's `utils.Retry`.
- `page.has("#missing")` blocked for the whole 5 s query timeout instead of
  answering `false` on the first attempt, `element.has("#missing")` never
  returned at all (an `Element#timeout` did not apply because the lookup ran on
  the page context), and `page.race` burned 5 s on every branch that missed.
  All of them now probe once, like go-rod's `NotFoundSleeper`.
- `Element#has`/`has_x`/`has_r` (and `parent`/`next`/`previous`) only rescued the
  port's `NotFoundError`, so a plain `ElementNotFoundError` — the one
  `NotFoundSleeper` raises — escaped instead of answering `false`/`nil`.
- `Element#wait_visible`, `wait_enabled`, `wait_writable` and `wait_invisible`
  ignored the page/element timeout and the chained sleeper: an element that
  became visible after 6 seconds failed under `page.timeout(30.seconds)`, and
  `CountSleeper`/`MaxSleepCountError` never fired. They now surface the
  context's `DeadlineExceededError` (Go's `context.DeadlineExceeded`) and the
  sleeper's error, exactly like `utils.Retry` does for go-rod's `Element.Wait`.
- `Element#visible?` disagreed with `js.Visible`: it treated `opacity: 0` as
  invisible and a zero-size box as visible, so `wait_visible` could hang or
  return early where go-rod would not.
- `Cdp::DOM.area` and `Rod::Util::Quad.area` return the signed shoelace area like
  go-rod's `DOMQuad.Area` (`lib/proto/a_patch.go:90-100`) instead of its absolute
  value, so `one_point_inside` skips clockwise-wound quads exactly like
  `OnePointInside`'s `q.Area() >= 1` guard. The generated helpers and their
  `pdlgen` template were updated together.
- `Rod::Util::Launcher::Manager` no longer answers 501 to a websocket upgrade
  without a `Rod-Launcher` header; like go-rod (`manager.go:172-178`) it launches
  with the launcher's default flags, still running the `before_launch` path
  protection.
- `Rod.is?` (the port's `errors.Is`) follows `unwrap` through the new
  `Rod::Unwrappable` before falling back to `cause`, so
  `Rod.is?(err, Rod::NotInteractableError)` matches `CoveredError`,
  `InvisibleShapeError` and `NoPointerEventsError` like go-rod's `Unwrap`
  chain. `Element#must_interactable` now classifies with it and returns `false`
  for all three instead of raising.
- `Element#must_interactable` could not be called at all: `Element` defines
  `method_missing` for the `foo!` aliases, which captured the method's bare
  re-`raise` and turned every call site into
  `undefined method 'raise' for …`. It now re-raises the captured error.
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
