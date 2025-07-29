# NixOS Configuration Flake

A modern NixOS configuration flake featuring Hyprland compositor, Rose Pine theming, and comprehensive Home Manager integration. This configuration provides a complete, optimized NixOS setup with declarative package management and modular design.

## Overview

This is a personal NixOS configuration that emphasizes:
- **Clean theming consistency** with Rose Pine color scheme
- **Modular design** with organized configuration files
- **Wayland-first** desktop environment using Hyprland
- **Declarative package management** through Nix flakes
- **Gaming support** with Steam, MangoHUD, and game launchers
- **Development tools** and environment setup

## Quick Start

### Prerequisites

- NixOS 23.05 or later with flakes enabled
- Git installed for cloning the repository
- System supporting Wayland compositors

### Installation

1. Clone the repository:
```bash
git clone https://github.com/PopCat19/popcat19-nixos-hm.git ~/nixos-config
cd ~/nixos-config
```

2. **Important**: Replace the hardware configuration with your own:
```bash
sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
echo "hardware-configuration.nix" >> .gitignore
```

3. Update system-specific settings in [`flake.nix`](flake.nix):
   - Change `hostname` from `popcat19-nixos0` to your hostname
   - Change `username` from `popcat19` to your username
   - Verify `system` architecture (default: `x86_64-linux`)

4. Update user settings in [`home.nix`](home.nix):
   - Update `home.username` and `home.homeDirectory`

5. Apply the configuration:
```bash
sudo nixos-rebuild switch --flake .#<your-hostname>
```

## Configuration Structure

### Core Files

- **[`flake.nix`](flake.nix)** - Main flake definition with inputs, overlays, and system configuration
- **[`configuration.nix`](configuration.nix)** - System-level NixOS configuration
- **[`home.nix`](home.nix)** - Home Manager user configuration entry point

### Modular Organization

- **`home_modules/`** - Modular Home Manager configurations:
  - [`packages.nix`](home_modules/packages.nix) - User package declarations
  - [`theme.nix`](home_modules/theme.nix) - Rose Pine theming configuration
  - [`gaming.nix`](home_modules/gaming.nix) - Gaming-related packages and settings
  - [`development.nix`](home_modules/development.nix) - Development tools and environments
  - [`kde.nix`](home_modules/kde.nix) - KDE application configurations
  - [`fish.nix`](home_modules/fish.nix) - Fish shell configuration
  - [`kitty.nix`](home_modules/kitty.nix) - Kitty terminal configuration
  - And more specialized modules...

- **`hypr_config/`** - Hyprland window manager configuration
- **`overlays/`** - Custom package overlays and modifications
- **`syncthing_config/`** - Syncthing file synchronization setup
- **`quickshell_config/`** - QuickShell panel configuration

## Key Features

### Desktop Environment
- **Hyprland** - Modern Wayland compositor with advanced features
- **SDDM** - Display manager with Rose Pine theming
- **Rose Pine** - Consistent theming across GTK/Qt applications
- **Fuzzel** - Fast application launcher
- **Kitty** - GPU-accelerated terminal emulator

### Development Tools
- **Fish shell** with custom functions and Starship prompt
- **Micro** editor with Rose Pine theme
- **Git** configuration with user settings
- **Development packages** for various programming languages

### Gaming Support
- **Steam** with Gamescope session support
- **MangoHUD** performance overlay with Rose Pine theming
- **Anime Game Launcher** (AAGL) for specific games
- **Game streaming** via Sunshine

### System Features
- **Waydroid** - Android app support
- **Virtualization** - QEMU/KVM with virt-manager
- **Hardware control** - OpenRGB, DDC utilities, tablet support
- **Audio** - PipeWire with EasyEffects
- **File sharing** - Syncthing configuration

### Custom Overlays
- **Rose Pine GTK theme** - Enhanced styling
- **Hyprshade 4.0.0** - Blue light filtering with shader support
- **Zrok** - Secure tunneling tool
- **QuickEmu** - Simplified VM management

## Customization

The configuration is designed to be easily customizable:

1. **Packages**: Edit [`home_modules/packages.nix`](home_modules/packages.nix) to add/remove software
2. **Theming**: Modify [`home_modules/theme.nix`](home_modules/theme.nix) for appearance changes
3. **Hyprland**: Adjust [`hypr_config/hyprland.conf`](hypr_config/hyprland.conf) for window manager behavior
4. **System services**: Update [`configuration.nix`](configuration.nix) for system-level changes

## System Requirements

- **Architecture**: x86_64-linux (configurable in flake.nix)
- **Graphics**: Wayland-compatible GPU with proper drivers
- **Memory**: 8GB+ recommended for full feature set
- **Storage**: SSD recommended for optimal performance

## Contributing

This is a personal configuration, but contributions and suggestions are welcome. Please:
- Test changes on clean systems before submitting
- Follow existing modular patterns
- Document significant changes
- Maintain compatibility with the declarative approach

## References

- [NixOS Manual](https://nixos.org/manual/)
- [Home Manager Documentation](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Rose Pine Theme](https://rosepinetheme.com/)
