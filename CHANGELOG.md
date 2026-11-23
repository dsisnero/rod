# Changelog

All notable changes to this project. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project aims to
follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Behavior is pinned to `go-rod/rod` at `vendor/rod` commit `d38c753`; entries
below describe the Crystal port, not upstream changes.

## [Unreleased]

### Added

- `make check-generate-crystal` (`scripts/check_generate_crystal.sh`): regenerates
  the pinned CDP vintage (`CDP_CHROMIUM=160.0.8168.1` / `CDP_V8=16.0.61`) into
  `temp/cdp_generated/`, formats it like `make generate-crystal`, and diffs it
  against `src/cdp`, so a hand edit or a template regression in the generated
  bindings cannot go unnoticed. A hand edit in `src/cdp` fails the gate by path.
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

### Fixed

- `Element#interactable` returns the `ContainsElement` error like go's
  `Interactable` (`element.go:392-400`). The port swallowed Chrome's "Argument
  should belong to the same JavaScript world as target object" and treated the
  element as *not covered*, so it reported a click point it could not verify and
  `wait_interactable` accepted it (only `CoveredError` retries). That message
  was a symptom of the wrong-JS-world requests fixed in Phases 62/63, and the
  live click/hover/tap/iframe specs pass without the workaround.
- `Element#wait_stable` waits on go's ticker race instead of a plain sleep: it
  `select`s between the interval and the element context (`element.go:519-550`),
  so an `Element#timeout`/`#context` clone stops the loop as soon as its deadline
  or cancellation fires instead of sleeping out the whole interval, and it traces
  `stable` only after `WaitVisible` succeeds. `Element#wait_stable_raf` got the
  same span placement (`element.go:556-570`).
- `Browser#trace(true)` now emits go's spans for the page waits: `wait open`,
  `event <protoEvent>`, `navigation <name>`, `request-idle`, `dom-stable` and
  `stable` (`page.go:661-705`, `718`, `784`, `822`), each placed where go's
  `defer p.tryTrace(...)` sits — at helper entry for the synchronous waits and
  inside the returned closure for `WaitOpen`/`WaitNavigation`. `Element#wait` no
  longer invents a span go does not have (`element.go:608-610`), so all 31
  upstream trace sites match.
- `Element#screenshot` builds `Page.captureScreenshot` like go's struct literal
  (`element.go:681-684`): the `quality` is always transmitted, even `0`, because
  go's `gson.Int` returns a non-nil pointer and the `omitempty` tag therefore
  never drops it; and an empty `format` is omitted like its `omitempty` tag, so
  Chrome keeps its `png` default instead of rejecting `"format": ""`.
- The iframe element refresh keeps the parent page's JS context: when Chrome
  answers a stale-node error while an iframe page resolves its JS context,
  `refresh_iframe_element` now rebuilds the `<iframe>` element through
  `ElementFromObject` on the page that owns it (`@element.page`) instead of on
  the iframe page. An iframe's backing element lives in the parent document
  (go's `Element.Frame` copies `el.page`, `element.go:458-471`), so building it
  on the iframe page put the element's object handle and its injected `lib/js`
  helpers in different JS worlds.
- Element CDP requests run in the element's context, like go-rod's
  `proto.X{...}.Call(el)` (`lib/proto/a_interface.go:50-57`): `Element` is now a
  `Cdp::Client` (as it is a `proto.Client` in go) and `#describe`, `#shape`,
  `#scroll_into_view`, `#set_files` and `#shadow_root`'s node resolution pass the
  element as the client instead of the page. An `Element#timeout`/`#context`
  clone's deadline and cancellation now reach those requests.
- `Element#shadow_root` builds the returned element through
  `el.page.Context(el.ctx).ElementFromObject(...)` like go (`element.go:456`),
  so the shadow root carries the receiver's context and gets the same JS-context
  resolution as every other object-based element. It was built with the page's
  context, so a cloned element's deadline never applied to the shadow root.
- `Element#input_time`, `Element#input_color` and `Element#contains_element`
  evaluate go's shared `lib/js` helpers (`js.InputTime`, `js.InputColor`,
  `js.ContainsElement`) instead of hand-copied JavaScript
  (`element.go:303`, `325`, `475`). `input_time` regains the user gesture go
  marks it with (`... .ByUser()`); all 33 helpers in `src/rod/util/js.cr` are now
  wired, so a helper edit can no longer leave a stale inline copy behind.
- `Page#capture_dom_snapshot` sends go's DOM snapshot include flags and enables
  the domain first. It passed `nil` for `includePaintOrder`, `includeDOMRects`,
  `includeBlendedBackgroundColors` and `includeTextColorOpacities`, so Chrome
  answered without `paintOrders`, `offsetRects`/`scrollRects`/`clientRects`,
  `blendedBackgroundColors` or `textColorOpacities` — data go's
  `CaptureDOMSnapshot` (`page.go:600-614`) always requests — and it skipped the
  discarded `DOMSnapshot.enable` call (`_ =`, `page.go:601`).
- `Element#input` dispatches the synthetic `input`/`change` events with go's
  shared `js.InputEvent` helper **as a user gesture**
  (`evaluate(evalHelper(js.InputEvent).ByUser())`, `element.go:278`). It ran a
  hand-written copy of the same JavaScript without a user gesture.
- `Page#extra_headers` and `Page#handle_dialog` enable and restore their CDP
  domains through `Page#enable_domain`, like go's `Page.EnableDomain`
  (`page.go:139-147`, `613-631`). They previously enabled and disabled
  unconditionally, so they turned Network or Page off for a caller that had
  enabled the domain and still needed it.
- Event waits (`Browser#each_event`, and therefore `Page#each_event`,
  `wait_request_idle`, `wait_stable` and `WaitDownload`) enable their CDP domains
  through `Browser#enable_domain`, like go's `EnableDomain` (`states.go:60-73`).
  Previously a wait that ended disabled a domain another caller had enabled and
  still needed, silently stopping its events.
- Element operations run in the element's own context, like go-rod's
  `el.page.Context(el.ctx)` (`element.go:88-734`): `click`, `hover`, `tap`,
  `type`, `key_actions`, `input`'s `insert_text`, `screenshot` and `evaluate`
  used the page's context, so an element cloned by `Element#timeout` or
  `Element#context` ignored its own deadline for those calls. `move_mouse_out`
  keeps using the page directly, matching go's one non-re-contexted site.
- `Page#evaluate` (and every helper-registration request) omits `false` flags
  from `Runtime.callFunctionOn` instead of sending them, matching go's proto
  fields (`bool` + `json:",omitempty"`). Same class as the Phase 54
  `fromSurface` fix: CDP defaults now apply whenever an option is not set.
- `Page#scroll_screenshot` no longer sends `fromSurface: false`: go marks that
  field `json:"fromSurface,omitempty"` (`vendor/rod/lib/proto/page.go:1745-1746`),
  so the `FromSurface: false` literal in `ScrollScreenshot` never reaches the
  browser and CDP keeps its documented default (`true`). The port transmitted the
  literal, and Chrome answers `-32000 Unable to capture screenshot` for a clipped
  capture with `fromSurface: false` — the ported `TestScrollScreenshot` example
  failed deterministically because of it. `captureBeyondViewport` and
  `optimizeForSpeed` are omitted too, matching go's wire request.
- `Page#expose` works: the `Runtime.bindingCalled` listener is now started in a
  fiber, like go's `go p.EachEvent(...)` (`page_eval.go:214`). The port passed
  `each_event`'s *wait* function to `stop()` instead of running it, so an exposed
  function never received its callback — `page.eval("() => exposedFunc(...)")`
  hung until the context deadline — and `stop()` blocked forever in the listener
  loop. `stop` now also follows go's order (remove the new-document script,
  `Runtime.removeBinding`, then cancel the listener context via `defer cancel()`,
  `page_eval.go:203-212`). Ported go's live `TestPageExpose`: two concurrent
  calls, survival across a reload, a second `stop()` that fails, and a reload
  that leaves the function unbound.
- `Page#must_expose` is usable: it took a `Proc(JSON::Any, JSON::Any)` that never
  matched `expose`'s tuple-returning proc, so it never type-checked — and because
  `Rod::Page` defines `method_missing`, the mismatch was reported as
  `undefined method 'must_expose'` instead of a type error. It now takes the same
  function shape as `expose`, which also accepts a `nil` function like go's
  `Expose(name, nil)` (`page_eval.go:186`, `must.go:479-484`).

### Changed

- `make test` now runs `crystal spec spec` with `CRYSTAL_CACHE_DIR` pinned to the
  git-ignored `.crystal-cache/`: Crystal names the spec binary
  `crystal-run-spec.tmp` inside the cache directory, so with the shared default
  cache a concurrent run from another checkout could make this repo execute that
  checkout's examples.
- Trace overlays are removed when the traced operation ends, like go-rod:
  `Page#overlay` and `Element#overlay` return a remove function that runs
  `js.removeOverlay` with the same id (`dev_helpers.go:114-131`, `198-211`),
  instead of a no-op that left the overlay div (and `elementOverlay`'s 100 ms
  reposition timer) in the page for the rest of the session. `try_trace_req`
  (the `wait requests` trace used by `Page#wait_request_idle`) draws its
  includes/excludes overlay and deletes it when the page context ends, like go's
  tracer goroutine (`dev_helpers.go:157-195`).
- `Element#scroll_into_view` follows go's `ScrollIntoView` (`element.go:68-78`):
  it waits for a stable repaint (`WaitStableRAF`) and then scrolls with
  `DOM.scrollIntoViewIfNeeded`. A second, later definition of the method had
  silently replaced that path with a plain `this.scrollIntoView(...)` eval, so
  the DOM call, the repaint wait and the trace/slow-motion hooks never ran.
  `Element#focus` and `Element#blur` now run as user gestures like go's
  `Eval(...).ByUser()` (`element.go:56-64`, `332-335`).
- `Page#wait_repaint` evaluates the `requestAnimationFrame` promise on the
  **root** page like go (`page.go:849-853`, "iframe doesn't trigger
  requestAnimationFrame"). `Page#root_page` now follows go's `Page.root`: a page
  created for a target is its own root, a frame clone inherits its page's root,
  and a JS-context clone keeps it. Before, the root was re-derived by walking
  `@element`, which answered the page itself for elements found by
  `Page#search` inside an iframe — `ScrollIntoView` on them then blocked forever
  on a throttled frame. The trace overlay helper used the same name with a
  one-level walk; it now draws on the real root (`dev_helpers.go:114-124`).
- Quad geometry has a single implementation again: `Rod::Util::Quad` delegates
  `len`/`each`/`center`/`area`/`one_point_inside`/`box` to the generated
  `Cdp::DOM` helpers (the port of go's `DOMQuad` patch methods) instead of
  repeating the math for `Element#interactable`, `#hover`, `#move_mouse_out` and
  `#screenshot`. `spec/quad_util_equivalence_spec.cr` pins the two against each
  other over whole-number, sub-pixel, counter-clockwise, degenerate and sliver
  quads, so a future fix cannot land in only one copy (Phase 30 had to fix both).
- `Element#element`, `#element_x`, `#element_r`, `#elements` and `#elements_x`
  now run go-rod's shared `lib/js` helpers through `eval_helper` instead of
  hand-written scripts (`query.go:487-499`). The visible fix is `element_r`: its
  regex argument is parsed like a JavaScript literal, so `element_r("span",
  "/hello/i")` builds `new RegExp("hello", "i")` and matches case-insensitively,
  where the raw-string form matched nothing (`lib/js/helper.go:40-44`). Element
  scoped `elements`/`elements_x` also go through `Element#elements_by_js`, i.e.
  go's `el.page.Context(el.ctx)` path.
- `Browser#load_state`/`Page#load_state` load the stored CDP params like go-rod's
  reflective `LoadState` (`states.go:43-52`), and `Page#screenshot(full_page:
  true)` restores the viewport from the browser state map (`page.go:437-471`)
  instead of a page-local copy, so a viewport applied with a raw
  `Emulation.setDeviceMetricsOverride` survives a full-page shot. A stored
  payload the request cannot rebuild is left alone field by field, and `nil`
  means "no state was stored". go fills the caller's request through
  `reflect.Value.Set`; Crystal copies structs at call boundaries, so
  `load_state` returns the loaded request instead (documented divergence).
  `Browser#wait_download` now reads the previous behavior through the same path,
  dropping the JSON workaround it shipped with.
- `Hijack#load_response(client, false)` no longer reads the response body, like
  go-rod's `LoadResponse` (`hijack.go:224-250`): the response is streamed through
  `HTTP::Client#exec(request) { ... }` so only `load_body: true` drains
  `body_io`. A hijack handler that proxies a large download no longer buffers it
  in memory first.
- `Pages#find` and `Pages#find_by_url` return the page or raise
  `PageNotFoundError`, like go-rod's `(nil, &PageNotFoundError{})`
  (`query.go:76-102`), instead of returning `nil`; `must_find`/`must_find_by_url`
  keep raising it. Page-level errors (`Has`, the URL eval) still propagate.
- `Rod::Input.mac?` defaults to the host OS, like go-rod's
  `var IsMac = runtime.GOOS == "darwin"` (`lib/input/mac_comands.go:5`), and
  `MAC_COMMANDS` carries every row go's `macCommands` can actually reach
  (`ArrowUp`/`ArrowDown`/`ArrowLeft`/`ArrowRight`, `Escape`, `F5`, `Delete`,
  `Home`, `End`, `PageUp`, `PageDown`). go looks the table up by
  `Key.Info().Key` alone (`keyboard.go:108-111`), so its playwright-style
  combination keys ("Meta+KeyA", "Shift+Enter", …) can never match and are not
  ported.
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

- `Element#get_xpath` evaluates go's `js.GetXPath` helper on the element, like
  `el.Evaluate(evalHelper(js.GetXPath, optimized))` (`element.go:747-754`). It
  ran the helper on the page, leaving `this` unbound, so every element answered
  `/`; `get_xpath(true)` now also returns the `//*[@id='...']` form again.
- `Element#parents` works again: it ran its own script straight on the page
  without binding `this` to the element, so a real call always answered an empty
  list (the stub-only spec only checked the recorded options). It now runs go's
  `js.Parents` helper with the selector go requires
  (`query.go:516-518`), so `parents(selector)` returns the matching ancestors,
  nearest first. The non-go `parents` overload without a selector is gone
  (`must_parents` already required one).
- `Element#frame` keeps the page's panic handler, so `must_*` on an iframe page
  reaches the handler installed with `Page#with_panic`/`set_panic_handler`, like
  go's `Element.Frame` (which copies `*el.page`, `element.go:458-471`). The
  iframe page is still a fresh `Page` with its own JS context, the element's
  sleeper and the page's `ctx`.
- `Browser#wait_event_typed` (and therefore `Browser#wait_event`, `Page#wait_event`
  and everything built on it) re-enabled the event's domain with
  `Domain.enable` and always disabled it in its cleanup, ignoring the browser
  state map. go-rod's `eachEvent` uses `b.EnableDomain(sessionID, enable)`
  (`browser.go:355-375`), so waiting for an event never reconfigures or tears
  down a domain the caller enabled. In practice `handle_auth` could never
  complete a live basic-auth challenge: the paused-request wait disabled Fetch
  again, and `Fetch.continueRequest` failed with `Fetch domain is not enabled`
  (surfaced by the newly ported live `TestHandleAuth`).
- The live `TestHandleAuth` example now awaits its auth fiber before releasing
  the page, so a pooled browser is never handed on with the Fetch domain still
  enabled, and `spec/live_browser_pool_spec.cr` asserts that a re-borrow adds no
  launch relative to the first borrow (the previous `launches_before + 1` form
  only passed on a cold pool).
- `Browser#handle_auth` tore the Fetch domain down and always disabled it when
  the auth wait finished, so a hijack router enabled before the call stopped
  intercepting afterwards. It now uses `disable_domain`/`enable_domain` like
  go-rod's `DisableDomain("", &FetchEnable{})` /
  `EnableDomain("", &FetchEnable{HandleAuthRequests: true})`
  (`hijack.go:415-455`) and restores the previous state in go's deferred order
  (`cancel`, then the disable restore, then the enable restore).
- `Element#select_all_text` selected a **document** range
  (`window.getSelection()` + `range.selectNodeContents`), which cannot select
  `<input>`/`<textarea>` contents — those keep their selection in
  `selectionStart`/`selectionEnd` — so `select_all_text` + `input` appended
  instead of replacing (`"hi"` → `"hello therehi"`, and clearing a field was
  impossible). It now evaluates go-rod's `js.SelectAllText`
  (`function(){this.select()}`) as a user gesture like `element.go:241-254`, and
  `Element#select_text` uses `js.SelectText` the same way (`element.go:228-239`).
  Reported as `temp/issues/rod.004.md`.
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
