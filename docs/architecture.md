# Architecture

This repository ports `go-rod/rod` behavior to Crystal.

Core architecture:

- `src/rod/*`: high-level browser/page/element API surface
- `src/rod/util/*`: launcher, CDP transport, defaults, devices, utilities
- `src/cdp/*`: generated CDP protocol types
- `spec/*`: parity and behavior specs mapped from upstream Go tests

Upstream Go implementation under `vendor/rod` is the source of truth for
behavior.
