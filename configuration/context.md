# Context

- `fish_functions/`: Custom Fish shell functions and completions
- `home/`: Home Manager modules (desktop, applications, theming)
- `hosts/`: Per-host NixOS and Home Manager configurations
- `nix-options.nix`: Centralized Nix configuration options
- `profiles/`: Profile presets stacking system modules for host types
- `secrets/`: Agenix-encrypted secrets (SillyTavern password, user password hash, SearXNG secret key)
- `services/`: Custom service definitions (zrok)
- `shared/`: Shared user configuration kernel merged by per-host user configs
- `stateversion.nix`: Single source of truth for NixOS and Home Manager state versions
- `system/`: System-level NixOS modules and package lists
