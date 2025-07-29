# Custom Package Overlays

This directory contains custom Nix package overlays for the NixOS configuration.

## Packages

### hyprshade.nix

**Version**: 4.0.0 (overlay for latest release)

A Hyprland shade configuration tool that provides screen shader management with scheduling capabilities.

**What's New in v4.0.0:**
- **BREAKING CHANGE**: Updated shaders to use GLES version 3.0
- Better compatibility with modern graphics drivers
- Enhanced shader performance

**Features:**
- **Auto-scheduling**: Set screen shaders to activate automatically on schedule
- **Shader crawling**: Automatically discovers available shaders from multiple sources
- **Manual control**: Turn shaders on/off or toggle them manually
- **Built-in shaders**: Includes blue-light-filter and vibrance shaders
- **Custom shader support**: Can load additional shaders from user directories

**Usage Examples:**
```bash
# List available shaders (crawls system for all available shaders)
hyprshade ls

# Turn on a specific shader
hyprshade on blue-light-filter

# Set up automatic scheduling
hyprshade auto

# Toggle current shader
hyprshade toggle

# Check current shader status
hyprshade current

# Turn off all shaders
hyprshade off

# Install systemd user units for automation
hyprshade install
```

**Package Source:**
- Upstream: https://github.com/loqusion/hyprshade
- Release: https://github.com/loqusion/hyprshade/releases/tag/4.0.0
- Original nixpkgs version: 3.2.1

### rose-pine-gtk-theme-full.nix

Full Rose Pine GTK theme package with enhanced styling from Fausto-Korpsvart.

## Usage in Configuration

These overlays are automatically applied in `flake.nix` and available system-wide. The packages can be referenced as `pkgs.hyprshade` or `pkgs.rose-pine-gtk-theme-full` in your NixOS configuration.

## Building Individual Packages

To test build a specific package:

```bash
# Build hyprshade
nix build .#nixosConfigurations.popcat19-nixos0.pkgs.hyprshade

# Run hyprshade directly
nix run .#nixosConfigurations.popcat19-nixos0.pkgs.hyprshade -- --version
```
