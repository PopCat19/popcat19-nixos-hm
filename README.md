# NixOS Configuration Flake

A modern NixOS configuration flake featuring Hyprland compositor, Rose Pine theming, and comprehensive Home Manager integration. This configuration provides a complete, optimized NixOS setup with declarative package management, modular design, and **crossplatform support**.

## Overview

This is a personal NixOS configuration that emphasizes:
- **Crossplatform support** for x86_64-linux and aarch64-linux (ARM64)
- **Clean theming consistency** with Rose Pine color scheme
- **Modular design** with organized configuration files
- **Wayland-first** desktop environment using Hyprland
- **Declarative package management** through Nix flakes
- **Gaming support** with Steam, MangoHUD, and game launchers (x86_64 optimized)
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

3. **Configure your system settings** in [`user-config.nix`](user-config.nix):
   - Update `host.hostname` to your desired hostname
   - Update `host.system` architecture if needed (default: `x86_64-linux`)
   - Update `user.username` to your username
   - Update `user.fullName` and `user.email` for Git and personal info
   - Customize `defaultApps` to set your preferred applications
   - Modify `network` settings if needed (firewall ports, etc.)

4. Apply the configuration:
```bash
sudo nixos-rebuild switch --flake .#<your-hostname>
```

**Note**: The configuration now uses a centralized [`user-config.nix`](user-config.nix) file for all user-specific settings. You no longer need to edit multiple files to customize the system for different users or machines.

## Configuration Structure

### Core Files

- **[`user-config.nix`](user-config.nix)** - **Centralized user configuration** - All customizable settings in one place
- **[`flake.nix`](flake.nix)** - Main flake definition with inputs, overlays, and system configuration
- **[`configuration.nix`](configuration.nix)** - System-level NixOS configuration
- **[`backup-user-config.nix`](backup-user-config.nix)** - Automatic configuration backup system
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
- **Configuration backup** - Automatic backup system with rotation

### Configuration Backup System

This configuration includes an automatic backup system that creates self-contained backups of your NixOS configuration:

- **Automatic backups** - Created on every `nixos-commit-rebuild-push`
- **Dual locations** - Stored in both `/etc/nixos/` and `~/nixos-config/`
- **3-backup rotation** - Maintains `configuration.nix.bak`, `configuration.nix.bak1`, `configuration.nix.bak2`, `configuration.nix.bak3`
- **Self-contained** - Includes all `system_modules/*` and `hardware-configuration.nix` content inlined
- **Standalone ready** - Works even if modular files are missing
- **Git ignored** - Backup files are excluded from version control

The backup system is implemented in [`backup-user-config.nix`](backup-user-config.nix) and automatically integrated into the system configuration.

### Custom Overlays
- **Rose Pine GTK theme** - Enhanced styling
- **Hyprshade 4.0.0** - Blue light filtering with shader support
- **Zrok** - Secure tunneling tool
- **QuickEmu** - Simplified VM management

## Customization

The configuration is designed to be easily customizable through a centralized configuration system:

### Primary Customization (user-config.nix)

**[`user-config.nix`](user-config.nix)** is your main customization file containing:

- **Host Configuration**: System architecture, hostname
- **User Credentials**: Username, full name, email, shell preference
- **Default Applications**: Browser, terminal, editor, file manager, media players
- **Network Settings**: Firewall ports, trusted interfaces
- **Git Configuration**: User name, email, and additional git settings
- **Directory Paths**: All user directory references

### Advanced Customization

1. **Packages**: Edit [`home_modules/packages.nix`](home_modules/packages.nix) to add/remove software
2. **Theming**: Modify [`home_modules/theme.nix`](home_modules/theme.nix) for appearance changes
3. **Hyprland**: Adjust [`hypr_config/hyprland.conf`](hypr_config/hyprland.conf) for window manager behavior
4. **System services**: Update [`configuration.nix`](configuration.nix) for system-level changes

### Benefits of Centralized Configuration

- **Single Source of Truth**: All user-specific settings in one file
- **Easy Migration**: Copy `user-config.nix` to new systems and rebuild
- **Consistent References**: All modules automatically use your configured values
- **No Hardcoded Values**: Username, hostname, and paths are dynamically referenced
- **Maintainable**: Clear separation between personal config and system logic

## Crossplatform Support

This configuration now supports multiple CPU architectures with automatic feature detection and optimization:

### Supported Architectures

- **x86_64-linux** - Full feature support including ROCm acceleration, gaming, and all packages
- **aarch64-linux (ARM64)** - Optimized support with architecture-specific package selection

### Architecture-Specific Features

#### x86_64-linux Features
- **ROCm GPU acceleration** for AMD graphics cards
- **Gaming support** with Steam, AAGL, and game launchers
- **Full virtualization** with KVM acceleration
- **Hardware control** tools like OpenRGB and DDC utilities
- **All binary packages** including architecture-specific overlays

#### aarch64-linux (ARM64) Features
- **CPU-based AI acceleration** for Ollama (no ROCm)
- **ARM-optimized virtualization** with appropriate QEMU packages
- **Universal packages** that work across architectures
- **Fallback implementations** for x86_64-only packages

### Multi-Architecture Installation

The flake automatically detects your system architecture and applies the appropriate configuration:

```bash
# For x86_64 systems
sudo nixos-rebuild switch --flake .#x86_64-linux

# For ARM64 systems
sudo nixos-rebuild switch --flake .#aarch64-linux

# Or use your hostname (automatically detects architecture from user-config.nix)
sudo nixos-rebuild switch --flake .#<your-hostname>
```

### Architecture Configuration

Update your architecture in [`user-config.nix`](user-config.nix):

```nix
host = {
  system = "x86_64-linux";  # or "aarch64-linux" for ARM64
  hostname = "your-hostname";
};
```

The configuration will automatically:
- Include/exclude architecture-specific packages
- Select appropriate hardware acceleration methods
- Configure virtualization for your platform
- Apply architecture-optimized settings

## System Requirements

### x86_64-linux Requirements
- **Architecture**: x86_64-linux (Intel/AMD 64-bit)
- **Graphics**: Wayland-compatible GPU with proper drivers
- **Memory**: 8GB+ recommended for full feature set
- **Storage**: SSD recommended for optimal performance

### aarch64-linux Requirements
- **Architecture**: aarch64-linux (ARM64)
- **Graphics**: ARM Mali, Adreno, or compatible GPU
- **Memory**: 4GB+ minimum, 8GB+ recommended
- **Storage**: Fast storage recommended (eMMC/SSD)

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
