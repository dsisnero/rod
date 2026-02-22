# Rod Crystal

This is a Crystal port of [go-rod/rod](https://github.com/go-rod/rod), a high-level browser automation library.

The goal is full parity with Go Rod while maintaining Crystal idioms and best practices. The Go source code is available in the `vendor/rod` submodule and serves as the source of truth for all logic and behavior.

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

For more examples, see the [go-rod documentation](https://go-rod.github.io/) and the Crystal tests.

## Development

### Project Structure

- `src/rod/` - Crystal implementation
- `vendor/rod/` - Go source code (submodule)
- `src/cdp/` - Generated Chrome DevTools Protocol bindings
- `spec/` - Crystal specs

### Development Workflow

1. **Install dependencies**: `make install` or `shards install`
2. **Run tests**: `make test` or `crystal spec`
3. **Format code**: `crystal tool format`
4. **Lint code**: `make lint` or `ameba`

### Porting Guidelines

This is a port, not a rewrite. Follow these principles:

1. **Logic must match Go exactly** - Only syntax should differ
2. **Use Crystal idioms** - After verifying behavioral equivalence
3. **Port tests alongside code** - Every Go test should have a Crystal spec
4. **Verify against Go implementation** - Use the vendor submodule as reference

See [AGENTS.md](AGENTS.md) for detailed agent instructions.

### Generating CDP Bindings

CDP (Chrome DevTools Protocol) bindings are generated from the browser protocol definitions:

```bash
make generate
```

This uses the `pdlgen` tool in `vendor/pdlgen` to generate Crystal types from the JSON protocol definitions.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following porting guidelines
4. Add tests for new functionality
5. Run quality gates: `make format && make lint && make test`
6. Submit a pull request

## License

MIT - see [LICENSE](LICENSE) for details.

## Attribution

This project ports code from [go-rod/rod](https://github.com/go-rod/rod) (MIT licensed). The original source is preserved in the `vendor/rod` submodule.