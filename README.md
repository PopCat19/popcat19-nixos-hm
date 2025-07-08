## NixOS Configuration Flake

A consolidated NixOS configuration flake featuring Hyprland compositor, Rose Pine theming, and comprehensive Home Manager integration. This configuration provides a complete, optimized NixOS setup with declarative package management and modular design.

The system emphasizes clean theming consistency, efficient workflows, and reliable functionality. All components are tested and verified to work together seamlessly.

## Table of Contents

- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [System Setup](#system-setup)
  - [Hardware Configuration](#hardware-configuration)
  - [User Configuration](#user-configuration)
- [Configuration Overview](#configuration-overview)
- [Configuration Details](#configuration-details)
  - [System Configuration](#system-configuration)
  - [User and Home Configuration](#user-and-home-configuration)
  - [Desktop Environment and Window Manager](#desktop-environment-and-window-manager)
  - [Programs and Packages](#programs-and-packages)
  - [Flake Overlays and Expressions](#flake-overlays-and-expressions)
- [Features](#features)
  - [Fish Shell Functions](#fish-shell-functions)
  - [Hyprland Configuration](#hyprland-configuration)
  - [Fuzzel Application Launcher](#fuzzel-application-launcher)
  - [Hyprshade Blue Light Filter](#hyprshade-blue-light-filter)
  - [Screenshot System](#screenshot-system)
  - [Kitty Terminal](#kitty-terminal)
  - [File Managers](#file-managers)
  - [Archive Management](#archive-management)
  - [Rose Pine Theme Integration](#rose-pine-theme-integration)
  - [Web Browsers](#web-browsers)
  - [Text Editors](#text-editors)
  - [Communication](#communication)
  - [System Monitoring](#system-monitoring)
  - [AI and Machine Learning](#ai-and-machine-learning)
  - [Package Management](#package-management)
  - [Gaming Support](#gaming-support)
  - [Hardware Control](#hardware-control)
  - [Input Methods](#input-methods)
  - [File Sharing](#file-sharing)
  - [Virtualization](#virtualization)
  - [Media Production](#media-production)
  - [Audio Effects](#audio-effects)
  - [Game Streaming](#game-streaming)
- [Troubleshooting Overview](#troubleshooting-overview)
- [Troubleshooting](#troubleshooting)
- [Feedback and Contribution](#feedback-and-contribution)
- [Wiki References](#wiki-references)

## Installation

### Prerequisites

A full, manual NixOS minimal install (following the official guide: https://nixos.org/manual/nixos/stable/#sec-installation-manual) is **highly recommended** for the best experience. This ensures a clean and well-understood base system. NixOS 23.05 or later with flakes enabled in your Nix configuration is required. Git must be installed for cloning the repository. Ensure your system supports Wayland compositors for optimal Hyprland functionality.

### System Setup

Clone the repository to your NixOS configuration directory. Replace the repository URL with the actual location of your configuration.

```bash
git clone https://github.com/PopCat19/popcat19-nixos-hm.git ~/nixos-config
cd ~/nixos-config
```

If you performed a minimal install and your user's home directory wasn't automatically created, create it now (replace `<your-username>` with your actual username):

```bash
sudo mkdir -p /home/<your-username>
sudo chown <your-username>:<your-username> /home/<your-username>
```

### Hardware Configuration

This repository includes a `hardware-configuration.nix` file. If you've booted into NixOS on bare metal, it's **highly recommended** to overwrite the included `hardware-configuration.nix` with your own from `/etc/nixos/`. The one generated during initial NixOS install contains configurations specific to your hardware and is crucial for booting.

> [!WARNING]
> **Critical Step:** You **MUST** overwrite the `hardware-configuration.nix` file in the repository with your *own* from `/etc/nixos/`.  Using the provided `hardware-configuration.nix` can result in an unbootable system or hardware malfunctions.

```bash
# Overwrite the included hardware-configuration.nix
sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix

# Compare the files to ensure the overwrite was successful.
# This command shows the differences between the original and the copied file.
diff /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
```

To prevent accidental overwrites or tracking of your specific hardware configuration, add `hardware-configuration.nix` to your `.gitignore` file:

```bash
echo "hardware-configuration.nix" >> .gitignore
```

This step is crucial for proper hardware detection and driver configuration.

### User Configuration

> [!NOTE]
> Before proceeding, it's crucial to tailor the flake to your specific system and user needs.  Accurate configuration here ensures a smooth transition and proper system functionality.

Update system-specific information within [`flake.nix`](flake.nix). This involves modifying the `hostname` variable to reflect your system's hostname, setting the `username` variable to your actual username, and verifying the system architecture, especially if you're not using the standard `x86_64-linux`. Consult your existing `/etc/nixos/configuration.nix` for accurate values.

> [!NOTE]
> Pay close attention to the values in your current `/etc/nixos/configuration.nix` and `/etc/nixos/hardware-configuration.nix` as these were generated specifically for your hardware during the initial NixOS installation.

Next, customize [`home.nix`](home.nix) with your user-specific settings. Update `home.username` to your username and `home.homeDirectory` to your home directory path. The default username is configured as `popcat19` with hostname `nixos0`. Replace these placeholders with the corresponding values from your `/etc/nixos/configuration.nix` to accurately reflect your user setup.

You might also need to modify [`flake.nix`](flake.nix) and [`configuration.nix`](configuration.nix) to reflect your system's hostname and any other system-wide configurations. Examine your existing `/etc/nixos/configuration.nix` for any user or system-specific paths or preferences and replicate them accurately within your `home.nix`, `flake.nix`, or `configuration.nix` files as appropriate.

For example, in `home.nix`:

```nix
{ config, pkgs, ... }:

{
  home.username = "<your-username>";
  home.homeDirectory = "/home/<your-username>";
}
```

Finally, apply the initial system configuration using the flake. This command, run from within the `~/nixos-config` directory, will build and switch your NixOS configuration, incorporating the settings from the flake alongside elements derived from your original system configuration.

```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#<hostname>
```

## Configuration Overview

The configuration follows a modular design with clear separation of concerns. [`flake.nix`](flake.nix) serves as the main entry point, defining all external dependencies and system parameters. [`configuration.nix`](configuration.nix) handles system-level NixOS configuration including hardware, services, and global settings.

[`home.nix`](home.nix) manages user-specific configurations through Home Manager integration. The configuration imports specialized modules for theming, screenshots, and performance monitoring. This modular approach enables easy customization and maintenance.

## Configuration Details

### System Configuration

[`configuration.nix`](configuration.nix) defines the core system configuration including boot settings, networking, hardware support, and system services. The file configures Hyprland as the primary Wayland compositor with proper XWayland support for legacy applications.

System-level packages include essential tools, virtualization support, and hardware control utilities. The configuration enables Bluetooth, graphics tablet support, and I2C bus access for hardware control. Network settings include firewall configuration optimized for file synchronization services.

### User and Home Configuration

[`home.nix`](home.nix) provides comprehensive user environment configuration through Home Manager. The file imports modular configurations for theming, screenshots, and performance monitoring. User packages are managed through [`home-packages.nix`](home-packages.nix) for better organization.

The configuration includes XDG MIME associations for proper application defaults, systemd user services for desktop integration, and extensive application-specific settings. Font configuration ensures consistent typography across all applications.

### Desktop Environment and Window Manager

[`hypr_config/hyprland.conf`](hypr_config/hyprland.conf) contains the consolidated Hyprland configuration with Rose Pine color scheme integration. The configuration includes comprehensive keybindings, window rules, and animation settings. Monitor configuration is handled through [`hypr_config/monitors.conf`](hypr_config/monitors.conf) for system-specific display settings.

User preferences are managed through [`hypr_config/userprefs.conf`](hypr_config/userprefs.conf) for personalized settings. The configuration supports multiple workspaces, floating windows, and advanced window management features.

### Programs and Packages

Package management is declarative through Nix expressions in [`home-packages.nix`](home-packages.nix). The file organizes packages by category including desktop applications, development tools, media applications, and system utilities. All packages are explicitly declared with clear categorization.

Application configurations are embedded within [`home.nix`](home.nix) or imported from specialized modules. This approach ensures reproducible environments and easy package management across different systems.

### Flake Overlays and Expressions

[`flake.nix`](flake.nix) defines custom overlays for package modifications and additions. The configuration includes overlays for Rose Pine GTK themes, custom package builds, and application-specific patches. Flake inputs manage external dependencies including Home Manager, gaming support, and browser packages.

Custom packages are defined in the [`pkgs/`](pkgs/) directory with proper Nix expressions. The overlay system enables seamless integration of custom packages with the broader NixOS ecosystem.

## Features

### Fish Shell Functions

The configuration includes over 100 custom Fish shell functions for NixOS management and daily workflows. Functions are organized in [`fish_functions/`](fish_functions/) with comprehensive documentation and help systems. Key functions include [`nixos-apply-config`](fish_functions/nixos-apply-config.fish) for configuration management and [`nixpkg`](fish_functions/nixpkg.fish) for package operations.

The [`nixos-help`](fish_functions/nixos-help.fish) function provides comprehensive documentation for all available functions. Functions support command-line help and integrate with the broader NixOS workflow for seamless system management.

### Hyprland Configuration

Hyprland serves as the primary Wayland compositor with comprehensive configuration in [`hypr_config/hyprland.conf`](hypr_config/hyprland.conf). The setup includes Rose Pine color scheme integration, smooth animations, and extensive keybinding support. Window management features include workspace switching, floating windows, and advanced layout options.

The configuration supports multiple monitors through [`hypr_config/monitors.conf`](hypr_config/monitors.conf) and user-specific preferences via [`hypr_config/userprefs.conf`](hypr_config/userprefs.conf). Integration with screenshot tools and application launchers provides a complete desktop experience.

### Fuzzel Application Launcher

Fuzzel provides fast application launching with Rose Pine theming integration. The launcher supports fuzzy search, application icons, and keyboard navigation. Configuration includes custom styling to match the overall desktop theme and optimized performance settings.

### Hyprshade Blue Light Filter

Hyprshade integration provides blue light filtering with shader support. The system includes multiple shader options in [`hypr_config/shaders/`](hypr_config/shaders/) including blue light filters and visual effects. Configuration through [`hypr_config/hyprshade.toml`](hypr_config/hyprshade.toml) enables automatic scheduling and manual control.

### Screenshot System

Custom screenshot system implemented in [`home-screenshot.nix`](home-screenshot.nix) with hyprshade integration for accurate color capture. The system supports full monitor and region screenshots with automatic shader toggling. Screenshots can be saved to files or copied to clipboard with desktop notifications.

The [`screenshot`](home-screenshot.nix) script provides command-line interface for various screenshot modes. Integration with Hyprland keybindings enables quick screenshot capture during daily workflows.

### Kitty Terminal

Kitty terminal emulator with comprehensive Rose Pine theming and optimized performance settings. Configuration includes custom font settings, transparency effects, and integration with the Fish shell. The terminal supports multiple tabs, splits, and advanced text rendering.

### File Managers

Multiple file manager options including Dolphin as the primary choice with KDE integration and Rose Pine theming. Nautilus and Nemo serve as alternative options with proper MIME type associations. All file managers include thumbnail support and integration with the desktop environment.

### Archive Management

Archive management through KDE Ark with support for multiple archive formats. Integration with file managers enables context menu access and proper MIME type handling for compressed files.

### Rose Pine Theme Integration

Comprehensive Rose Pine theming across GTK and Qt applications through [`home-theme.nix`](home-theme.nix). The theming system includes cursor themes, icon themes, and font configuration. Integration covers all desktop applications with consistent color schemes and visual elements.

Theme management tools include [`nwg-look`](home-theme.nix) for GTK configuration and [`kvantummanager`](home-theme.nix) for Qt theming. The [`check-rose-pine-theme`](home-theme.nix) script provides comprehensive theme status checking.

### Web Browsers

Zen Browser serves as the primary web browser with Firefox as an alternative option. Both browsers include Wayland support and integration with the desktop environment. Browser selection is managed through XDG MIME associations.

### Text Editors

Multiple text editor options including Micro as the primary terminal-based editor with Rose Pine theming. Additional editors include Zed, Cursor, VSCodium, and Vim for different use cases. All editors include proper font configuration and theme integration.

### Communication

Vesktop provides Discord functionality with improved Wayland support and better performance compared to the standard Discord client. The application includes proper theming integration and desktop notifications.

### System Monitoring

System monitoring through btop with ROCm support for AMD graphics cards. The monitoring tool provides real-time system information including CPU, memory, and GPU usage with Rose Pine theming integration.

### AI and Machine Learning

Ollama integration with ROCm acceleration for local AI model execution. The service runs as a user-level systemd service with automatic startup and proper resource management for AI workloads.

### Package Management

Declarative package management through Nix expressions with custom functions for package operations. The [`nixpkg`](fish_functions/nixpkg.fish) function provides simplified package management with search, add, and remove operations. All packages are managed through configuration files for reproducible environments.

### Gaming Support

Gaming support includes Steam with Gamescope integration, MangoHUD performance overlay with Rose Pine theming, and various gaming utilities. Configuration in [`home-mangohud.nix`](home-mangohud.nix) provides comprehensive performance monitoring for gaming sessions.

### Hardware Control

Hardware control utilities include OpenRGB for RGB lighting management, DDC utilities for monitor control, and graphics tablet support through OpenTabletDriver. All hardware tools include proper permissions and integration with the desktop environment.

### Input Methods

Fcitx5 input method support with Mozc for Japanese input and Rose Pine theming integration. Configuration includes proper environment variables and desktop integration for multilingual text input.

### File Sharing

LocalSend provides cross-platform file sharing with simple setup and reliable performance. The application includes proper firewall configuration and desktop integration for seamless file transfers.

### Virtualization

Comprehensive virtualization support through QEMU/KVM with virt-manager for virtual machine management. Additional tools include Quickemu for simplified VM creation and Waydroid for Android application support (currently marked as broken).

### Media Production

OBS Studio provides screen recording and streaming capabilities with proper Wayland support and hardware acceleration. The application includes integration with the desktop environment and audio system.

### Audio Effects

EasyEffects provides advanced audio processing for PipeWire with real-time effects and filtering. The service runs automatically and integrates with the desktop audio system for enhanced audio quality.

### Game Streaming

Sunshine and Moonlight integration provides game streaming capabilities with proper hardware acceleration and network configuration. The setup includes automatic firewall configuration and optimized streaming settings.

## Troubleshooting Overview

Common issues typically involve theme application, font rendering, or application integration. The configuration includes diagnostic tools and comprehensive documentation for resolving typical problems. Most issues can be resolved through Home Manager rebuilds or environment variable updates.

## Troubleshooting

This section is currently in draft status. Comprehensive troubleshooting documentation will be added based on user feedback and common issues encountered during system usage.

## Feedback and Contribution

Contributions are welcome through standard Git workflows. Please test changes thoroughly on clean systems before submitting pull requests. Follow existing patterns for configuration organization and maintain compatibility with the modular design approach.

Guidelines include maintaining declarative configurations, documenting significant changes, and testing across multiple systems. Keep configurations modular and follow Nix best practices for sustainable maintenance.

## Wiki References

https://nixos.org/manual/
https://nix-community.github.io/home-manager/
https://wiki.hyprland.org/
https://wiki.archlinux.org/
