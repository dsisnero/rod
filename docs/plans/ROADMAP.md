# Rod Crystal Port - Development Roadmap

**Status**: Alpha / Early Development  
**Current Completion**: ~5-8%  
**Last Updated**: 2025-02-21

## Quick Reference

```bash
# View available work
bd ready

# View specific issue  
bd show rod-6o3

# Claim an issue
bd update rod-6o3 --status in_progress

# Mark complete
bd close rod-6o3
```

## Overview

This roadmap tracks the porting of the Go Rod library to Crystal. The goal is full parity with Go Rod while maintaining Crystal idioms.

## Phase 1: Foundation (Current)

### Completed ✅
- [x] Project structure and basic module layout
- [x] CDP (Chrome DevTools Protocol) type generation via pdlgen
- [x] Basic WebSocket client for CDP communication
- [x] NewType pattern implementation for type-safe IDs (BrowserContextID, TargetID, SessionID, FrameID, etc.)
- [x] Minimal Browser and Page stubs
- [x] Basic error type
- [x] Event system infrastructure (Goob-based)
- [x] Logger integration

### In Progress 🔄
- [ ] P0-Issues: Critical core functionality

## Phase 2: Core Types (P0 - Critical)

### rod-6o3: Element Type
**Priority**: P0 | **Effort**: High | **Dependencies**: None  
**Description**: Implement the Element type with 50+ DOM interaction methods

**Key Methods to Port**:
- Click, Hover, Focus, Blur
- GetText, GetHTML, GetProperty
- SetValue, Input, Select
- GetAttribute, SetAttribute
- Query (within element), Find (multiple elements)
- Frame support
- Screenshot

**Go Reference**: `element.go` (~800 lines)

---

### rod-42c: Query System (Epic)
**Priority**: P0 | **Effort**: High | **Dependencies**: rod-6o3  
**Description**: Implement CSS, XPath, and JavaScript element selection

**Implementation Plan**: See [QUERY_PORTING_PLAN.md](QUERY_PORTING_PLAN.md) for detailed 5-phase plan

**Sub-issues**:
- **rod-6jx** (P0): Phase 1 - Collection Types (Elements, Pages)
- **rod-xkz** (P0): Phase 2 - Basic Page Queries
- **rod-18n** (P0): Phase 3 - Advanced Queries (XPath, Regex, JS)
- **rod-9eb** (P1): Phase 4 - Search and Race
- **rod-sbl** (P0): Phase 5 - Element Scoped Queries

**Features**:
- Page.Element(css) / Page.Elements(css)
- Page.XPath(xpath) / Page.XPathElements(xpath)
- Page.ElementByJS(js) / Page.ElementsByJS(js)
- Element.Element / Element.Elements (scoped queries)
- Wait for element visibility/presence
- Retry logic with timeout

**Go Reference**: `query.go`, `page.go` (Element* methods)

---

### rod-e1s: JavaScript Evaluation System
**Priority**: P0 | **Effort**: High | **Dependencies**: None  
**Description**: Implement JavaScript evaluation with EvalOptions and helper functions

**Features**:
- Page.Eval(js) / Page.Evaluate(js)
- ByEvalOptions (timeout, awaitPromise, etc.)
- RemoteObject handling
- ExceptionDetails with stack traces
- Promise resolution support
- Object serialization/deserialization

**Go Reference**: `lib/proto/runtime.go`, `page.go` (Eval methods)

---

### rod-4nr: Input Types (Mouse, Keyboard, Touch)
**Priority**: P0 | **Effort**: High | **Dependencies**: None  
**Description**: Implement input simulation types

**Mouse**:
- Click, DoubleClick
- Move, Drag
- Scroll

**Keyboard**:
- Type, KeyDown, KeyUp
- Input.InsertText

**Touch**:
- Tap, Swipe, Pinch
- Multi-touch gestures

**Go Reference**: `input.go`, `lib/input/`

---

### rod-cqx: Error Types
**Priority**: P0 | **Effort**: Medium | **Dependencies**: None  
**Description**: Implement all 14 error types with proper hierarchy and wrapping

**Error Types**:
1. NotFoundError - Element not found
2. ElementNotFoundError - Specific element error
3. TimeoutError - Operation timed out
4. NavigationError - Page navigation failed
5. EvalError - JavaScript evaluation error
6. ContextError - Context-related errors
7. ConnectionError - CDP connection issues
8. TargetError - Target management errors
9. InputError - Input simulation errors
10. AssertionError - Test assertions
11. HijackError - Request interception errors
12. PageError - General page errors
13. BrowserError - Browser management errors
14. CdpError - Low-level CDP errors

**Go Reference**: `error.go`, `lib/cdp/error.go`

---

## Phase 3: Page & Navigation (P1 - High)

### rod-r6m: Page Navigation
**Priority**: P1 | **Effort**: Medium | **Dependencies**: rod-cqx  
**Description**: Implement page navigation methods

**Methods**:
- Navigate(url)
- Reload()
- GoBack()
- GoForward()
- WaitLoad()
- WaitNavigation()

**Go Reference**: `page.go` (Navigate*, Back, Forward, Reload)

---

### rod-kz1: Context/Timeout System
**Priority**: P1 | **Effort**: High | **Dependencies**: None  
**Description**: Implement context/timeout/cancellation support

**Crystal Approach**:
- Use Channel-based cancellation (Crystal idiomatic)
- Fiber-aware timeout handling
- Nested context support
- Context.WithTimeout, Context.WithCancel

**Go Reference**: Go's `context.Context` package

**Notes**: Crystal doesn't have built-in context like Go. We'll implement a Channel-based system that integrates with Crystal's concurrency model.

---

### rod-edo: Event System
**Priority**: P1 | **Effort**: High | **Dependencies**: None  
**Description**: Implement EachEvent and WaitEvent with Crystal patterns

**Features**:
- Page.EachEvent(callback) - Subscribe to all events
- Page.WaitEvent(type) - Wait for specific event
- Event filtering
- Timeout support
- Goob integration (already in place)

**Go Reference**: `page.go` (EachEvent, WaitEvent)

---

### rod-2sl: Full Launcher
**Priority**: P1 | **Effort**: High | **Dependencies**: None  
**Description**: Implement full browser launcher with auto-download

**Features**:
- Detect installed Chrome/Chromium/Edge
- Download browser binaries
- Manage browser lifecycle
- Handle different platforms (Linux, macOS, Windows)
- Revision management
- User data directory management

**Go Reference**: `lib/launcher/` directory

---

### rod-d50: Must Helpers
**Priority**: P1 | **Effort**: Medium | **Dependencies**: rod-cqx  
**Description**: Implement panic-on-error convenience methods

**Pattern**: For every method that returns error, create a `Must` variant:
- MustNavigate(url)
- MustElement(css)
- MustClick()
- MustWaitLoad()
- etc.

**Go Reference**: Throughout Go Rod (Must* methods)

---

## Phase 4: Advanced Features (P2 - Medium)

### rod-1p6: Hijack/Request Interception
**Priority**: P2 | **Effort**: High | **Dependencies**: rod-edo  
**Description**: Implement request interception and modification

**Features**:
- HijackRequests() - Enable interception
- HijackResponse - Modify responses
- Route requests to handlers
- Mock responses
- Request/response logging

**Go Reference**: `hijack.go`

---

### rod-pit: Screenshot and PDF
**Priority**: P2 | **Effort**: Medium | **Dependencies**: None  
**Description**: Implement screenshot and PDF capture

**Features**:
- Page.Screenshot() - Full page
- Element.Screenshot() - Single element
- Page.PDF() - Generate PDF
- Various format options (PNG, JPEG, PDF)
- Clip regions

**Go Reference**: `page.go` (Screenshot*, PDF methods)

---

### rod-v79: Device Emulation
**Priority**: P2 | **Effort**: Medium | **Dependencies**: None  
**Description**: Implement device emulation with full device list

**Features**:
- 100+ device definitions (iPhone, iPad, Android, etc.)
- Viewport emulation
- User agent strings
- Touch event emulation
- Device pixel ratio

**Go Reference**: `lib/devices/`

---

### rod-94o: Wait Conditions
**Priority**: P2 | **Effort**: Medium | **Dependencies**: rod-6o3  
**Description**: Implement wait conditions for stable automation

**Conditions**:
- WaitStable() - Wait for DOM to stabilize
- WaitLoad() - Wait for page load
- WaitDOMStable() - Wait for DOM changes to stop
- WaitRequestIdle() - Wait for network idle
- WaitIdle() - Combined wait

**Go Reference**: `page.go` (Wait* methods)

---

### rod-9sa: State Management
**Priority**: P2 | **Effort**: Medium | **Dependencies**: None  
**Description**: Implement domain enable/disable state management

**Features**:
- EnableDomain(domain)
- DisableDomain(domain)
- Track enabled domains
- Automatic domain management

**Go Reference**: `page.go` (Enable/Disable methods)

---

### rod-bot: JavaScript Helpers
**Priority**: P2 | **Effort**: Low | **Dependencies**: rod-e1s  
**Description**: Implement JavaScript helper functions library

**Helpers**:
- ScrollIntoView
- GetBoundingClientRect
- Click simulation
- Form handling
- Cookie helpers
- LocalStorage/SessionStorage
- Element visibility checks
- etc.

**Go Reference**: `lib/js/`

---

### rod-c6w: Input Keymap
**Priority**: P2 | **Effort**: Low | **Dependencies**: rod-4nr  
**Description**: Implement input system keymap

**Features**:
- 100+ key definitions
- Key combination support (Ctrl+A, etc.)
- Special keys (Enter, Escape, Tab, etc.)
- Modifiers (Shift, Ctrl, Alt, Meta)

**Go Reference**: `lib/input/` (keymap)

---

### rod-q20: Utils Library
**Priority**: P2 | **Effort**: Medium | **Dependencies**: None  
**Description**: Port utility functions

**Utilities**:
- Sleeper (retry with backoff)
- Retry logic
- IdleCounter
- Random string generation
- Time utilities

**Go Reference**: `lib/utils/`

---

## Phase 5: Advanced & Polish (P3 - Low)

### rod-5wc: Browser and Page Pools
**Priority**: P3 | **Effort**: High | **Dependencies**: rod-2sl  
**Description**: Implement pools for concurrent browser/page management

**Features**:
- BrowserPool - Reuse browser instances
- PagePool - Reuse page instances
- Resource limits
- Cleanup management

**Go Reference**: `pool.go`

---

### rod-dz0: Development Helpers
**Priority**: P3 | **Effort**: Low | **Dependencies**: None  
**Description**: Implement development and debugging helpers

**Features**:
- Tracing support
- Visual overlays
- Monitor/logging
- DevTools integration helpers

**Go Reference**: `dev_helpers.go`

---

## Dependencies Graph

```
Foundation
├── rod-cqx (Errors) ──┬── rod-r6m (Navigation)
│                      ├── rod-d50 (Must helpers)
│                      └── rod-94o (Wait conditions)
├── rod-e1s (JS Eval) ─┬── rod-bot (JS Helpers)
│                      └── rod-pit (Screenshot/PDF)
├── rod-6o3 (Element) ─┬── rod-42c (Query)
│                      ├── rod-94o (Wait conditions)
│                      └── rod-pit (Screenshot)
├── rod-4nr (Input) ───┬── rod-c6w (Keymap)
│                      └── rod-d50 (Must helpers)
├── rod-edo (Events) ──┬── rod-1p6 (Hijack)
│                      └── rod-dz0 (Dev helpers)
└── rod-kz1 (Context) ─┬── All P1+ features

rod-2sl (Launcher) ────┬── rod-5wc (Pools)
                       └── rod-v79 (Devices)
```

## Development Guidelines

### Type Safety
- Use NewType pattern for all IDs (BrowserContextID, TargetID, etc.)
- Leverage Crystal's type system for compile-time safety
- Avoid `JSON::Any` where possible, prefer typed structs

### Error Handling
- Implement all error types from Go Rod
- Use Crystal's exception system with custom error types
- Provide Must* variants that panic on error

### Concurrency
- Use Crystal's Fibers and Channels for async operations
- Implement context/timeout using Channel-based cancellation
- Use Mutex for thread-safe state management

### Testing
- Port Go Rod's test suite where applicable
- Add Crystal-specific tests for concurrency
- Integration tests with real browser

### Go → Crystal Mapping
- `struct` → `struct` (value types) or `class` (reference types with recursion)
- `interface` → `module` with abstract methods
- `context.Context` → Custom Channel-based context
- `sync.Map` → `Hash` with Mutex or concurrent hash map
- `error` → Custom exception hierarchy
- `go func()` → `spawn` (Crystal fibers)

## Success Criteria

- [ ] All P0 issues completed
- [ ] 80%+ test coverage
- [ ] API parity with Go Rod
- [ ] Crystal idiomatic patterns
- [ ] Documentation complete
- [ ] CI/CD passing
- [ ] Release candidate

## Resources

- **Go Rod Reference**: `vendor/rod/`
- **CDP Protocol**: `vendor/rod/lib/proto/`
- **Issues**: Run `bd ready` to see available work
- **Crystal Docs**: https://crystal-lang.org/reference/

## Contributing

1. Run `bd ready` to find available work
2. Run `bd update <id> --status in_progress` to claim
3. Create feature branch: `git checkout -b feature/rod-xxx`
4. Implement with tests
5. Run `crystal spec` to verify
6. Commit with reference: `git commit -m "rod-xxx: Implement feature"`
7. Run `bd close <id>` when complete
8. Push and create PR

---

*This roadmap is a living document. Update as priorities shift or new requirements emerge.*
