# Context

- `default.nix` — Shared user configuration kernel: merges per-concern defaults with host overrides and derives `directories`, `git`, and `env`
- `identity.nix` — username, full name, email, shell, base groups
- `theme.nix` — color theme hue and variant
- `fonts.nix` — monospace, sans-serif, serif, and emoji font preferences
- `default-apps.nix` — preferred desktop applications (browser, terminal, editor, etc.)
- `agents.nix` — coding/LLM agent toggles
- `gaming.nix` — gaming and ROCm feature toggles
- `env.nix` — shared environment variables
- `features.nix` — opt-in features (zrok, sillytavern, klipper)

## Notes

- Hosts import this kernel via `../../shared { inherit lib; host = { ... }; }`.
- This replaces the previous monolithic `configuration/user-config.nix` and shallow `//` merging.
