# Architecture

This repository ports `go-rod/rod` behavior to Crystal.

Core architecture:
- `src/rod/*`: high-level browser/page/element API surface
- `src/rod/lib/*`: launcher, CDP transport, utilities
- `src/cdp/*`: generated and hand-maintained CDP protocol types
- `spec/*`: parity and behavior specs mapped from upstream Go tests

Upstream Go implementation under `vendor/rod` is the source of truth for behavior.
