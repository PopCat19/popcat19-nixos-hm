```
.
├── configuration/
│   ├── base/                    # Minimal bootable skeleton
│   ├── builders/                # Distributed build host configs
│   ├── fish_functions/          # Custom Fish shell functions
│   ├── home/                    # Home-manager configuration
│   │   ├── hyprland/            # Hyprland compositor (shaders, scripts, modules)
│   │   ├── modules/             # Per-app home module (~40 modules)
│   │   ├── noctalia/            # Noctalia Wayland shell
│   │   └── wallpaper/           # Wallpaper assets
│   ├── hosts/                   # Per-machine configurations
│   ├── profiles/                # Composable profile presets
│   ├── secrets/                 # Agenix-encrypted secrets
│   ├── system/modules/          # System-level NixOS modules (~30 modules)
│   ├── home-manager.nix         # Centralized Home Manager config
│   ├── nix-options.nix          # Nix daemon settings (features, GC, trusted users)
│   ├── stateversion.nix         # Single source of truth for state versions
│   ├── user-config.nix          # Shared user/host/theme/fonts config
│   └── user.nix                 # User config for home-manager
├── flake-modules/               # Flake-parts modules (nixos, hosts, overlays, cachix, formatter)
├── lib/                         # Shared helper library (mkHost, mkHome, helpers)
├── overlays/                    # Package overlays (OpenTabletDriver, Friction graphics)
├── tools/                       # CLI utilities (profile manager, debug, cachix push)
├── conventions/                 # Dev conventions (see conventions/DEVELOPMENT.md)
├── .github/workflows/           # CI: flake check, cachix push, dev→main sync
└── flake.nix                    # Flake entry point
```
