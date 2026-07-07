# Context

Per-host NixOS configurations. Each subdirectory contains a complete host definition:

- `nix-on-droid/`: Nix-on-Droid configuration for mobile/Android
- `popcat19-dedede0/`: ChromeOS/Dedede-based device
- `popcat19-nixos0/`: Primary desktop (x86_64, gaming, SillyTavern, etc.)
- `popcat19-surface0/`: Microsoft Surface device
- `popcat19-thinkpad0/`: Lenovo ThinkPad

Each host directory contains:

- `configuration.nix`: NixOS system configuration
- `home.nix`: Home Manager user configuration
- `hardware-configuration.nix`: Auto-generated NixOS hardware config
- `user-config.nix`: Host-specific user config (profile, features, overrides)
