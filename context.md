# Context

- `flake.nix` — Main flake entry point with fleet-wide binary cache configuration
- `flake.lock` — Dependency lock file for reproducible builds
- `context.md` — Structural and intent mapping for the repository root
- `README.md` — Detailed documentation of the repository purpose and multi-host structure

## Binary Caches

This flake explicitly declares several binary caches in its `nixConfig` to optimize build times across different hardware:
- **PopCat19 Shared**: Personalized binaries for this fleet
- **Shimboot**: Systemd and ChromeOS system components
- **Numtide**: Shared development tools
- **Nix Gaming**: Gaming-related packages and optimizations
