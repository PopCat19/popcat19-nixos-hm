# Configuration Reference

This document explains the modular architecture and configuration structure of this NixOS flake.

## Architecture Overview

The configuration follows a **modular design** with clear separation of concerns:

- **Centralized configuration** via `user-config.nix`
- **System-level modules** in `system_modules/`
- **User-level modules** in `home_modules/`
- **Specialized configurations** for desktop environments and applications

## Core Configuration Files

### [`user-config.nix`](../user-config.nix)
**Centralized user configuration** - All customizable settings in one place:
- Host configuration (hostname, system architecture)
- User credentials (username, full name, email)
- Default applications and preferences
- Network settings
- Git configuration
- Directory paths

### [`flake.nix`](../flake.nix)
Main flake definition with:
- Input declarations (nixpkgs, home-manager, etc.)
- System configurations
- Overlay definitions
- Output specifications

### [`configuration.nix`](../configuration.nix)
System-level NixOS configuration that:
- Imports system modules
- Configures hardware and kernel parameters
- Sets up system services
- Integrates with the backup system

### [`home.nix`](../home.nix)
Home Manager entry point that:
- Imports user-level modules
- Configures user environment
- Sets up user services

## Modular Organization

### System Modules (`system_modules/`)
Core system components:

- **[`audio.nix`](../system_modules/audio.nix)** - PipeWire, EasyEffects, audio configuration
- **[`boot.nix`](../system_modules/boot.nix)** - Boot loader, kernel parameters, initrd
- **[`core-packages.nix`](../system_modules/core-packages.nix)** - Essential system packages
- **[`display.nix`](../system_modules/display.nix)** - Display server, GPU drivers
- **[`environment.nix`](../system_modules/environment.nix)** - System environment variables
- **[`fonts.nix`](../system_modules/fonts.nix)** - Font configuration and packages
- **[`hardware.nix`](../system_modules/hardware.nix)** - Hardware-specific settings
- **[`localization.nix`](../system_modules/localization.nix)** - Locale, timezone, keyboard
- **[`networking.nix`](../system_modules/networking.nix)** - Network configuration
- **[`packages.nix`](../system_modules/packages.nix)** - System-level packages
- **[`programs.nix`](../system_modules/programs.nix)** - System programs configuration
- **[`services.nix`](../system_modules/services.nix)** - System services (SSH, printing, etc.)
- **[`users.nix`](../system_modules/users.nix)** - User management
- **[`virtualisation.nix`](../system_modules/virtualisation.nix)** - QEMU/KVM setup

### Home Manager Modules (`home_modules/`)
User environment configuration:

- **[`packages.nix`](../home_modules/packages.nix)** - User package declarations
- **[`theme.nix`](../home_modules/theme.nix)** - Rose Pine theming configuration
- **[`gaming.nix`](../home_modules/gaming.nix)** - Gaming packages and settings
- **[`development.nix`](../home_modules/development.nix)** - Development tools
- **[`kde.nix`](../home_modules/kde.nix)** - KDE application configurations
- **[`fish.nix`](../home_modules/fish.nix)** - Fish shell configuration
- **[`kitty.nix`](../home_modules/kitty.nix)** - Kitty terminal setup
- **[`git.nix`](../home_modules/git.nix)** - Git configuration
- **[`micro.nix`](../home_modules/micro.nix)** - Micro editor configuration
- **[`starship.nix`](../home_modules/starship.nix)** - Starship prompt setup
- **[`services.nix`](../home_modules/services.nix)** - User services (Syncthing, etc.)
- **[`android-tools.nix`](../home_modules/android-tools.nix)** - Android development tools
- **[`desktop-theme.nix`](../home_modules/desktop-theme.nix)** - Desktop appearance
- **[`environment.nix`](../home_modules/environment.nix)** - User environment variables
- **[`fcitx5.nix`](../home_modules/fcitx5.nix)** - Input method configuration
- **[`fuzzel-config.nix`](../home_modules/fuzzel-config.nix)** - Application launcher
- **[`mangohud.nix`](../home_modules/mangohud.nix)** - Gaming overlay
- **[`qt-gtk-config.nix`](../home_modules/qt-gtk-config.nix)** - Qt/GTK theming
- **[`screenshot.nix`](../home_modules/screenshot.nix)** - Screenshot tools
- **[`shimboot-project.nix`](../home_modules/shimboot-project.nix)** - Shimboot development
- **[`systemd-services.nix`](../home_modules/systemd-services.nix)** - User systemd services

### Specialized Configurations

#### Hyprland Configuration (`hypr_config/`)
- **[`hyprland.nix`](../hypr_config/hyprland.nix)** - Hyprland module integration
- **[`hyprland.conf`](../hypr_config/hyprland.conf)** - Main Hyprland configuration
- **[`hyprpanel.nix`](../hypr_config/hyprpanel.nix)** - Panel configuration
- **[`hyprpaper.conf`](../hypr_config/hyprpaper.conf)** - Wallpaper settings
- **[`monitors.conf`](../hypr_config/monitors.conf)** - Display configuration
- **[`userprefs.conf`](../hypr_config/userprefs.conf)** - User preferences

#### QuickShell Configuration (`quickshell_config/`)
- **[`quickshell.nix`](../quickshell_config/quickshell.nix)** - QuickShell integration
- **[`shell.qml`](../quickshell_config/shell.qml)** - Main shell interface
- **Modules** for clock, bar, and widgets

#### Syncthing Configuration (`syncthing_config/`)
- **[`home.nix`](../syncthing_config/home.nix)** - User Syncthing setup
- **[`system.nix`](../syncthing_config/system.nix)** - System Syncthing service

## Configuration Flow

1. **User Configuration** → `user-config.nix` provides all customizable values
2. **System Configuration** → `configuration.nix` imports system modules
3. **User Environment** → `home.nix` imports home manager modules
4. **Specialized Configs** → Desktop environments and applications

## Custom Overlays

Located in [`overlays/`](../overlays/):
- **Rose Pine GTK theme** - Enhanced styling
- **Hyprshade 4.0.0** - Blue light filtering
- **Zrok** - Secure tunneling tool
- **QuickEmu** - Simplified VM management

## Backup System

The configuration includes an automatic backup system:
- **Location**: [`backup-user-config.nix`](../backup-user-config.nix)
- **Function**: Creates self-contained backups on rebuild
- **Storage**: Dual locations in `/etc/nixos/` and `~/nixos-config/`
- **Rotation**: 3-backup rotation system
- **Integration**: Automatically triggered on rebuild

## Configuration Variables

All configuration uses centralized variables from `user-config.nix`:

- **System variables**: `host.hostname`, `host.system`
- **User variables**: `user.username`, `user.fullName`, `user.email`
- **Application variables**: `defaultApps.*`
- **Network variables**: `network.*`
- **Path variables**: All user directories

This ensures consistency and easy migration between systems.