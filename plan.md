# 📋 Modular Refactor Execution Plan

## Overview
Convert flat-file architecture to categorical-modular architecture, eliminate Nix-debt, and ensure discoverability.

---

## Phase 0: Preparation

### 0.1 Create backup branch
```bash
git checkout -b dev-refactor0
git add -A
git commit -m "Pre-refactor: backup current configuration"
```

---

## Phase 1: Foundation Setup

### 1.1 Create new directory structure
```bash
mkdir -p vars
mkdir -p lib

mkdir -p modules/nixos/core
mkdir -p modules/nixos/desktop
mkdir -p modules/nixos/hardware
mkdir -p modules/nixos/services
mkdir -p modules/nixos/profiles/surface
mkdir -p modules/nixos/profiles/thinkpad
mkdir -p modules/nixos/gaming

mkdir -p modules/home/cli
mkdir -p modules/home/desktop/hyprland/modules
mkdir -p modules/home/desktop/noctalia_config
mkdir -p modules/home/apps
mkdir -p modules/home/services
mkdir -p modules/home/core
mkdir -p modules/home/ai
```

### 1.2 Create `vars/default.nix`
Plain attribute set from `configuration/user-config.nix` (function wrapper removed)

### 1.3 Create `lib/default.nix`
```nix
{
  mkHost = hostname: extraModules:
    { inputs, nixpkgs, vars, hostName ? hostname }:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs vars hostName; };
      modules = [
        ./hosts/${hostname}/configuration.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs vars hostName; };
          home-manager.users.${vars.username} = {
            imports = [ ./hosts/${hostname}/home.nix ];
          };
        }
      ] ++ extraModules;
    };
}
```

---

## Phase 2: Move System Modules

### 2.1 Core modules (10 files)
Move to `modules/nixos/core/`, create `default.nix` bundle

### 2.2 Desktop modules (8 files)
Move to `modules/nixos/desktop/`, create `default.nix` bundle

### 2.3 Hardware modules (5 files)
Move to `modules/nixos/hardware/`, create `default.nix` bundle

### 2.4 Services modules (5 files)
Move to `modules/nixos/services/`, create `default.nix` bundle

### 2.5 Surface profile (5 files)
Move from `hosts/surface0/system_modules/` to `modules/nixos/profiles/surface/`, create `default.nix`

### 2.6 ThinkPad profile (2 files)
Move from `hosts/thinkpad0/system_modules/` to `modules/nixos/profiles/thinkpad/`, create `default.nix`

### 2.7 Gaming module
Create `modules/nixos/gaming/default.nix` with AAGL integration

### 2.8 Cleanup
```bash
rm -rf hosts/surface0/system_modules
rm -rf hosts/thinkpad0/system_modules
```

---

## Phase 3: Move Home Modules

### 3.1 CLI modules (6 files)
Move to `modules/home/cli/`, create `default.nix` with bundled packages (ripgrep, fd, eza, jq, tree, gh, unzip)

### 3.2 Desktop modules (4 files + Hyprland)
- Move Hyprland config to `modules/home/desktop/hyprland/` (modules/, userprefs.conf, shaders, wallpaper.nix)
- Move screenshot.nix, vicinae.nix, audio-control.nix to `modules/home/desktop/`
- **Keep** monitors.conf in `hosts/*/hypr_config/` (source path remains)
- Move Noctalia config to `modules/home/desktop/noctalia_config/`
- Create `modules/home/desktop/default.nix` bundle

### 3.3 Apps modules (7 files)
Move to `modules/home/apps/`, create `default.nix` bundle

### 3.4 Services modules (6 files)
Move to `modules/home/services/`, create `default.nix` bundle

### 3.5 Core modules (6 files)
Move to `modules/home/core/`, create `default.nix` bundle

### 3.6 AI module
Create `modules/home/ai/default.nix` with llm-agents/opencode

---

## Phase 4: Package Integration

### 4.1 Update modules with packages
- `kitty.nix`: add `home.packages = [ pkgs.kitty ]`
- `fuzzel-config.nix`: add `home.packages = [ pkgs.fuzzel ]`
- `starship.nix`: add `home.packages = [ pkgs.starship ]`
- `vicinae.nix`: add `home.packages = [ inputs.vicinae.packages.${pkgs.system}.default ]`
- `zen-browser.nix`: add `home.packages = [ inputs.zen-browser.packages.${pkgs.system}.default ]`
- `vesktop.nix`: already has package
- `obs.nix`: already has package

### 4.2 Remove old package files
```bash
rm -rf configuration/home/packages/
rm configuration/home/home_modules/packages.nix
rm configuration/home/home_modules/x86_64-packages.nix
```

### 4.3 Update `modules/nixos/core/packages.nix`
Remove llm-agents reference (now in modules/home/ai/)

---

## Phase 5: Update Entry Points

### 5.1 Update `flake.nix`
Replace with simplified version:
- Change nixpkgs to `nixos-unstable`
- Import `vars` and `lib`
- Explicit host configurations showing module bundles
- No complex helper functions, just clear imports

### 5.2-5.7 Update all host files
- `hosts/nixos0/home.nix`: Import home module bundles
- `hosts/nixos0/configuration.nix`: Import jovian, host-specific packages
- `hosts/surface0/home.nix`: Import home module bundles
- `hosts/surface0/configuration.nix`: Import surface profile
- `hosts/thinkpad0/home.nix`: Import home module bundles
- `hosts/thinkpad0/configuration.nix`: Import thinkpad profile

---

## Phase 6: Cleanup & Wallpaper

### 6.1 Move wallpaper to config root
```bash
mv configuration/home/wallpaper/ wallpaper/
```

### 6.2 Remove old directories
```bash
rm -rf configuration/
```

**Keep**: `hosts/*/hypr_config/monitors.conf` (stays in place)

### 6.3 Update imports
Update any references to wallpaper path in home modules

---

## Phase 7: Validation (NO rebuilds)

### 7.1 Flake check
```bash
nix flake check
```

### 7.2 Dry-build all outputs
```bash
nix build .#packages.x86_64-linux.agenix --dry-run
nix build .#formatter.x86_64-linux --dry-run
nix build .#nixosConfigurations.popcat19-nixos0.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.popcat19-surface0.config.system.build.toplevel --dry-run
nix build .#nixosConfigurations.popcat19-thinkpad0.config.system.build.toplevel --dry-run
```

### 7.3 Fix any issues
Address any errors found during dry-build

### 7.4 Format and lint
```bash
nix fmt
```

### 7.5 Commit if passes
```bash
git add -A
git commit -m "Refactor: Convert to categorical-modular architecture"
```

---

## Phase 8: Post-Commit (Optional Rebuilds)

**NOT executed in this plan** - to be done manually by user if validation passes

---

## Final Directory Structure

```
nixos-config/
├── flake.nix (simplified, explicit host configs)
├── vars/default.nix (plain attribute set)
├── lib/default.nix (helper functions)
├── modules/
│   ├── nixos/
│   │   ├── core/ (10 modules)
│   │   ├── desktop/ (8 modules)
│   │   ├── hardware/ (5 modules)
│   │   ├── services/ (5 modules)
│   │   ├── profiles/surface/ (5 modules)
│   │   ├── profiles/thinkpad/ (2 modules)
│   │   └── gaming/ (1 module)
│   └── home/
│       ├── cli/ (6 modules + bundled packages)
│       ├── desktop/ (4 modules + hyprland + noctalia)
│       ├── apps/ (7 modules)
│       ├── services/ (6 modules)
│       ├── core/ (6 modules)
│       └── ai/ (1 module)
├── wallpaper/
└── hosts/
    ├── nixos0/ (hardware, config, home, monitors.conf)
    ├── surface0/ (hardware, config, home, monitors.conf)
    └── thinkpad0/ (hardware, config, home, monitors.conf)
```

---

## Key Benefits

- ✅ Categorized modules by domain
- ✅ Packages integrated with configuration
- ✅ Hardware profiles reusable
- ✅ Explicit flake.nix showing host composition
- ✅ Searchable: find Fish config in `modules/home/cli/fish.nix`
- ✅ Discoverable: clear folder structure
- ✅ Scalable: easy to add new hosts/modules
- ✅ Nix-debt eliminated: adding features = minimal changes
