# Coding Guidelines

- Preserve upstream Go behavior; prefer semantic parity over style refactors.
- Keep API and error behavior aligned with upstream contracts.
- Use Crystal idioms only when they do not change behavior.
- Port and keep tests as first-class artifacts.
- Add concise `#` doc comments for public methods and non-obvious parity logic.
- For query methods, ensure timeout/cancellation behavior is explicit and tested.
- Keep `must_*` wrappers and `!` aliases behaviorally equivalent.
