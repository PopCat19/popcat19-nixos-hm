# NixOS Configuration

Personal NixOS configuration with Hyprland Wayland compositor and PMD theming.

## Overview

Personal dotfiles repository for a NixOS setup focused on:
- Modern Wayland desktop with Hyprland compositor
- Gaming-optimized environment with Steam, Proton, and AAGL
- Development-ready setup with multiple editors and language support
- Consistent theming via Stylix with PMD (Personal Material Design)
- Modular design with multi-host support
- Distributed builds between machines

## Architecture

```
nixos-config/
├── configuration/
│   ├── base/                    # Minimal bootable configuration
│   │   ├── configuration.nix
│   │   └── system/
│   ├── flake/modules/           # Flake-related modules
│   ├── home/                    # Home-manager configuration
│   │   ├── modules/
│   │   ├── hyprland/
│   │   ├── noctalia/
│   │   ├── wallpaper/
│   │   ├── home_packages.nix
│   │   └── home.nix
│   ├── hosts/                   # Host-specific configurations
│   │   ├── nixos0/
│   │   ├── surface0/
│   │   └── thinkpad0/
│   ├── profiles/                # Profile presets
│   │   ├── default.nix          # Desktop workstation
│   │   ├── laptop.nix           # Laptop profile
│   │   ├── minimal.nix          # Minimal profile
│   │   └── surface.nix          # Surface Pro profile
│   ├── system/                  # System-level configuration
│   │   ├── packages.nix         # System packages
│   │   └── modules/
│   ├── home-manager.nix
│   ├── nix-options.nix
│   ├── user-config.nix
│   └── user.nix
├── conventions/
└── flake.nix
```

## Key Components

### Desktop Environment
- Hyprland Wayland compositor with custom configuration
- Stylix theming for GTK, Qt, and cursor themes
- Fuzzel application launcher
- Custom GLSL shader effects
- Noctalia shell (Wayland bar/launcher)

### Gaming Support
- Steam with Proton compatibility
- MangoHUD performance overlay with Rose Pine theme
- GameMode optimization
- Anime Game Launcher (AAGL)
- Jovian NixOS (Steam Deck OS support)

### Development Tools
- Multiple editors: VSCodium, Zed, Micro
- Fish shell with custom functions
- Docker and Podman support
- Multiple programming languages and tools
- Git with custom configuration
- LLM agents integration

### System Features
- PipeWire audio server
- Distributed builds between machines
- Syncthing file synchronization
- Multi-host support (nixos0, surface0, thinkpad0)
- Surface Pro thermal management
- ThinkPad power management
- Agenix secrets management

### System Modules
- Audio: PipeWire configuration
- Display: Hyprland + SDDM setup
- Virtualisation: Docker, libvirt, Waydroid, QEMU/KVM
- Networking: Firewall and network management
- Power Management: TLP and custom thermal controls
- VPN: Mullvad VPN integration

## Flake Inputs

| Input | Purpose |
|-------|---------|
| nixpkgs | Core package repository |
| home-manager | User-level configuration |
| stylix | Theming framework |
| jovian | Steam Deck OS support |
| aagl | Anime game launchers |
| agenix | Secrets management |
| zen-browser | Zen browser package |
| noctalia | Wayland bar/launcher |
| pmd | Personal Material Design theme |
| vicinae | Application launcher |
| llm-agents | LLM agent utilities |

## Hosts

### nixos0 (Desktop Workstation)
- AMD Ryzen 5 5500 with ROCm support
- Dual monitor setup (DP-3 + HDMI-A-1)
- Gaming and development machine
- Distributed build server

### surface0 (Surface Pro Tablet)
- Microsoft Surface Pro (Intel i5-8350U)
- Touch/pen input support
- Aggressive thermal management
- WiFi stability fixes

### thinkpad0 (ThinkPad Laptop)
- ThinkPad series laptop
- External HDMI display support
- TLP power management
- ThinkPad ACPI integration

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd nixos-config
   ```

2. Update flake inputs:
   ```bash
   nix flake update
   ```

3. Build for specific host:
   ```bash
   sudo nixos-rebuild switch --flake .#popcat19-nixos0
   ```

4. Or for current host:
   ```bash
   sudo nixos-rebuild switch --flake .
   ```

## Development

See [`conventions/DEVELOPMENT.md`](conventions/DEVELOPMENT.md) for development conventions and coding standards.

## Note

Personal dotfiles collection with multi-host support and distributed builds. Breaking changes may occur at any time.
