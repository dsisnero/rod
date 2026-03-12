# Testing

Primary gates:

```bash
crystal tool format --check
ameba --fix
ameba
crystal spec
```

Targeted parity checks:

```bash
crystal spec spec/must_bang_alias_spec.cr
crystal spec spec/browser_wait_download_parity_spec.cr
crystal spec spec/page_query_api_parity_spec.cr
```

Parity manifests:

```bash
./scripts/check_port_inventory.sh . plans/inventory/go_port_inventory.tsv vendor/rod go
./scripts/check_source_parity.sh . plans/inventory/go_source_parity.tsv vendor/rod go
./scripts/check_test_parity.sh . plans/inventory/go_test_parity.tsv vendor/rod go
```
