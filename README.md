# NixOS Configuration

Personal NixOS configuration with Hyprland Wayland compositor and Rose Pine theming.

## Overview

This is a personal dotfiles repository for a NixOS setup focused on:
- Modern Wayland desktop with Hyprland compositor
- Gaming-optimized environment with Steam, Proton, and gaming tools
- Development-ready setup with VS Code, language servers, and containers
- Consistent Rose Pine theming across all applications
- Modular design for easy customization

## Architecture

The configuration follows a modular structure:

```
nixos-config/
├── system_modules/     # System-level configuration
├── home_modules/       # User-level configuration
├── hypr_config/        # Hyprland settings
├── hosts/             # Host-specific configurations
├── overlays/          # Custom package overlays
└── user-config.nix    # Central user configuration
```

## Key Components

### Desktop Environment
- Hyprland Wayland compositor with custom configuration
- Rose Pine theming for GTK, Qt, and cursor themes
- QuickShell status bar with system monitoring
- Fuzzel application launcher

### Gaming Support
- Steam with Proton compatibility
- Lutris and Heroic Game Launcher
- MangoHUD performance overlay
- GameMode optimization

### Development Tools
- VS Code with language servers
- Docker and Podman support
- Multiple programming languages (Python, Node.js, Rust, Go, Java)
- Git with custom configuration

### System Features
- PipeWire audio server
- Distributed builds between machines
- Syncthing file synchronization
- Custom fish shell functions and aliases

## Note

This repository is under active development and may have breaking changes at any time. It's intended as a personal dotfiles collection, with plans to eventually convert it into a proper distribution.
