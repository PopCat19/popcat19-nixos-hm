# Context

- `configuration/` — NixOS and Home Manager configuration modules, hosts, and profiles
- `flake-modules/` — Flake-parts modules for NixOS, nix-on-droid, and formatter
- `flake.nix` — Main flake entry point for NixOS multi-host configuration
- `git-intent-watch.sh` — Continuously run 'git add --intent-to-add .' every 3 seconds
- `lib/` — Builder functions (mk-host, mk-home) and helper utilities
- `overlays/` — Custom package overlays (Friction graphics, ROCm targets)
- `tools/` — Development tooling (flake-auto-update, profile-manager)
