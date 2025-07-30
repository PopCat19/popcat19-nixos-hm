# NixOS Configuration Documentation

Welcome to the comprehensive documentation for this NixOS configuration. This setup provides a modern, gaming-focused Linux desktop environment with Hyprland as the window manager.

## Quick Start

- [**Installation Guide**](installation.md) - Get started with a fresh NixOS installation
- [**Configuration Guide**](configuration.md) - Learn how to configure your system
- [**Features Overview**](features.md) - Discover what's included in this setup
- [**Customization Guide**](customization.md) - Personalize your experience
- [**Troubleshooting**](troubleshooting.md) - Solve common issues

## System Overview

This configuration provides:

- **Modern Wayland desktop** with Hyprland compositor
- **Gaming-optimized** environment with Steam, Proton, and gaming tools
- **Development-ready** with VS Code, language servers, and containers
- **Beautiful theming** with Rose Pine color scheme
- **Productivity tools** including clipboard manager, file manager, and more
- **Modular design** for easy customization and maintenance

## Architecture

The configuration is organized into modular components:

```
nixos-config/
├── system_modules/          # System-level configuration
├── home_modules/           # User-level configuration
├── hypr_config/           # Hyprland-specific settings
├── docs/                  # This documentation
├── user-config.nix        # Main user configuration
└── flake.nix             # Nix flake definition
```

## Key Features

### Desktop Environment
- **Hyprland** - Modern Wayland compositor with animations
- **Rose Pine theme** - Consistent theming across all applications
- **Custom keybindings** - Optimized for productivity
- **Multi-monitor support** - Per-display configuration

### Gaming
- **Steam** - Full gaming platform with Proton support
- **Lutris** - Game launcher for non-Steam games
- **MangoHUD** - Performance overlay
- **GameMode** - Performance optimization

### Development
- **VS Code** - Full-featured code editor
- **Language servers** - For multiple programming languages
- **Docker** - Container support
- **Git** - Version control with GUI tools

### Productivity
- **Clipboard manager** - CopyQ with history
- **File manager** - Dolphin with customizations
- **Terminal** - Kitty with fish shell
- **Screenshot tools** - Flameshot and grim

## Quick Commands

```bash
# Rebuild system
nixos-rebuild switch --flake .#$(hostname)

# Update all packages
nix flake update

# Check system health
nix flake check

# Rollback changes
sudo nixos-rebuild switch --rollback
```

## Getting Help

- **Documentation**: Browse the guides in this directory
- **Troubleshooting**: Check the [troubleshooting guide](troubleshooting.md)
- **Community**: Join NixOS and Hyprland communities
- **Issues**: Report problems on GitHub

## Next Steps

1. **Install NixOS** using the [installation guide](installation.md)
2. **Configure your system** with [configuration guide](configuration.md)
3. **Explore features** in the [features overview](features.md)
4. **Customize** your setup with the [customization guide](customization.md)

---

**Note**: This documentation is continuously updated. Check back for new features and improvements.