# NixOS Configuration Structural Refactoring Plan

## Overview
This document outlines the structural refactoring of the NixOS configuration from a flat `system_modules/` and `home_modules/` layout to a category-based organization under `modules/`.

## Current Structure Analysis

### Existing Directories
- `system_modules/` - 24 files including `core_modules/` subdirectory
- `home_modules/` - 23 files including `lib/` subdirectory  
- `hosts/` - Host-specific configurations with some having `system_modules/` subdirectories
- `lib/` - Contains `user-config.nix` (already in correct location)
- `hypr_config/` - Separate Hyprland configuration
- `syncthing_config/` - Split system/home configurations
- `packages/` - Home package definitions

### Module Categorization

#### Core Modules (essential system functionality)
- `system_modules/core_modules/boot.nix`
- `system_modules/core_modules/hardware.nix`
- `system_modules/core_modules/networking.nix`
- `system_modules/core_modules/users.nix`
- `system_modules/localization.nix`
- `system_modules/environment.nix`
- `home_modules/environment.nix`

#### Hardware Modules (physical device configuration)
- `system_modules/tablet.nix`
- `system_modules/openrgb.nix`
- `system_modules/power-management.nix`
- Host-specific: `thermal-config.nix`, `zram.nix`, `clear-bdprochot.nix`

#### Services Modules (background processes)
- `system_modules/services.nix`, `vpn.nix`, `ssh.nix`, `virtualisation.nix`
- `system_modules/distributed-builds*.nix`, `gnome-keyring.nix`
- `home_modules/services.nix`, `systemd-services.nix`
- `syncthing_config/system.nix`, `syncthing_config/home.nix`

#### Desktop Modules (UI/UX and user applications)
- `system_modules/display.nix`, `audio.nix`, `fonts.nix`, `programs.nix`
- `home_modules/theme.nix`, `fonts.nix`, `screenshot.nix`
- `home_modules/kde-apps.nix`, `qt-gtk-config.nix`, `fuzzel-config.nix`
- `home_modules/kitty.nix`, `fish.nix`, `starship.nix`, `micro.nix`
- `home_modules/fcitx5.nix`, `mangohud.nix`, `obs.nix`
- `home_modules/generative.nix`, `ollama-rocm.nix`, `zen-browser.nix`
- `hypr_config/` - All Hyprland configuration files

#### Packages Modules
- `system_modules/core-packages.nix`, `packages.nix`, `x86_64-packages.nix`
- `home_modules/packages.nix`, `x86_64-packages.nix`
- `packages/home/browsers.nix`, `communication.nix`, `media.nix`

## Proposed New Structure

```
nixos-config/
├── flake.nix
├── lib/
│   ├── user-config.nix   (already in place)
│   └── helpers.nix
├── modules/              (new unified directory)
│   ├── core/             (essential system functionality)
│   │   ├── system-boot.nix
│   │   ├── system-hardware.nix
│   │   ├── system-networking.nix
│   │   ├── system-users.nix
│   │   ├── system-localization.nix
│   │   ├── system-environment.nix
│   │   └── home-environment.nix
│   ├── hardware/         (physical hardware configuration)
│   │   ├── system-tablet.nix
│   │   ├── system-openrgb.nix
│   │   ├── system-power-management.nix
│   │   └── host-specific/  (preserve host overrides)
│   ├── services/         (background processes)
│   │   ├── system-services.nix
│   │   ├── system-vpn.nix
│   │   ├── system-ssh.nix
│   │   ├── system-virtualisation.nix
│   │   ├── system-distributed-builds.nix
│   │   ├── system-gnome-keyring.nix
│   │   ├── home-services.nix
│   │   ├── home-systemd-services.nix
│   │   └── syncthing/
│   │       ├── system.nix
│   │       └── home.nix
│   ├── desktop/          (UI/UX and user applications)
│   │   ├── system-display.nix
│   │   ├── system-audio.nix
│   │   ├── system-fonts.nix
│   │   ├── system-programs.nix
│   │   ├── home-theme.nix
│   │   ├── home-fonts.nix
│   │   ├── home-screenshot.nix
│   │   ├── home-kde-apps.nix
│   │   ├── home-qt-gtk-config.nix
│   │   ├── home-fuzzel-config.nix
│   │   ├── home-kitty.nix
│   │   ├── home-fish.nix
│   │   ├── home-starship.nix
│   │   ├── home-micro.nix
│   │   ├── home-fcitx5.nix
│   │   ├── home-mangohud.nix
│   │   ├── home-obs.nix
│   │   ├── home-generative.nix
│   │   ├── home-ollama-rocm.nix
│   │   ├── home-zen-browser.nix
│   │   └── hyprland/      (integrated from hypr_config/)
│   │       ├── hyprland.nix
│   │       ├── hyprpanel-common.nix
│   │       ├── hyprpanel-home.nix
│   │       ├── userprefs.conf
│   │       ├── wallpaper.nix
│   │       └── hypr_modules/
│   └── packages/         (package management)
│       ├── system-core-packages.nix
│       ├── system-packages.nix
│       ├── system-x86_64-packages.nix
│       ├── home-packages.nix
│       ├── home-x86_64-packages.nix
│       └── home/
│           ├── browsers.nix
│           ├── communication.nix
│           └── media.nix
└── hosts/
    └── nixos0/
        └── default.nix   (renamed from configuration.nix)
```

## Migration Strategy

### Key Decisions
1. **Naming Convention**: Use `system-` and `home-` prefixes to maintain clear separation
2. **Host-Specific Configs**: Keep host-specific hardware configs in their current locations
3. **Hyprland Integration**: Move `hypr_config/` under `modules/desktop/hyprland/`
4. **Package Consolidation**: Unify all package-related modules under `modules/packages/`
5. **Preservation**: Maintain all module headers and validation rules from `llm-note.md`

### Migration Phases

#### Phase 1: Preparation and Backup
1. Create backup of current structure
2. Document all current import paths
3. Create migration script
4. Identify all cross-module dependencies

#### Phase 2: Create New Structure
1. Create `modules/` directory with subdirectories
2. Set up category structure: `core/`, `hardware/`, `services/`, `desktop/`, `packages/`
3. Create `host-specific/` subdirectory for hardware overrides

#### Phase 3: File Migration
1. Move system modules with `system-` prefix
2. Move home modules with `home-` prefix
3. Handle special cases:
   - Move `hypr_config/` to `modules/desktop/hyprland/`
   - Move `syncthing_config/` to `modules/services/syncthing/`
   - Move `packages/home/` to `modules/packages/home/`
4. Preserve host-specific hardware configs in place

#### Phase 4: Update Import Paths
1. Update all host `configuration.nix` files
2. Update all `home.nix` files
3. Update any cross-module references
4. Update `flake.nix` if needed

#### Phase 5: Integration and Cleanup
1. Integrate hyprland configurations
2. Consolidate package management
3. Handle host-specific hardware configs
4. Rename `configuration.nix` to `default.nix` in host directories

#### Phase 6: Validation and Testing
1. Run `nix flake check --impure --accept-flake-config`
2. Test dry-run builds for all hosts
3. Validate functionality
4. Clean up old directories

## Risk Mitigation

### Validation Requirements
- All modules must maintain proper headers per `llm-note.md`
- `nix flake check` must pass after migration
- All host configurations must build successfully
- Import paths must be correctly updated
- No functionality should be lost

### Rollback Strategy
- Keep original directories until validation is complete
- Create commit before migration for easy rollback
- Test on one host first before applying to all
- Use `nixos-rebuild dry-run` to validate before actual rebuild

### Dependencies to Monitor
1. Flake inputs and module imports
2. Cross-module dependencies
3. Host-specific configurations
4. Package definitions and overlays
5. Hyprland and desktop environment configurations

## Implementation Notes

### Module Header Requirements
All migrated modules must maintain the standardized header format:
```nix
# <Module Name>
#
# Purpose: <Brief description of its function>
# Dependencies: <pkg1, pkg2, ...> | None
# Related: <file1.nix, file2.nix> | None
#
# This module:
# - <What it enables/configures>
# - <Dependency or related feature>
# - <Additional internal notes>
```

### Import Path Updates
All import statements will need to be updated from:
- `../../system_modules/filename.nix` → `../../modules/category/system-filename.nix`
- `../../home_modules/filename.nix` → `../../modules/category/home-filename.nix`

### Host Configuration Updates
Host configurations will need updated import paths and potentially renamed from `configuration.nix` to `default.nix`.

## Benefits of This Refactoring

1. **Improved Organization**: Related functionality is grouped together
2. **Easier Navigation**: Finding graphics-related configs means going to `modules/hardware/`
3. **Better Maintainability**: Clear separation between system and home modules within categories
4. **Scalability**: Easy to add new modules in appropriate categories
5. **Consistency**: Unified approach to module organization

## Timeline Estimate

- **Phase 1**: 1-2 hours (preparation and backup)
- **Phase 2**: 30 minutes (create structure)
- **Phase 3**: 2-3 hours (file migration)
- **Phase 4**: 2-3 hours (update imports)
- **Phase 5**: 1-2 hours (integration)
- **Phase 6**: 2-3 hours (validation and testing)

**Total Estimated Time**: 8.5-13.5 hours

## Success Criteria

1. All hosts build successfully with `nixos-rebuild dry-run`
2. `nix flake check` passes without errors
3. All functionality is preserved
4. New structure is logical and maintainable
5. All module headers are properly maintained
6. Documentation is updated to reflect new structure

---

*This refactoring plan adheres to the LLM workspace standards defined in `llm-note.md` and maintains all validation requirements.*