# Configuration

This NixOS configuration uses a modular design with clear separation of concerns.

## Architecture

- **Centralized configuration** via `user-config.nix`
- **System-level modules** in `system_modules/`
- **User-level modules** in `home_modules/`
- **Specialized configurations** for desktop environments and applications

## Core Files

- **[`user-config.nix`](../user-config.nix)** - Centralized user configuration with all customizable settings
- **[`flake.nix`](../flake.nix)** - Main flake definition with inputs and outputs
- **[`configuration.nix`](../configuration.nix)** - System-level NixOS configuration
- **[`home.nix`](../home.nix)** - Home Manager entry point

## System Modules

Core system components in `system_modules/`:
- audio, boot, core-packages, display, environment, fonts
- hardware, localization, networking, packages, programs
- services, users, virtualisation

## Home Modules

User environment configuration in `home_modules/`:
- packages, theme, gaming, development, kde
- fish, kitty, git, micro, starship, services
- android-tools, desktop-theme, environment, fcitx5
- fuzzel-config, mangohud, qt-gtk-config, screenshot
- shimboot-project, systemd-services

## Specialized Configurations

- **Hyprland** - Window manager configuration in `hypr_config/`
- **QuickShell** - Status bar configuration in `quickshell_config/`
- **Syncthing** - File synchronization in `syncthing_config/`

## Custom Overlays

Located in `overlays/`:
- Rose Pine GTK theme
- Hyprshade 4.0.0
- Zrok
- QuickEmu

## Configuration Flow

1. User Configuration → `user-config.nix`
2. System Configuration → `configuration.nix`
3. User Environment → `home.nix`
4. Specialized Configs → Desktop environments and applications

## Variables

All configuration uses centralized variables from `user-config.nix`:
- System variables: `host.hostname`, `host.system`
- User variables: `user.username`, `user.fullName`, `user.email`
- Application variables: `defaultApps.*`
- Network variables: `network.*`
- Path variables: All user directories