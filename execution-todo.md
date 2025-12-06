# NixOS Configuration Refactoring - Execution Todo List

## Phase 1: Preparation and Backup ⏱️ 1-2 hours

- [ ] Create backup of current structure
  - [ ] Backup `system_modules/` directory
  - [ ] Backup `home_modules/` directory
  - [ ] Backup `hosts/` directory
  - [ ] Create git commit with current state

- [ ] Document all current import paths
  - [ ] Scan all `configuration.nix` files for imports
  - [ ] Scan all `home.nix` files for imports
  - [ ] Document cross-module dependencies
  - [ ] Create import path mapping table

- [ ] Create migration script
  - [ ] Script to create new directory structure
  - [ ] Script to move and rename files
  - [ ] Script to update import paths
  - [ ] Script to validate syntax

- [ ] Identify all cross-module dependencies
  - [ ] Map dependencies between system modules
  - [ ] Map dependencies between home modules
  - [ ] Map system-home module dependencies
  - [ ] Document special cases

## Phase 2: Create New Structure ⏱️ 30 minutes

- [ ] Create `modules/` directory
- [ ] Create category subdirectories
  - [ ] `modules/core/`
  - [ ] `modules/hardware/`
  - [ ] `modules/services/`
  - [ ] `modules/desktop/`
  - [ ] `modules/packages/`
- [ ] Create special subdirectories
  - [ ] `modules/hardware/host-specific/`
  - [ ] `modules/services/syncthing/`
  - [ ] `modules/desktop/hyprland/`
  - [ ] `modules/desktop/hyprland/hypr_modules/`
  - [ ] `modules/packages/home/`

## Phase 3: File Migration ⏱️ 2-3 hours

### Core Modules Migration
- [ ] Move `system_modules/core_modules/boot.nix` → `modules/core/system-boot.nix`
- [ ] Move `system_modules/core_modules/hardware.nix` → `modules/core/system-hardware.nix`
- [ ] Move `system_modules/core_modules/networking.nix` → `modules/core/system-networking.nix`
- [ ] Move `system_modules/core_modules/users.nix` → `modules/core/system-users.nix`
- [ ] Move `system_modules/localization.nix` → `modules/core/system-localization.nix`
- [ ] Move `system_modules/environment.nix` → `modules/core/system-environment.nix`
- [ ] Move `home_modules/environment.nix` → `modules/core/home-environment.nix`

### Hardware Modules Migration
- [ ] Move `system_modules/tablet.nix` → `modules/hardware/system-tablet.nix`
- [ ] Move `system_modules/openrgb.nix` → `modules/hardware/system-openrgb.nix`
- [ ] Move `system_modules/power-management.nix` → `modules/hardware/system-power-management.nix`
- [ ] Keep host-specific hardware configs in place
  - [ ] `hosts/surface0/system_modules/thermal-config.nix`
  - [ ] `hosts/surface0/system_modules/clear-bdprochot.nix`
  - [ ] `hosts/thinkpad0/system_modules/zram.nix`

### Services Modules Migration
- [ ] Move `system_modules/services.nix` → `modules/services/system-services.nix`
- [ ] Move `system_modules/vpn.nix` → `modules/services/system-vpn.nix`
- [ ] Move `system_modules/ssh.nix` → `modules/services/system-ssh.nix`
- [ ] Move `system_modules/virtualisation.nix` → `modules/services/system-virtualisation.nix`
- [ ] Move `system_modules/distributed-builds.nix` → `modules/services/system-distributed-builds.nix`
- [ ] Move `system_modules/distributed-builds-server.nix` → `modules/services/system-distributed-builds-server.nix`
- [ ] Move `system_modules/gnome-keyring.nix` → `modules/services/system-gnome-keyring.nix`
- [ ] Move `home_modules/services.nix` → `modules/services/home-services.nix`
- [ ] Move `home_modules/systemd-services.nix` → `modules/services/home-systemd-services.nix`
- [ ] Move `syncthing_config/system.nix` → `modules/services/syncthing/system.nix`
- [ ] Move `syncthing_config/home.nix` → `modules/services/syncthing/home.nix`

### Desktop Modules Migration
- [ ] Move `system_modules/display.nix` → `modules/desktop/system-display.nix`
- [ ] Move `system_modules/audio.nix` → `modules/desktop/system-audio.nix`
- [ ] Move `system_modules/fonts.nix` → `modules/desktop/system-fonts.nix`
- [ ] Move `system_modules/programs.nix` → `modules/desktop/system-programs.nix`
- [ ] Move `home_modules/theme.nix` → `modules/desktop/home-theme.nix`
- [ ] Move `home_modules/fonts.nix` → `modules/desktop/home-fonts.nix`
- [ ] Move `home_modules/screenshot.nix` → `modules/desktop/home-screenshot.nix`
- [ ] Move `home_modules/kde-apps.nix` → `modules/desktop/home-kde-apps.nix`
- [ ] Move `home_modules/qt-gtk-config.nix` → `modules/desktop/home-qt-gtk-config.nix`
- [ ] Move `home_modules/fuzzel-config.nix` → `modules/desktop/home-fuzzel-config.nix`
- [ ] Move `home_modules/kitty.nix` → `modules/desktop/home-kitty.nix`
- [ ] Move `home_modules/fish.nix` → `modules/desktop/home-fish.nix`
- [ ] Move `home_modules/starship.nix` → `modules/desktop/home-starship.nix`
- [ ] Move `home_modules/micro.nix` → `modules/desktop/home-micro.nix`
- [ ] Move `home_modules/fcitx5.nix` → `modules/desktop/home-fcitx5.nix`
- [ ] Move `home_modules/mangohud.nix` → `modules/desktop/home-mangohud.nix`
- [ ] Move `home_modules/obs.nix` → `modules/desktop/home-obs.nix`
- [ ] Move `home_modules/generative.nix` → `modules/desktop/home-generative.nix`
- [ ] Move `home_modules/ollama.nix` → `modules/desktop/home-ollama.nix`
- [ ] Move `home_modules/zen-browser.nix` → `modules/desktop/home-zen-browser.nix`

### Hyprland Integration
- [ ] Move `hypr_config/hyprland.nix` → `modules/desktop/hyprland/hyprland.nix`
- [ ] Move `hypr_config/hyprpanel-common.nix` → `modules/desktop/hyprland/hyprpanel-common.nix`
- [ ] Move `hypr_config/hyprpanel-home.nix` → `modules/desktop/hyprland/hyprpanel-home.nix`
- [ ] Move `hypr_config/userprefs.conf` → `modules/desktop/hyprland/userprefs.conf`
- [ ] Move `hypr_config/wallpaper.nix` → `modules/desktop/hyprland/wallpaper.nix`
- [ ] Move `hypr_config/hypr_modules/` → `modules/desktop/hyprland/hypr_modules/`
- [ ] Move `hypr_config/shaders/` → `modules/desktop/hyprland/shaders/`

### Packages Modules Migration
- [ ] Move `system_modules/core-packages.nix` → `modules/packages/system-core-packages.nix`
- [ ] Move `system_modules/packages.nix` → `modules/packages/system-packages.nix`
- [ ] Move `system_modules/x86_64-packages.nix` → `modules/packages/system-x86_64-packages.nix`
- [ ] Move `home_modules/packages.nix` → `modules/packages/home-packages.nix`
- [ ] Move `home_modules/x86_64-packages.nix` → `modules/packages/home-x86_64-packages.nix`
- [ ] Move `packages/home/browsers.nix` → `modules/packages/home/browsers.nix`
- [ ] Move `packages/home/communication.nix` → `modules/packages/home/communication.nix`
- [ ] Move `packages/home/media.nix` → `modules/packages/home/media.nix`

### Special Files
- [ ] Move `home_modules/fish-functions.nix` → `modules/desktop/home-fish-functions.nix`
- [ ] Move `home_modules/fish.nix` → `modules/desktop/home-fish.nix`
- [ ] Move `home_modules/privacy.nix` → `modules/desktop/home-privacy.nix`
- [ ] Move `home_modules/home-files.nix` → `modules/desktop/home-files.nix`
- [ ] Move `home_modules/lib/theme.nix` → `modules/desktop/lib/theme.nix`
- [ ] Move `home_modules/screenshot.fish` → `modules/desktop/screenshot.fish`
- [ ] Move `system_modules/privacy.nix` → `modules/desktop/system-privacy.nix`

## Phase 4: Update Import Paths ⏱️ 2-3 hours

### Host Configuration Updates
- [ ] Update `hosts/nixos0/configuration.nix` imports
- [ ] Update `hosts/surface0/configuration.nix` imports
- [ ] Update `hosts/thinkpad0/configuration.nix` imports
- [ ] Update `hosts/nixos0/home.nix` imports
- [ ] Update `hosts/surface0/home.nix` imports
- [ ] Update `hosts/thinkpad0/home.nix` imports

### Host-Specific Hyprland Config Updates
- [ ] Update `hosts/nixos0/hypr_config/hyprland.nix` imports
- [ ] Update `hosts/surface0/hypr_config/hyprland.nix` imports
- [ ] Update `hosts/thinkpad0/hypr_config/hyprland.nix` imports

### Cross-Module Reference Updates
- [ ] Scan and update any cross-module imports
- [ ] Update any absolute path references
- [ ] Update any documentation references

### Flake Updates
- [ ] Check if `flake.nix` needs updates
- [ ] Update any flake module references
- [ ] Update any helper functions

## Phase 5: Integration and Cleanup ⏱️ 1-2 hours

### Host Configuration Renaming
- [ ] Rename `hosts/nixos0/configuration.nix` → `hosts/nixos0/default.nix`
- [ ] Rename `hosts/surface0/configuration.nix` → `hosts/surface0/default.nix`
- [ ] Rename `hosts/thinkpad0/configuration.nix` → `hosts/thinkpad0/default.nix`

### Integration Tasks
- [ ] Update hyprland import paths in host configs
- [ ] Update syncthing import paths in host configs
- [ ] Consolidate any duplicate functionality
- [ ] Update any remaining references

### Cleanup
- [ ] Remove empty `hypr_config/` directory
- [ ] Remove empty `syncthing_config/` directory
- [ ] Remove empty `packages/home/` directory
- [ ] Update `.gitignore` if needed

## Phase 6: Validation and Testing ⏱️ 2-3 hours

### Syntax Validation
- [ ] Run `nix flake check --impure --accept-flake-config`
- [ ] Fix any syntax errors
- [ ] Check all module headers are intact
- [ ] Validate all import paths are correct

### Build Testing
- [ ] Test `nixos-rebuild dry-run --flake .#popcat19-nixos0`
- [ ] Test `nixos-rebuild dry-run --flake .#popcat19-surface0`
- [ ] Test `nixos-rebuild dry-run --flake .#popcat19-thinkpad0`
- [ ] Fix any build errors

### Functionality Validation
- [ ] Verify all modules are properly imported
- [ ] Check for any missing dependencies
- [ ] Validate package installations
- [ ] Test service configurations

### Final Cleanup
- [ ] Remove old `system_modules/` directory
- [ ] Remove old `home_modules/` directory
- [ ] Remove any backup files
- [ ] Create final commit

## Success Validation

- [ ] All hosts build successfully with `nixos-rebuild dry-run`
- [ ] `nix flake check` passes without errors
- [ ] All functionality is preserved
- [ ] New structure is logical and maintainable
- [ ] All module headers are properly maintained
- [ ] Documentation is updated

## Rollback Plan (if needed)

- [ ] Git revert to pre-migration commit
- [ ] Restore from backup if git revert fails
- [ ] Document any issues encountered
- [ ] Plan alternative approach if needed

---

**Total Estimated Time**: 8.5-13.5 hours
**Priority Order**: Complete each phase fully before proceeding to next
**Validation Point**: After each phase, run basic syntax checks