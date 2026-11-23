# Architecture

This repository ports `go-rod/rod` behavior to Crystal.

Core architecture:

- `src/rod/*`: high-level browser/page/element API surface
- `src/rod/util/*`: launcher, CDP transport, defaults, devices, utilities
- `src/cdp/*`: generated CDP protocol types
- `spec/*`: parity and behavior specs mapped from upstream Go tests
- `spec/support/*`: spec harness (pooled live browser, shared teardown helpers)

Upstream Go implementation under `vendor/rod` is the source of truth for
behavior.

## State that must stay shared

A page's JavaScript execution-context cache is shared between clones
(`Page::JsCtxCache`), because go-rod keeps `jsCtxID` behind a pointer "so that
page clones can share the change" (`vendor/rod/page.go:70`) and clears it on the
*root* page after a navigation (`page.go:188`). Anything that invalidates a
context must go through the shared holder, and callers that need an independent
cache (iframe pages, iframe-context elements) install a fresh one, mirroring
Go's `new(...)`.

## Element requests and contexts

go passes the element itself as the CDP client (`proto.X{...}.Call(el)`), and
`proto.call` takes the request context from `Element.GetContext()`
(`vendor/rod/lib/proto/a_interface.go:50-57`, `context.go:104-106`). Crystal's
`Rod::Element` is a `Cdp::Client` for exactly that reason: `#describe`, `#shape`,
`#scroll_into_view`, `#set_files` and `#shadow_root`'s node resolution therefore
honour an `Element#timeout`/`Element#context` clone.

Every JavaScript helper is injected through `@page.context(@ctx)` so `this` and
the `lib/js` helper object live in the same JS world; that is also why a refreshed
iframe element is rebuilt on the page that owns it (`element_from_object` on
`@element.page`) and why `Element#shadow_root` hands the receiver's context to
the returned element.

## Tracing

`Browser#trace(true)` logs a `[type] message page` span per operation, mirroring
go's `tryTrace`/`tryTraceQuery`/`tryTraceReq` sites (`vendor/rod/dev_helpers.go`).
The span belongs to the method go defers it in: the `Element#wait_*` helpers trace
after `wait_visible`, the page waits trace at helper entry, and `WaitOpen`/
`WaitNavigation` trace inside the closure they return. When adding a traced
operation, check where upstream puts the `defer` instead of guessing.

## Launcher and manager lifecycle

`Launcher#cleanup` waits for the browser to exit and removes its
`user-data-dir`; specs call it through `shutdown_launcher`
(`spec/spec_helper.cr`). `Rod::Util::Launcher::Manager` mirrors Go's
`Manager.launch`/`Manager.cleanup`: managed browsers are forced leakless, killed
on disconnect only when the caller asked for a managed browser, and their
profiles are always removed.
