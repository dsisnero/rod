# Coding Guidelines

## Parity first

- Preserve upstream Go behavior; prefer semantic parity over style refactors.
- Keep API shape and error behavior aligned with `vendor/rod` contracts.
- Use Crystal idioms only when they do not change observable behavior.
- `must_*` helpers and their `!` aliases must stay behaviorally equivalent
  (`page!` ↔ `must_page`, `element!` ↔ `must_element`).
- For query methods, make timeout/cancellation behavior explicit and tested.

## Crystal style

- Format with `crystal tool format`; lint with `ameba --fix` then `ameba`.
- Follow Crystal naming: `snake_case` for methods/variables, `CamelCase` for
  types; match upstream exported names with `must_` prefixes and predicate `?`
  methods where they map cleanly.
- Prefer the standard library over hand-rolled helpers.
- Use the type system instead of casts: avoid `as` unless narrowing is
  genuinely required, and prefer `nil`-aware APIs (`receive?`, `[]?`) over bare
  `not_nil!`.
- Add concise `#` doc comments for public methods and for non-obvious parity
  logic (note the Go symbol being mirrored when names differ).

## Specs

- Port and keep tests as first-class artifacts; see
  [testing.md](testing.md) for the Go → Crystal porting rules.
- Do not weaken assertions to make a spec pass.
