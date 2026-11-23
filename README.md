# Rod Crystal

A Crystal port of [go-rod/rod](https://github.com/go-rod/rod), a high-level
browser automation library for the Chrome DevTools Protocol.

The goal is full parity with Go Rod while keeping Crystal idioms and best
practices. The Go source is preserved in the `vendor/rod` submodule and is the
source of truth for all behavior.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  rod:
    github: dsisnero/rod
```

Then run `shards install`.

## Usage

```crystal
require "rod"

# Connect to existing browser
browser = Rod::Browser.new
browser.connect("ws://localhost:9222/devtools/browser/...")

# Get page and navigate
page = browser.page
page.navigate("https://example.com")

# Find elements and interact
element = page.element("h1")
puts element.text

# Close browser
browser.close
```

### Must Bang Aliases

All `must_*` helpers also support `!` aliases:

```crystal
browser = Rod::Browser.new.connect!
page = browser.page!("https://example.com")
title = page.element!("h1").text!
```

`page!` is an alias for `must_page`, `element!` for `must_element`, etc.

### Opening pages

`page` creates a tab. Pass a `Target.createTarget` request for everything
go-rod's [`Browser.Page`](https://pkg.go.dev/github.com/go-rod/rod#Browser.Page)
supports — a new window instead of a tab, a background tab, or a non-default
size:

```crystal
# A new window instead of a tab (go's `TargetCreateTarget{NewWindow: true}`)
window = browser.page(Cdp::Target::CreateTarget.new("", new_window: true))

# A background tab that loads while the current page keeps running
tab = browser.page(Cdp::Target::CreateTarget.new("https://example.com", background: true))
```

The creation URL is always `about:blank`; a non-empty `url` is navigated
afterwards. The plain `page` / `page("about:blank")` form does not re-navigate a
target that CDP already opened there. See
`examples/page-options/main.cr`.

### Query Timeout Behavior

`element_r` / `must_element_r` follow page/query timeout settings the same way
as other query helpers. When no match exists, they fail with timeout instead of
looping indefinitely.

### Download Example

The end-to-end download example is available at:

- `examples/compare-chromedp/download_file/main.cr`

It relies on browser download events (enabled through `Browser#wait_download`)
and writes the downloaded bytes after the browser reports completion.

For more examples, see the [go-rod documentation](https://go-rod.github.io/)
and the Crystal specs under `spec/`.

## Development

```bash
make install   # shards install
make format    # crystal tool format --check
make lint      # ameba
make test      # crystal spec
make check-examples  # compile every example (they are not part of `make test`)
```

Specs that drive a browser borrow one pooled Chrome
(`spec/support/live_browser_pool.cr`), so the suite does not launch a browser per
example. Use `ROD_CHROME_BIN` to point at a non-default Chrome and
`ROD_POOL_STATS=1` to see how many browsers a run launched; see
[docs/testing.md](docs/testing.md).

Start with [docs/resuming.md](docs/resuming.md) to pick up work, and
[docs/development.md](docs/development.md) for project layout, upstream pinning,
and parity gates. Released changes are listed in [CHANGELOG.md](CHANGELOG.md).

## Documentation

- [Resuming work](docs/resuming.md)
- [Architecture](docs/architecture.md)
- [Development](docs/development.md)
- [Coding Guidelines](docs/coding-guidelines.md)
- [Testing](docs/testing.md)
- [CDP generation](docs/generation.md)
- [PR Workflow](docs/pr-workflow.md)
- [Porting plan](plans/parity.md)
- [Changelog](CHANGELOG.md)

Agent instructions live in [AGENTS.md](AGENTS.md) (also reachable as
`CLAUDE.md`).

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make behavior-faithful changes and port the matching upstream tests
4. Run the gates: `make format && make lint && make test`
5. Submit a pull request — see [docs/pr-workflow.md](docs/pr-workflow.md)

## License

MIT - see [LICENSE](LICENSE) for details.

## Attribution

This project ports code from [go-rod/rod](https://github.com/go-rod/rod) (MIT
licensed). The original source is preserved in the `vendor/rod` submodule.
