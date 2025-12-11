# NixOS Configuration

Personal NixOS configuration with Hyprland Wayland compositor and Rose Pine theming.

## Overview

This is a personal dotfiles repository for a NixOS setup focused on:
- Modern Wayland desktop with Hyprland compositor
- Gaming-optimized environment with Steam, Proton, and gaming tools
- Development-ready setup with VS Code, language servers, and containers
- Consistent Rose Pine theming across all applications
- Modular design with multi-host support
- Distributed builds between machines

## Architecture

The configuration follows a modular structure under the `configuration/` directory:

```
nixos-config/
├── configuration/          # Main configuration directory
│   ├── flake/             # Flake modules and overlays
│   │   ├── modules/       # NixOS module definitions
│   │   └── overlays/      # Custom package overlays
│   ├── home/              # Home Manager configuration
│   │   ├── home_modules/  # User-level modules
│   │   ├── hypr_config/   # Hyprland settings
│   │   ├── packages/      # Organized package lists
│   │   └── fish_themes/   # Shell color schemes
│   ├── system/            # System-level configuration
│   │   └── system_modules/# System modules
│   ├── wallpaper/         # Wallpaper assets
│   └── user-config.nix    # Central user configuration
├── hosts/                 # Host-specific configurations
│   ├── nixos0/           # Desktop workstation
│   ├── surface0/         # Mobile workstation
│   └── thinkpad0/        # Portable laptop
├── .github/workflows/    # GitHub Actions workflows
└── .kilocode/rules/      # LLM workspace standards
```

## Key Components

### Desktop Environment
- Hyprland Wayland compositor with custom configuration
- Rose Pine theming for GTK, Qt, and cursor themes
- Fuzzel application launcher
- Custom shader effects and animations

### Gaming Support
- Steam with Proton compatibility
- MangoHUD performance overlay with Rose Pine theme
- GameMode optimization
- Anime Game Launcher (AAGL) support

### Development Tools
- Micro text editor with Rose Pine theme
- Fish shell with custom functions
- Docker and Podman support
- Multiple programming languages and tools
- Git with custom configuration

### System Features
- PipeWire audio server
- Distributed builds between machines
- Syncthing file synchronization
- Multi-host support (nixos0, surface0, thinkpad0)
- Surface Pro thermal management
- ThinkPad power management

### System Modules
- Audio: PipeWire configuration
- Display: Hyprland + SDDM setup
- Virtualisation: Docker, libvirt, Waydroid
- Networking: Firewall and network management
- Power Management: TLP and custom thermal controls
- VPN: Mullvad VPN integration

## Hosts

### nixos0 (Desktop Workstation)
- AMD Ryzen 5 5500 with ROCm support
- Dual monitor setup (DP-3 + HDMI-A-1)
- Gaming and development machine
- Distributed build server

### surface0 (Mobile Workstation)
- Microsoft Surface Pro (Intel i5-8350U)
- Touch/pen input support
- Aggressive thermal management
- WiFi stability fixes

### thinkpad0 (Portable Laptop)
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

## Note

This repository is under active development and may have breaking changes at any time. It's intended as a personal dotfiles collection with multi-host support and distributed builds.
