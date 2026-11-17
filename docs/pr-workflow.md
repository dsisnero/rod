# PR Workflow

1. Pick the next item from the **Next up** list in `plans/parity.md`.
2. Implement behavior-faithful changes against `vendor/rod`.
3. Port or update the matching upstream tests as specs.
4. Run the gates: `make format`, `make lint`, `make test`, and the parity
   checks under `make check-go-*` when manifests changed.
5. Update `plans/inventory/go_port_inventory.tsv` for the feature's symbols and
   refresh the **Where we are** block in `plans/parity.md`.
6. Commit focused changesets with a `port: <feature>` message (see
   `AGENTS.md`), then push.
