| Workflow | Trigger | Action |
|----------|---------|--------|
| `flake-check.yml` | Push to `dev` | `nix flake check` on all hosts |
| `cachix-nixos.yml` | Push to `dev` | Build + push to Cachix |
| `sync-dev-main.yml` | Push to `main` | Sync back to `dev` (bidirectional) |
