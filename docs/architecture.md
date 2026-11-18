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

## Launcher and manager lifecycle

`Launcher#cleanup` waits for the browser to exit and removes its
`user-data-dir`; specs call it through `shutdown_launcher`
(`spec/spec_helper.cr`). `Rod::Util::Launcher::Manager` mirrors Go's
`Manager.launch`/`Manager.cleanup`: managed browsers are forced leakless, killed
on disconnect only when the caller asked for a managed browser, and their
profiles are always removed.
