# Migration Mapping Table

This document provides a complete mapping of all file movements during the refactoring process.

## Core Modules Mapping

| From | To | Notes |
|------|----|-------|
| `system_modules/core_modules/boot.nix` | `modules/core/system-boot.nix` | Essential bootloader config |
| `system_modules/core_modules/hardware.nix` | `modules/core/system-hardware.nix` | Base hardware configuration |
| `system_modules/core_modules/networking.nix` | `modules/core/system-networking.nix` | Network configuration |
| `system_modules/core_modules/users.nix` | `modules/core/system-users.nix` | User management |
| `system_modules/localization.nix` | `modules/core/system-localization.nix` | Locale and timezone |
| `system_modules/environment.nix` | `modules/core/system-environment.nix` | System environment variables |
| `home_modules/environment.nix` | `modules/core/home-environment.nix` | Home environment variables |

## Hardware Modules Mapping

| From | To | Notes |
|------|----|-------|
| `system_modules/tablet.nix` | `modules/hardware/system-tablet.nix` | Tablet configuration |
| `system_modules/openrgb.nix` | `modules/hardware/system-openrgb.nix` | RGB lighting control |
| `system_modules/power-management.nix` | `modules/hardware/system-power-management.nix` | Power settings |

### Host-Specific Hardware (Preserved in Place)

| From | To | Notes |
|------|----|-------|
| `hosts/surface0/system_modules/thermal-config.nix` | `hosts/surface0/system_modules/thermal-config.nix` | Stay in place |
| `hosts/surface0/system_modules/clear-bdprochot.nix` | `hosts/surface0/system_modules/clear-bdprochot.nix` | Stay in place |
| `hosts/thinkpad0/system_modules/zram.nix` | `hosts/thinkpad0/system_modules/zram.nix` | Stay in place |

## Services Modules Mapping

| From | To | Notes |
|------|----|-------|
| `system_modules/services.nix` | `modules/services/system-services.nix` | Base system services |
| `system_modules/vpn.nix` | `modules/services/system-vpn.nix` | VPN configuration |
| `system_modules/ssh.nix` | `modules/services/system-ssh.nix` | SSH server config |
| `system_modules/virtualisation.nix` | `modules/services/system-virtualisation.nix` | Virtualization services |
| `system_modules/distributed-builds.nix` | `modules/services/system-distributed-builds.nix` | Distributed builds client |
| `system_modules/distributed-builds-server.nix` | `modules/services/system-distributed-builds-server.nix` | Distributed builds server |
| `system_modules/gnome-keyring.nix` | `modules/services/system-gnome-keyring.nix` | Keyring service |
| `home_modules/services.nix` | `modules/services/home-services.nix` | Home services |
| `home_modules/systemd-services.nix` | `modules/services/home-systemd-services.nix` | User systemd services |
| `syncthing_config/system.nix` | `modules/services/syncthing/system.nix` | Syncthing system config |
| `syncthing_config/home.nix` | `modules/services/syncthing/home.nix` | Syncthing home config |

## Desktop Modules Mapping

| From | To | Notes |
|------|----|-------|
| `system_modules/display.nix` | `modules/desktop/system-display.nix` | Display server config |
| `system_modules/audio.nix` | `modules/desktop/system-audio.nix` | Audio system config |
| `system_modules/fonts.nix` | `modules/desktop/system-fonts.nix` | System fonts |
| `system_modules/programs.nix` | `modules/desktop/system-programs.nix` | System programs |
| `home_modules/theme.nix` | `modules/desktop/home-theme.nix` | Desktop theme |
| `home_modules/fonts.nix` | `modules/desktop/home-fonts.nix` | User fonts |
| `home_modules/screenshot.nix` | `modules/desktop/home-screenshot.nix` | Screenshot tools |
| `home_modules/kde-apps.nix` | `modules/desktop/home-kde-apps.nix` | KDE applications |
| `home_modules/qt-gtk-config.nix` | `modules/desktop/home-qt-gtk-config.nix` | Qt/GTK theming |
| `home_modules/fuzzel-config.nix` | `modules/desktop/home-fuzzel-config.nix` | Application launcher |
| `home_modules/kitty.nix` | `modules/desktop/home-kitty.nix` | Terminal emulator |
| `home_modules/fish.nix` | `modules/desktop/home-fish.nix` | Shell configuration |
| `home_modules/starship.nix` | `modules/desktop/home-starship.nix` | Shell prompt |
| `home_modules/micro.nix` | `modules/desktop/home-micro.nix` | Text editor |
| `home_modules/fcitx5.nix` | `modules/desktop/home-fcitx5.nix` | Input method |
| `home_modules/mangohud.nix` | `modules/desktop/home-mangohud.nix` | Gaming overlay |
| `home_modules/obs.nix` | `modules/desktop/home-obs.nix` | Streaming software |
| `home_modules/generative.nix` | `modules/desktop/home-generative.nix` | AI tools |
| `home_modules/ollama.nix` | `modules/desktop/home-ollama.nix` | Local AI |
| `home_modules/zen-browser.nix` | `modules/desktop/home-zen-browser.nix` | Web browser |

## Hyprland Integration Mapping

| From | To | Notes |
|------|----|-------|
| `hypr_config/hyprland.nix` | `modules/desktop/hyprland/hyprland.nix` | Main Hyprland config |
| `hypr_config/hyprpanel-common.nix` | `modules/desktop/hyprland/hyprpanel-common.nix` | Panel common config |
| `hypr_config/hyprpanel-home.nix` | `modules/desktop/hyprland/hyprpanel-home.nix` | Panel home config |
| `hypr_config/userprefs.conf` | `modules/desktop/hyprland/userprefs.conf` | User preferences |
| `hypr_config/wallpaper.nix` | `modules/desktop/hyprland/wallpaper.nix` | Wallpaper config |
| `hypr_config/hypr_modules/` | `modules/desktop/hyprland/hypr_modules/` | Hyprland modules |
| `hypr_config/shaders/` | `modules/desktop/hyprland/shaders/` | Shader effects |

## Packages Modules Mapping

| From | To | Notes |
|------|----|-------|
| `system_modules/core-packages.nix` | `modules/packages/system-core-packages.nix` | Essential system packages |
| `system_modules/packages.nix` | `modules/packages/system-packages.nix` | Additional system packages |
| `system_modules/x86_64-packages.nix` | `modules/packages/system-x86_64-packages.nix` | Architecture-specific packages |
| `home_modules/packages.nix` | `modules/packages/home-packages.nix` | Home packages |
| `home_modules/x86_64-packages.nix` | `modules/packages/home-x86_64-packages.nix` | Architecture-specific home packages |
| `packages/home/browsers.nix` | `modules/packages/home/browsers.nix` | Browser packages |
| `packages/home/communication.nix` | `modules/packages/home/communication.nix` | Communication apps |
| `packages/home/media.nix` | `modules/packages/home/media.nix` | Media applications |

## Special Files Mapping

| From | To | Notes |
|------|----|-------|
| `home_modules/fish-functions.nix` | `modules/desktop/home-fish-functions.nix` | Fish shell functions |
| `home_modules/privacy.nix` | `modules/desktop/home-privacy.nix` | Privacy settings |
| `home_modules/home-files.nix` | `modules/desktop/home-files.nix` | Home file management |
| `home_modules/lib/theme.nix` | `modules/desktop/lib/theme.nix` | Theme library |
| `home_modules/screenshot.fish` | `modules/desktop/screenshot.fish` | Screenshot script |
| `system_modules/privacy.nix` | `modules/desktop/system-privacy.nix` | System privacy settings |

## Host Configuration Renaming

| From | To | Notes |
|------|----|-------|
| `hosts/nixos0/configuration.nix` | `hosts/nixos0/default.nix` | Standardize naming |
| `hosts/surface0/configuration.nix` | `hosts/surface0/default.nix` | Standardize naming |
| `hosts/thinkpad0/configuration.nix` | `hosts/thinkpad0/default.nix` | Standardize naming |

## Import Path Updates

### Old Import Patterns → New Import Patterns

| Old Pattern | New Pattern | Example |
|-------------|-------------|---------|
| `../../system_modules/filename.nix` | `../../modules/category/system-filename.nix` | `../../system_modules/audio.nix` → `../../modules/desktop/system-audio.nix` |
| `../../home_modules/filename.nix` | `../../modules/category/home-filename.nix` | `../../home_modules/theme.nix` → `../../modules/desktop/home-theme.nix` |
| `../../hypr_config/filename.nix` | `../../modules/desktop/hyprland/filename.nix` | `../../hypr_config/hyprland.nix` → `../../modules/desktop/hyprland/hyprland.nix` |
| `../../syncthing_config/filename.nix` | `../../modules/services/syncthing/filename.nix` | `../../syncthing_config/system.nix` → `../../modules/services/syncthing/system.nix` |

### Host-Specific Hyprland Updates

| Old Pattern | New Pattern | Example |
|-------------|-------------|---------|
| `./hypr_config/hyprland.nix` | `../../modules/desktop/hyprland/hyprland.nix` | In host configs |
| `./hypr_config/hyprpanel.nix` | `../../modules/desktop/hyprland/hyprpanel-home.nix` | In host configs |

## Directory Structure Changes

### Directories Being Removed
- `system_modules/` (after migration)
- `home_modules/` (after migration)
- `hypr_config/` (after migration)
- `syncthing_config/` (after migration)
- `packages/home/` (after migration)

### Directories Being Created
- `modules/core/`
- `modules/hardware/`
- `modules/services/`
- `modules/desktop/`
- `modules/packages/`
- `modules/desktop/hyprland/`
- `modules/services/syncthing/`
- `modules/packages/home/`

### Directories Preserved
- `lib/` (already in correct location)
- `hosts/` (structure preserved, only file renames)
- `overlays/`
- `flake_modules/`
- `.kilocode/`
- `fish_themes/`
- `wallpaper/`
- `micro_config/`
- `quickshell_config/`

## Validation Checklist

- [ ] All files have been moved to correct locations
- [ ] All import paths updated in configuration files
- [ ] All module headers preserved
- [ ] No duplicate functionality
- [ ] All dependencies maintained
- [ ] Host-specific configurations preserved
- [ ] Hyprland configurations properly integrated
- [ ] Package management consolidated
- [ ] Git tracking updated for new structure

---

**Total Files to Move**: ~60 files
**Total Directories to Create**: 10 directories
**Total Import Path Updates**: ~150+ references across all configs