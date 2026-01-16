# NixOS Configuration Restructuring Plan

## Overview

This document outlines a comprehensive restructuring of the NixOS configuration repository to organize modules into semantic groups: **minimal**, **main**, and **extras**. This reorganization improves maintainability, enables selective module loading per host, and provides a clear separation between essential, daily-use, and optional functionality.

## Current Structure Analysis

### Existing Module Organization

**System Modules** (`configuration/system/system_modules/`):
- Core: boot, networking, ssh, hardware, users, services, display, audio, virtualisation, fonts, environment, fish, localization, core-packages, packages, tablet, gnome-keyring
- Extended: programs, power-management, vpn, syncthing, dconf, openrgb, stylix-lightdm
- Wayland: hyprland, noctalia

**Home Modules** (`configuration/home/home_modules/`):
- Core: environment, fonts, home-files, services, systemd-services
- Editors: zed, vscodium, micro
- Browsers: zen-browser
- Communication: vesktop
- Development: git, starship, packages (aggregator)
- Media: obs, screenshot, audio-control
- Gaming: mangohud
- Privacy: privacy
- AI/ML: generative, ollama
- Sync: syncthing
- Desktop: stylix, kde-apps, qt-gtk-config, fuzzel-config, kitty, fcitx5
- Custom: noctalia_config, vicinae

**Host-Specific Modules**:
- `surface0/system_modules/`: clear-bdprochot, thermal-config, boot, hardware
- `thinkpad0/system_modules/`: hardware, zram

## Target Structure

```
configuration/
├── system/
│   ├── minimal/
│   │   ├── boot.nix
│   │   ├── networking.nix
│   │   ├── ssh.nix
│   │   ├── hardware.nix
│   │   ├── users.nix
│   │   ├── services.nix
│   │   ├── environment.nix
│   │   ├── fish.nix
│   │   ├── localization.nix
│   │   ├── core-packages.nix
│   │   ├── fonts.nix
│   │   ├── audio.nix
│   │   └── virtualisation.nix
│   ├── main/
│   │   ├── display.nix
│   │   ├── programs.nix
│   │   ├── power-management.nix
│   │   ├── syncthing.nix
│   │   ├── dconf.nix
│   │   ├── openrgb.nix
│   │   ├── stylix-lightdm.nix
│   │   ├── wayland/
│   │   │   ├── hyprland.nix
│   │   │   └── noctalia.nix
│   │   └── flatpak.nix
│   └── extras/
│       ├── vpn.nix
│       └── self-hosting/
│           └── (future modules)
├── home/
│   ├── minimal/
│   │   ├── environment.nix
│   │   ├── fonts.nix
│   │   ├── home-files.nix
│   │   ├── services.nix
│   │   ├── systemd-services.nix
│   │   ├── starship.nix
│   │   ├── micro.nix
│   │   └── git.nix
│   ├── main/
│   │   ├── stylix.nix
│   │   ├── kde-apps.nix
│   │   ├── qt-gtk-config.nix
│   │   ├── fuzzel-config.nix
│   │   ├── kitty.nix
│   │   ├── fcitx5.nix
│   │   ├── zen-browser.nix
│   │   ├── zed.nix
│   │   ├── vscodium.nix
│   │   ├── screenshot.nix
│   │   ├── audio-control.nix
│   │   ├── syncthing.nix
│   │   ├── privacy.nix
│   │   ├── obs.nix
│   │   ├── vesktop.nix
│   │   ├── wayland/
│   │   │   ├── hyprland/
│   │   │   │   ├── hyprland.nix
│   │   │   │   └── modules/
│   │   │   ├── noctalia/
│   │   │   │   └── noctalia.nix
│   │   │   └── (future: niri, mangowc, cosmic-desktop)
│   │   └── packages/
│   │       ├── terminal.nix
│   │       ├── browsers.nix
│   │       ├── media.nix
│   │       ├── communication.nix
│   │       ├── utilities.nix
│   │       ├── editors.nix
│   │       └── development.nix
│   └── extras/
│       ├── gaming/
│       │   └── mangohud.nix
│       ├── ai-ml/
│       │   ├── generative.nix
│       │   └── ollama.nix
│       └── launchers/
│           └── vicinae.nix
└── main/
    └── wayland/
        ├── cosmic/
        ├── mangowc/
        └── niri/
```

## Module Mapping Document

### System Modules Mapping

#### minimal (Boot to TTY with Network and Users)

| Module | Source | Rationale |
|--------|--------|-----------|
| boot.nix | system_modules/boot.nix | Essential for system boot |
| networking.nix | system_modules/networking.nix | Network connectivity required |
| ssh.nix | system_modules/ssh.nix | Remote access capability |
| hardware.nix | system_modules/hardware.nix | Hardware enablement (bluetooth, i2c) |
| users.nix | system_modules/users.nix | User account management |
| services.nix | system_modules/services.nix | Core system services (journald, udisks, dbus) |
| environment.nix | system_modules/environment.nix | System environment variables |
| fish.nix | system_modules/fish.nix | User shell |
| localization.nix | system_modules/localization.nix | Locale and timezone settings |
| core-packages.nix | system_modules/core-packages.nix | Essential system packages |
| fonts.nix | system_modules/fonts.nix | Font configuration for console |
| audio.nix | system_modules/audio.nix | Audio subsystem (pipewire) |
| virtualisation.nix | system_modules/virtualisation.nix | Docker/KVM for development |

#### main (Userland with Wayland Environment)

| Module | Source | Rationale |
|--------|--------|-----------|
| display.nix | system_modules/display.nix | Display manager and greeter |
| programs.nix | system_modules/programs.nix | Additional system programs |
| power-management.nix | system_modules/power-management.nix | Power management for desktop |
| syncthing.nix | system_modules/syncthing.nix | File synchronization service |
| dconf.nix | system_modules/dconf.nix | GSettings configuration |
| openrgb.nix | system_modules/openrgb.nix | RGB lighting control |
| stylix-lightdm.nix | system_modules/stylix-lightdm.nix | Theming for display manager |
| wayland/hyprland.nix | system_modules/hyprland.nix | Wayland compositor |
| wayland/noctalia.nix | system_modules/noctalia.nix | Wayland bar shell |
| flatpak.nix | NEW | Flatpak support (from services.nix) |

#### extras (Optional Modules)

| Module | Source | Rationale |
|--------|--------|-----------|
| vpn.nix | system_modules/vpn.nix | VPN service (optional) |

### Home Modules Mapping

#### minimal (Essential User Configuration)

| Module | Source | Rationale |
|--------|--------|-----------|
| environment.nix | home_modules/environment.nix | User environment variables |
| fonts.nix | home_modules/fonts.nix | User font configuration |
| home-files.nix | home_modules/home-files.nix | User file configuration |
| services.nix | home_modules/services.nix | User services |
| systemd-services.nix | home_modules/systemd-services.nix | User systemd services |
| starship.nix | home_modules/starship.nix | Shell prompt |
| micro.nix | home_modules/micro.nix | Basic text editor |
| git.nix | home_modules/git.nix | Version control |

#### main (Daily Use Applications and Tools)

| Module | Source | Rationale |
|--------|--------|-----------|
| stylix.nix | home_modules/stylix.nix | System-wide theming |
| kde-apps.nix | home_modules/kde-apps.nix | File manager and utilities |
| qt-gtk-config.nix | home_modules/qt-gtk-config.nix | Qt/GTK theming |
| fuzzel-config.nix | home_modules/fuzzel-config.nix | Application launcher |
| kitty.nix | home_modules/kitty.nix | Terminal emulator |
| fcitx5.nix | home_modules/fcitx5.nix | Input method |
| zen-browser.nix | home_modules/zen-browser.nix | Web browser |
| zed.nix | home_modules/zed.nix | Code editor |
| vscodium.nix | home_modules/vscodium.nix | Alternative code editor |
| screenshot.nix | home_modules/screenshot.nix | Screenshot utility |
| audio-control.nix | home_modules/audio-control.nix | Audio control tools |
| syncthing.nix | home_modules/syncthing.nix | Syncthing directory setup |
| privacy.nix | home_modules/privacy.nix | Password management |
| obs.nix | home_modules/obs.nix | Screen recording |
| vesktop.nix | home_modules/vesktop.nix | Discord client |
| wayland/hyprland/hyprland.nix | hypr_config/hyprland.nix | Hyprland config |
| wayland/hyprland/modules/ | hypr_config/modules/ | Hyprland modules |
| wayland/noctalia/noctalia.nix | noctalia_config/noctalia.nix | Noctalia config |
| packages/terminal.nix | packages/home/terminal.nix | Terminal packages |
| packages/browsers.nix | packages/home/browsers.nix | Browser packages |
| packages/media.nix | packages/home/media.nix | Media packages |
| packages/communication.nix | packages/home/communication.nix | Communication packages |
| packages/utilities.nix | packages/home/utilities.nix | Utility packages |
| packages/editors.nix | packages/home/editors.nix | Editor packages |
| packages/development.nix | packages/home/development.nix | Development packages |

#### extras (Optional Features)

| Module | Source | Rationale |
|--------|--------|-----------|
| gaming/mangohud.nix | home_modules/mangohud.nix | Gaming performance overlay |
| ai-ml/generative.nix | home_modules/generative.nix | AI/ML tools |
| ai-ml/ollama.nix | home_modules/ollama.nix | Local LLM service |
| launchers/vicinae.nix | home_modules/vicinae.nix | Alternative launcher |

### Host-Specific Modules

#### surface0 (Retain All)

| Module | Source | Rationale |
|--------|--------|-----------|
| clear-bdprochot.nix | hosts/surface0/system_modules/clear-bdprochot.nix | Surface-specific thermal fix |
| thermal-config.nix | hosts/surface0/system_modules/thermal-config.nix | Surface thermal management |
| boot.nix | hosts/surface0/system_modules/boot.nix | Surface kernel and modules |
| hardware.nix | hosts/surface0/system_modules/hardware.nix | Surface hardware config |

#### thinkpad0 (Retain All)

| Module | Source | Rationale |
|--------|--------|-----------|
| hardware.nix | hosts/thinkpad0/system_modules/hardware.nix | ThinkPad hardware config |
| zram.nix | hosts/thinkpad0/system_modules/zram.nix | ZRAM swap configuration |

## Host Configuration Import Strategy

### nixos0 (Full Stack)

**System Imports:**
```nix
imports = [
  ./hardware-configuration.nix
  ../../configuration/system/minimal/*.nix
  ../../configuration/system/main/*.nix
  ../../configuration/system/extras/*.nix
  inputs.jovian.nixosModules.default
];
```

**Home Imports:**
```nix
imports = [
  ../../configuration/home/minimal/*.nix
  ../../configuration/home/main/*.nix
  ../../configuration/home/extras/*.nix
];
```

### thinkpad0 (Excludes ML/Self-Host and Gaming)

**System Imports:**
```nix
imports = [
  ./hardware-configuration.nix
  ../../configuration/system/minimal/*.nix
  ../../configuration/system/main/*.nix
  ./system_modules/hardware.nix
  ./system_modules/zram.nix
];
```

**Home Imports:**
```nix
imports = [
  ../../configuration/home/minimal/*.nix
  ../../configuration/home/main/*.nix
  # Exclude: extras/gaming, extras/ai-ml
];
```

### surface0 (Follows thinkpad0 + Surface Configs)

**System Imports:**
```nix
imports = [
  ./hardware-configuration.nix
  ../../configuration/system/minimal/*.nix
  ../../configuration/system/main/*.nix
  ./system_modules/clear-bdprochot.nix
  ./system_modules/thermal-config.nix
  ./system_modules/boot.nix
  ./system_modules/hardware.nix
];
```

**Home Imports:**
```nix
imports = [
  ../../configuration/home/minimal/*.nix
  ../../configuration/home/main/*.nix
  # Exclude: extras/gaming, extras/ai-ml
];
```

## Migration Plan

### Phase 1: Create New Directory Structure

1. Create minimal, main, and extras directories:
   ```bash
   mkdir -p configuration/system/{minimal,main,extras}
   mkdir -p configuration/home/{minimal,main,extras}
   mkdir -p configuration/system/main/wayland
   mkdir -p configuration/home/main/wayland/{hyprland,noctalia}
   mkdir -p configuration/home/extras/{gaming,ai-ml,launchers}
   ```

2. Create wayland subdirectories for future compositors:
   ```bash
   mkdir -p configuration/main/wayland/{cosmic,mangowc,niri}
   ```

### Phase 2: Move System Modules

#### Move minimal modules:
```bash
mv configuration/system/system_modules/boot.nix configuration/system/minimal/
mv configuration/system/system_modules/networking.nix configuration/system/minimal/
mv configuration/system/system_modules/ssh.nix configuration/system/minimal/
mv configuration/system/system_modules/hardware.nix configuration/system/minimal/
mv configuration/system/system_modules/users.nix configuration/system/minimal/
mv configuration/system/system_modules/services.nix configuration/system/minimal/
mv configuration/system/system_modules/environment.nix configuration/system/minimal/
mv configuration/system/system_modules/fish.nix configuration/system/minimal/
mv configuration/system/system_modules/localization.nix configuration/system/minimal/
mv configuration/system/system_modules/core-packages.nix configuration/system/minimal/
mv configuration/system/system_modules/fonts.nix configuration/system/minimal/
mv configuration/system/system_modules/audio.nix configuration/system/minimal/
mv configuration/system/system_modules/virtualisation.nix configuration/system/minimal/
```

#### Move main modules:
```bash
mv configuration/system/system_modules/display.nix configuration/system/main/
mv configuration/system/system_modules/programs.nix configuration/system/main/
mv configuration/system/system_modules/power-management.nix configuration/system/main/
mv configuration/system/system_modules/syncthing.nix configuration/system/main/
mv configuration/system/system_modules/dconf.nix configuration/system/main/
mv configuration/system/system_modules/openrgb.nix configuration/system/main/
mv configuration/system/system_modules/stylix-lightdm.nix configuration/system/main/
```

#### Move wayland modules:
```bash
mv configuration/system/system_modules/hyprland.nix configuration/system/main/wayland/
mv configuration/system/system_modules/noctalia.nix configuration/system/main/wayland/
```

#### Move extras modules:
```bash
mv configuration/system/system_modules/vpn.nix configuration/system/extras/
```

#### Create flatpak.nix in main:
Extract flatpak configuration from services.nix and create new module.

### Phase 3: Move Home Modules

#### Move minimal modules:
```bash
mv configuration/home/home_modules/environment.nix configuration/home/minimal/
mv configuration/home/home_modules/fonts.nix configuration/home/minimal/
mv configuration/home/home_modules/home-files.nix configuration/home/minimal/
mv configuration/home/home_modules/services.nix configuration/home/minimal/
mv configuration/home/home_modules/systemd-services.nix configuration/home/minimal/
mv configuration/home/home_modules/starship.nix configuration/home/minimal/
mv configuration/home/home_modules/micro.nix configuration/home/minimal/
mv configuration/home/home_modules/git.nix configuration/home/minimal/
```

#### Move main modules:
```bash
mv configuration/home/home_modules/stylix.nix configuration/home/main/
mv configuration/home/home_modules/kde-apps.nix configuration/home/main/
mv configuration/home/home_modules/qt-gtk-config.nix configuration/home/main/
mv configuration/home/home_modules/fuzzel-config.nix configuration/home/main/
mv configuration/home/home_modules/kitty.nix configuration/home/main/
mv configuration/home/home_modules/fcitx5.nix configuration/home/main/
mv configuration/home/home_modules/zen-browser.nix configuration/home/main/
mv configuration/home/home_modules/zed.nix configuration/home/main/
mv configuration/home/home_modules/vscodium.nix configuration/home/main/
mv configuration/home/home_modules/screenshot.nix configuration/home/main/
mv configuration/home/home_modules/audio-control.nix configuration/home/main/
mv configuration/home/home_modules/syncthing.nix configuration/home/main/
mv configuration/home/home_modules/privacy.nix configuration/home/main/
mv configuration/home/home_modules/obs.nix configuration/home/main/
mv configuration/home/home_modules/vesktop.nix configuration/home/main/
```

#### Move wayland configurations:
```bash
mv configuration/home/hypr_config configuration/home/main/wayland/hyprland/
mv configuration/home/noctalia_config configuration/home/main/wayland/noctalia/
```

#### Move packages:
```bash
mv configuration/home/packages/home/* configuration/home/main/packages/
```

#### Move extras modules:
```bash
mv configuration/home/home_modules/mangohud.nix configuration/home/extras/gaming/
mv configuration/home/home_modules/generative.nix configuration/home/extras/ai-ml/
mv configuration/home/home_modules/ollama.nix configuration/home/extras/ai-ml/
mv configuration/home/home_modules/vicinae.nix configuration/home/extras/launchers/
```

#### Handle remaining files:
- `configuration/home/home_modules/packages.nix` - Update to import from new location
- `configuration/home/home_modules/x86_64-packages.nix` - Move to minimal or main
- `configuration/home/packages/system/*` - Evaluate and place appropriately

### Phase 4: Update Import Statements

#### Update system configuration files:

**Create `configuration/system/minimal.nix`:**
```nix
# Minimal System Configuration
#
# Purpose: Core system configuration for boot to TTY with network and users
# Dependencies: All minimal modules
# Related: main.nix, extras.nix
#
# This module:
# - Imports all minimal system modules
# - Provides base system functionality
{...}: {
  imports = [
    ./minimal/boot.nix
    ./minimal/networking.nix
    ./minimal/ssh.nix
    ./minimal/hardware.nix
    ./minimal/users.nix
    ./minimal/services.nix
    ./minimal/environment.nix
    ./minimal/fish.nix
    ./minimal/localization.nix
    ./minimal/core-packages.nix
    ./minimal/fonts.nix
    ./minimal/audio.nix
    ./minimal/virtualisation.nix
  ];
}
```

**Create `configuration/system/main.nix`:**
```nix
# Main System Configuration
#
# Purpose: Userland with Wayland environment and essential daily tools
# Dependencies: minimal.nix, all main modules
# Related: minimal.nix, extras.nix
#
# This module:
# - Imports all main system modules
# - Provides Wayland environment and desktop functionality
{...}: {
  imports = [
    ./minimal.nix
    ./main/display.nix
    ./main/programs.nix
    ./main/power-management.nix
    ./main/syncthing.nix
    ./main/dconf.nix
    ./main/openrgb.nix
    ./main/stylix-lightdm.nix
    ./main/wayland/hyprland.nix
    ./main/wayland/noctalia.nix
    ./main/flatpak.nix
  ];
}
```

**Create `configuration/system/extras.nix`:**
```nix
# Extras System Configuration
#
# Purpose: Optional modules for self-hosting, development, gaming, privacy
# Dependencies: main.nix
# Related: minimal.nix, main.nix
#
# This module:
# - Imports optional system modules
# - Provides extended functionality
{...}: {
  imports = [
    ./main.nix
    ./extras/vpn.nix
  ];
}
```

#### Update home configuration files:

**Create `configuration/home/minimal.nix`:**
```nix
# Minimal Home Configuration
#
# Purpose: Essential user configuration for basic system usage
# Dependencies: All minimal modules
# Related: main.nix, extras.nix
#
# This module:
# - Imports all minimal home modules
# - Provides basic user environment
{pkgs, inputs, userConfig, hostPlatform, ...}: {
  imports = [
    ./minimal/environment.nix
    ./minimal/fonts.nix
    ./minimal/home-files.nix
    ./minimal/services.nix
    ./minimal/systemd-services.nix
    ./minimal/starship.nix
    ./minimal/micro.nix
    ./minimal/git.nix
  ];
}
```

**Create `configuration/home/main.nix`:**
```nix
# Main Home Configuration
#
# Purpose: Daily use applications and tools for Wayland environment
# Dependencies: minimal.nix, all main modules
# Related: minimal.nix, extras.nix
#
# This module:
# - Imports all main home modules
# - Provides Wayland desktop environment and applications
{pkgs, inputs, userConfig, hostPlatform, ...}: {
  imports = [
    ./minimal.nix
    ./main/stylix.nix
    ./main/kde-apps.nix
    ./main/qt-gtk-config.nix
    ./main/fuzzel-config.nix
    ./main/kitty.nix
    ./main/fcitx5.nix
    ./main/zen-browser.nix
    ./main/zed.nix
    ./main/vscodium.nix
    ./main/screenshot.nix
    ./main/audio-control.nix
    ./main/syncthing.nix
    ./main/privacy.nix
    ./main/obs.nix
    ./main/vesktop.nix
    ./main/wayland/hyprland/hyprland.nix
    ./main/wayland/noctalia/noctalia.nix
  ];

  home.packages = import ./main/packages.nix {inherit pkgs inputs hostPlatform userConfig;};
}
```

**Create `configuration/home/extras.nix`:**
```nix
# Extras Home Configuration
#
# Purpose: Optional modules for gaming, AI/ML, and additional features
# Dependencies: main.nix
# Related: minimal.nix, main.nix
#
# This module:
# - Imports optional home modules
# - Provides gaming, AI/ML, and extended functionality
{...}: {
  imports = [
    ./main.nix
    ./extras/gaming/mangohud.nix
    ./extras/ai-ml/generative.nix
    ./extras/ai-ml/ollama.nix
    ./extras/launchers/vicinae.nix
  ];
}
```

#### Update host configuration files:

**Update `hosts/nixos0/configuration.nix`:**
```nix
# NixOS Configuration for nixos0
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../configuration/system/extras.nix
    inputs.jovian.nixosModules.default
  ];

  networking.hostName = "popcat19-nixos0";

  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
    opentabletdriver
  ];
}
```

**Update `hosts/thinkpad0/configuration.nix`:**
```nix
# NixOS Configuration for thinkpad0
{lib, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../configuration/system/main.nix
    ./system_modules/hardware.nix
    ./system_modules/zram.nix
  ];

  networking.hostName = "popcat19-thinkpad0";

  services.displayManager.autoLogin.enable = lib.mkForce false;
}
```

**Update `hosts/surface0/configuration.nix`:**
```nix
# NixOS Configuration for surface0
{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../configuration/system/main.nix
    ./system_modules/clear-bdprochot.nix
    ./system_modules/thermal-config.nix
    ./system_modules/boot.nix
    ./system_modules/hardware.nix
  ];

  networking.hostName = "popcat19-surface0";
}
```

**Update `hosts/nixos0/home.nix`:**
```nix
# Host-specific home configuration for nixos0
{userConfig, ...}: {
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  imports = [
    ../../configuration/home/extras.nix
  ];

  home.file.".config/hypr/monitors.conf".source = ./hypr_config/monitors.conf;
}
```

**Update `hosts/thinkpad0/home.nix`:**
```nix
# Host-specific home configuration for thinkpad0
{userConfig, ...}: {
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  imports = [
    ../../configuration/home/main.nix
  ];

  home.file.".config/hypr/monitors.conf".source = ./hypr_config/monitors.conf;
}
```

**Update `hosts/surface0/home.nix`:**
```nix
# Host-specific home configuration for surface0
{userConfig, ...}: {
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  imports = [
    ../../configuration/home/main.nix
  ];

  home.file.".config/hypr/monitors.conf".source = ./hypr_config/monitors.conf;
}
```

### Phase 5: Handle Module Dependencies

#### Update display.nix:
Update import paths for wayland modules:
```nix
imports = [
  ./greeter.nix
  ./wayland/hyprland.nix
  ./xdg.nix
];
```

#### Update wayland module paths:
Ensure all wayland modules reference correct paths after restructuring.

#### Update packages.nix:
Update import paths for package lists:
```nix
earlyPackages = [
  (import ../main/packages/terminal.nix {inherit pkgs;})
  (import ../main/packages/browsers.nix {inherit pkgs;})
  # ... etc
];
```

### Phase 6: Clean Up Old Structure

1. Remove empty directories:
   ```bash
   rmdir configuration/system/system_modules
   rmdir configuration/home/home_modules
   ```

2. Remove old configuration files:
   ```bash
   rm configuration/system/configuration.nix
   rm configuration/system/system-extended.nix
   rm configuration/home/home.nix
   ```

3. Update any remaining references in documentation.

### Phase 7: Update User Config References

Ensure `user-config.nix` is properly imported in all new configuration files.

## Validation Checklist

### Pre-Migration Validation

- [ ] Current flake check passes: `nix flake check --impure --accept-flake-config`
- [ ] All hosts can build: `nixos-rebuild dry-run --flake .#<host>`
- [ ] Git status is clean (no uncommitted changes)

### Post-Migration Validation

#### Structure Validation

- [ ] All minimal modules exist in `configuration/system/minimal/`
- [ ] All main modules exist in `configuration/system/main/`
- [ ] All extras modules exist in `configuration/system/extras/`
- [ ] All minimal home modules exist in `configuration/home/minimal/`
- [ ] All main home modules exist in `configuration/home/main/`
- [ ] All extras home modules exist in `configuration/home/extras/`
- [ ] Wayland modules properly organized in subdirectories
- [ ] Package lists moved to `configuration/home/main/packages/`

#### Import Validation

- [ ] `configuration/system/minimal.nix` imports all minimal modules
- [ ] `configuration/system/main.nix` imports minimal and main modules
- [ ] `configuration/system/extras.nix` imports main and extras modules
- [ ] `configuration/home/minimal.nix` imports all minimal home modules
- [ ] `configuration/home/main.nix` imports minimal and main home modules
- [ ] `configuration/home/extras.nix` imports main and extras home modules
- [ ] All host configurations import correct module sets
- [ ] No circular import dependencies

#### Build Validation

- [ ] Flake check passes: `nix flake check --impure --accept-flake-config`
- [ ] nixos0 builds: `nixos-rebuild dry-run --flake .#nixos0`
- [ ] thinkpad0 builds: `nixos-rebuild dry-run --flake .#thinkpad0`
- [ ] surface0 builds: `nixos-rebuild dry-run --flake .#surface0`
- [ ] No evaluation errors or warnings

#### Host-Specific Validation

##### nixos0
- [ ] Imports all modules (minimal + main + extras)
- [ ] Includes gaming modules (mangohud)
- [ ] Includes AI/ML modules (generative, ollama)
- [ ] Includes VPN module
- [ ] Includes Jovian module

##### thinkpad0
- [ ] Imports minimal + main modules only
- [ ] Excludes gaming modules
- [ ] Excludes AI/ML modules
- [ ] Excludes VPN module
- [ ] Includes zram module
- [ ] Autologin disabled

##### surface0
- [ ] Imports minimal + main modules only
- [ ] Excludes gaming modules
- [ ] Excludes AI/ML modules
- [ ] Excludes VPN module
- [ ] Includes clear-bdprochot module
- [ ] Includes thermal-config module
- [ ] Includes Surface-specific boot module
- [ ] Includes Surface-specific hardware module

#### Git Diff Validation

- [ ] Git diff shows expected module moves
- [ ] No unexpected file modifications
- [ ] Import path changes are correct
- [ ] No configuration content changes (only structure)
- [ ] Host-specific modules unchanged

#### Functional Validation

- [ ] Boot to TTY works on all hosts
- [ ] Network connectivity functional
- [ ] User login works
- [ ] Wayland session starts on main/extras hosts
- [ ] Hyprland loads correctly
- [ ] Noctalia bar functions
- [ ] Fuzzel launcher works
- [ ] Syncthing syncs correctly
- [ ] All applications launch

## Rollback Plan

If migration fails:

1. **Immediate Rollback:**
   ```bash
   git checkout -- .
   git clean -fd
   ```

2. **Validation:**
   ```bash
   nix flake check --impure --accept-flake-config
   for host in nixos0 surface0 thinkpad0; do
     nixos-rebuild dry-run --flake .#$host
   done
   ```

3. **Commit Rollback:**
   ```bash
   git add .
   git commit -m "revert(structure): rollback restructuring due to issues"
   ```

## Additional Considerations

### Future Wayland Compositors

The `configuration/main/wayland/` directory structure is prepared for:
- **niri**: Scrollable-tiling Wayland compositor
- **mangowc**: Mango Wayland compositor
- **cosmic-desktop**: COSMIC desktop environment

When adding these compositors:
1. Create subdirectory in `configuration/main/wayland/<compositor>/`
2. Create module files for system and home configuration
3. Update host configurations to import desired compositor
4. Ensure proper theming integration with Stylix

### Flatpak Integration

The `flatpak.nix` module should be created in `configuration/system/main/` by extracting Flatpak configuration from `services.nix`.

### Package Organization

The `packages/` directory structure should be maintained and expanded as needed:
- Keep packages organized by category (terminal, browsers, media, etc.)
- Consider creating architecture-specific package lists
- Document package purposes in module headers

### Module Headers

All moved modules should maintain proper module headers following the established template:
```nix
# Module Name
#
# Purpose: Brief description
# Dependencies: packages | None
# Related: file1.nix, file2.nix | None
#
# This module:
# - What it enables/configures
# - Dependency or related feature
# - Additional internal notes
```

## Summary

This restructuring plan provides:

1. **Clear separation** between minimal, main, and extras functionality
2. **Host-specific module selection** enabling different feature sets per host
3. **Future-proof structure** for additional Wayland compositors
4. **Maintainable organization** with semantic grouping
5. **Comprehensive validation** to ensure all hosts continue to function
6. **Rollback capability** in case of issues

The migration should be executed in phases, with validation after each phase, to ensure a smooth transition without breaking any existing functionality.
