# nixos-config Technical Specification

**Status:** Stable (Multi-Host Production)  
**Target:** NixOS 24.05+ with Flakes, Hyprland Wayland Desktop  
**License:** Personal Configuration (Unlicensed)

---

## 1. Project Identity

### What This Is
- Declarative multi-host NixOS configuration using Nix Flakes
- Modular system architecture with per-host customization support
- Rose Pine themed desktop environment (Hyprland + KDE apps)
- Reproducible builds with centralized user configuration
- Distributed build infrastructure for cross-machine compilation

### What This Is Not
- A pre-packaged NixOS distribution or installer
- A general-purpose framework (highly personalized)
- A stable API (breaking changes expected for personal use)
- A desktop environment (uses Hyprland compositor)

### Tested Hardware/Environments
```
nixos0 (Desktop Workstation)
 ├─ Status: Fully Working
 ├─ CPU: AMD Ryzen 5 5500 (6c/12t)
 ├─ GPU: AMD Radeon (ROCm-capable)
 ├─ Role: Primary development + gaming + build server + GitHub Actions runner
 └─ Features: Dual monitor (DP-3 1920x1080@165Hz + HDMI-A-1 1920x1080@60Hz rotated), OpenRGB, gaming, AI (Ollama ROCm), GitHub Actions runners (temporarily disabled)

 surface0 (Mobile Workstation)
 ├─ Status: Working
 ├─ Device: Microsoft Surface Pro (Intel i5-8350U)
 ├─ Role: Mobile development + distributed builds client
 └─ Features: Touch/pen input, thermal management, BD-PROCHOT workaround, auto-cpufreq, distributed builds, WiFi stability fixes

 thinkpad0 (Portable Laptop)
 ├─ Status: Working
 ├─ Device: ThinkPad series laptop
 ├─ Role: Secondary portable machine
 └─ Features: External HDMI (Dell S2415H), TLP power management, ThinkPad ACPI, distributed builds
```

### Supported Platforms (Infrastructure Only)
```
x86_64-linux (primary), aarch64-linux (untested infrastructure exists)
└─ Note: Only x86_64-linux actively tested across all hosts
```

---

## 2. System Architecture

### Layer Model
```
User Applications (Browser, IDE, Games)
    ↓
Home Manager (User-specific configuration)
    ↓
NixOS System (System services, drivers)
    ↓
Nix Flakes (Declarative inputs/outputs)
    ↓
Hardware Abstraction (kernel, firmware)
    ↓
Physical Hardware (CPU, GPU, peripherals)
```

### Configuration Layout
```
nixos-config/ (project root)
├─ flake.nix                    - Flake entry point, host definitions
├─ flake.lock                   - Pinned input versions
├─ user-config.nix              - Centralized user/host metadata
│
├─ system_modules/              - System-level NixOS modules
│  ├─ core_modules/             - Essential system configuration
│  │  ├─ boot.nix               - Bootloader, kernel
│  │  ├─ hardware.nix           - Hardware devices
│  │  ├─ networking.nix         - Network + firewall
│  │  └─ users.nix              - User accounts
│  ├─ [feature].nix             - Optional system features
│  └─ x86_64-packages.nix       - Architecture-specific packages
│
├─ home_modules/                - Home Manager user configuration
│  ├─ packages.nix              - Package list aggregator
│  ├─ theme.nix                 - Rose Pine theme application
│  ├─ [app]-config.nix          - Application-specific configs
│  └─ lib/theme.nix             - Theme utilities library
│
├─ hosts/                       - Per-host configurations
│  ├─ [hostname]/
│  │  ├─ configuration.nix      - Host system config
│  │  ├─ hardware-configuration.nix - Generated hardware config
│  │  ├─ home.nix               - Host home-manager config
│  │  ├─ hypr_config/           - Host-specific Hyprland config
│  │  └─ system_modules/        - Host-specific system modules
│  ├─ minimal.nix               - Template for new hosts
│  └─ home-minimal.nix          - Template for home configs
│
├─ overlays/                    - Nix package overlays
│  ├─ rose-pine-*.nix           - Rose Pine theme packages
│  ├─ rocm-pinned.nix           - ROCm version pinning
│  ├─ rocm-hipblas.nix          - ROCm hipblas compatibility
│  └─ fcitx5-fix.nix            - Input method fixes
│
├─ packages/                    - Organized package lists
│  ├─ home/                     - User-space packages by category
│  └─ system/                   - System-level packages by category
│
├─ hypr_config/                 - Shared Hyprland configuration
│  ├─ hyprland.nix              - Hyprland module entry point
│  ├─ hypr_modules/             - Modular Hyprland settings
│  │  ├─ colors.nix             - Rose Pine color definitions
│  │  ├─ keybinds.nix           - Keyboard shortcuts
│  │  ├─ window-rules.nix       - Window behavior rules
│  │  └─ [other].nix            - Other Hyprland settings
│  ├─ shaders/                  - GLSL shader files
│  └─ wallpaper.nix             - Dynamic wallpaper selection
│
├─ syncthing_config/            - Cross-host file sync
│  ├─ system.nix                - System service config
│  └─ home.nix                  - User directory setup
│
├─ quickshell_config/           - Status bar (alternative)
├─ micro_config/                - Text editor themes
└─ fish_themes/                 - Shell color schemes
```

### Critical Patches/Modifications
```
fcitx5-qt6
└─ fcitx5-fix.nix
   ├─ Removes Qt6 variant to fix build issues
   ├─ Required: Qt6 incompatibility in nixpkgs
   └─ Source: Local overlay (temporary fix)

rocmPackages
└─ rocm-pinned.nix
   ├─ Pins ROCm to commit 18dd725c2960
   ├─ Reason: Prevents breaking changes in ROCm stack
   └─ Source: nixpkgs snapshot (2024-12)

rocm-hipblas
└─ rocm-hipblas.nix
   ├─ ROCm hipblas compatibility overlay
   ├─ Reason: Provides hipblas compatibility for ROCm packages
   └─ Source: Local overlay

rose-pine-gtk-theme-full
└─ rose-pine-gtk-theme-full.nix
   ├─ Custom SCSS build of Rose Pine GTK theme
   ├─ Reason: Borderless variant not in nixpkgs
   └─ Source: Fausto-Korpsvart/Rose-Pine-GTK-Theme

surface0 Thermal Management
└─ thermal-config.nix + clear-bdprochot.nix
   ├─ Implements aggressive thermal limits (65°C passive trip)
   ├─ Clears BD-PROCHOT bit (MSR 0x1FC) on boot
   ├─ Reason: Surface Pro thermal throttling issue
   └─ Source: nixos-hardware + custom systemd service

surface0 WiFi Stability
└─ services.nix + hardware.nix
   ├─ Disables WiFi power saving (mwifiex_pcie)
   ├─ Disables USB autosuspend for WiFi
   ├─ Sets reg_alpha2=US for regulatory domain
   └─ Reason: mwifiex_pcie driver instability

thinkpad0 Power Management
└─ power-management.nix
   ├─ TLP with AC performance mode
   └─ Reason: Optimize for AC performance while allowing battery balance

OpenRGB Support
└─ openrgb.nix
   ├─ Enables OpenRGB RGB control service
   ├─ Reason: RGB lighting control for gaming peripherals
   └─ Applied to: nixos0 (gaming workstation)

Tablet Support
└─ tablet.nix
   ├─ Enables OpenTabletDriver for graphics tablets
   ├─ Reason: Graphics tablet input support
   └─ Applied to: Available for all hosts

Kernel Module Blacklist
└─ boot.nix
   ├─ Blacklists snd_seq_dummy kernel module
   ├─ Reason: Prevents audio system conflicts
   └─ Applied to: All hosts

GitHub Actions Runner (nixos0)
└─ github-runner/
   ├─ Self-hosted runners for personal repositories (temporarily disabled)
   ├─ Uses agenix for encrypted token management
   ├─ Docker integration for containerized builds
   ├─ Repositories: PopCat19/nixos-shimboot (2 runners), PopCat19/popcat19-nixos-hm (1 runner)
   └─ Source: github-nix-ci flake input (commented out due to runCommandNoCC deprecation)
```

---

## 3. Component Reference

### Flake Inputs
```
nixpkgs
├─ Purpose: Core NixOS packages
├─ Branch: nixos-unstable
├─ Related: All system/home modules
└─ Provides: Base system packages, overlays

home-manager
├─ Purpose: User environment management
├─ Dependencies: nixpkgs
├─ Related: home_modules/*, hosts/*/home.nix
└─ Provides: User-level declarative configuration

chaotic
├─ Purpose: Community package extensions
├─ Dependencies: nixpkgs
├─ Related: None (system extension)
└─ Provides: Additional community packages

quickshell
├─ Purpose: Status bar (alternative to hyprpanel)
├─ Dependencies: nixpkgs
├─ Related: quickshell_config/
└─ Provides: Customizable status bar

zen-browser
├─ Purpose: Privacy-focused browser
├─ Dependencies: nixpkgs
├─ Related: home_modules/zen-browser.nix
└─ Provides: Zen Browser with PWA support

github-nix-ci
├─ Purpose: Self-hosted GitHub Actions runners (temporarily disabled)
├─ Dependencies: nixpkgs
├─ Related: hosts/nixos0/github-runner/
└─ Provides: GitHub Actions runner service with Nix support
└─ Status: Commented out due to runCommandNoCC deprecation

agenix
├─ Purpose: Secrets management with age encryption
├─ Dependencies: nixpkgs
├─ Related: hosts/nixos0/github-runner/secrets/
└─ Provides: Encrypted secrets for GitHub runner tokens

rose-pine-hyprcursor
├─ Purpose: Cursor theme
├─ Dependencies: None
├─ Related: home_modules/theme.nix
└─ Provides: Rose Pine cursor theme package

catppuccin-nix
├─ Purpose: Catppuccin theme integration
├─ Dependencies: nixpkgs
├─ Related: None (available for future use)
└─ Provides: Catppuccin theme variants

aagl (Anime Game Launcher)
├─ Purpose: Gaming support
├─ Dependencies: nixpkgs
├─ Related: flake_modules/modules.nix
└─ Provides: Game launcher integration (x86_64 only)
```

### Module Organization
```
system_modules/*.nix
├─ Purpose: System-level NixOS configuration
├─ Dependencies: nixpkgs, user-config.nix
├─ Related: hosts/*/configuration.nix
└─ Provides: Bootloader, services, drivers, firewall

home_modules/*.nix
├─ Purpose: User environment configuration
├─ Dependencies: home-manager, user-config.nix
├─ Related: hosts/*/home.nix
└─ Provides: Applications, themes, dotfiles

hypr_config/*.nix
├─ Purpose: Hyprland compositor settings
├─ Dependencies: home-manager, hyprland
├─ Related: hosts/*/hypr_config/ overrides
└─ Provides: Keybinds, window rules, theming

overlays/*.nix
├─ Purpose: Package modifications/additions
├─ Dependencies: nixpkgs
├─ Related: flake_modules/overlays.nix
└─ Provides: Custom package versions, fixes

packages/*/*.nix
├─ Purpose: Organized package lists by category
├─ Dependencies: nixpkgs
├─ Related: home_modules/packages.nix (aggregator)
└─ Provides: Categorized package selections
```

### Host Configuration Variants
```
nixos0/ (Desktop Workstation)
├─ Purpose: Primary development + gaming machine + CI/CD server
├─ Size Target: Full-featured desktop
├─ CPU: AMD Ryzen 5 5500
├─ GPU: AMD Radeon RX 6600 XT (ROCm 6.3.3)
├─ Display: Dual monitor setup (DP-3, DP-4)
├─ Monitors: DP-3 (1920x1080@165Hz primary) + HDMI-A-1 (1920x1080@60Hz portrait)
├─ Packages: zluda (CUDA on AMD), OpenRGB, gaming stack
└─ Features: Gaming, AI (Ollama ROCm), development, distributed builds server, OpenRGB, GitHub Actions runners (temporarily disabled)
└─ Home Modules: All modules including ollama-rocm, mangohud, generative
└─ System Modules: github-runner (self-hosted CI/CD)

surface0/ (Mobile Workstation)
├─ Purpose: Portable development machine
├─ Size Target: Mobile-optimized
├─ CPU: Intel i5-8350U (4c/8t, 1.7GHz-3.6GHz)
├─ GPU: Intel UHD Graphics 620
├─ Display: Internal eDP-1 (2736x1824 @ 1.5 scale) + optional external
├─ Extends: Base configuration
├─ Adds: Surface-specific boot, hardware, services, thermal, BD-PROCHOT fix
├─ Display: Internal + optional external
├─ Packages: Surface-control, iptsd (touch/pen), WiFi stability tools
└─ Features: Touch/pen input, aggressive thermal management, auto-cpufreq, distributed builds client, WiFi fixes
└─ Home Modules: Base modules (excluding generative AI, ollama-rocm)

thinkpad0/ (Portable Laptop)
├─ Purpose: Secondary portable machine
├─ Size Target: Minimal configuration
├─ CPU: Intel i5-8350U (4c/8t, 1.7GHz-3.6GHz)
├─ Display: Internal eDP-1 + Dell S2415H via HDMI-A-1
├─ Extends: Base configuration
├─ Adds: HDMI external display support
├─ Adds: ThinkPad power management (TLP), ThinkPad ACPI
├─ Packages: ThinkPad ACPI tools, power management utilities
└─ Features: AC performance optimization, battery balance, distributed builds client, external monitor
└─ Home Modules: All modules including generative AI (VOICEVOX)
```

---

## 4. Build Pipeline

### Reproducibility Matrix
```
Component              | Reproducible | Notes
-----------------------|--------------|------------------------
Nix Packages           | Yes          | Pinned via flake.lock
System Configuration   | Yes          | Declarative NixOS modules
Home Manager Config    | Yes          | Declarative user environment
Hyprland Settings      | Mostly       | Some runtime state exists
Theme Assets           | Yes          | Fetched from flake inputs
Wallpapers             | No           | Local files in repo
User Data              | No           | Managed by Syncthing
Build Cache            | No           | Distributed builds use SSH
```

### Build Graph
```
flake.nix (entry point)
├─ nixosConfigurations.<hostname>
│  └─ hosts/<hostname>/configuration.nix
│     ├─ system_modules/*.nix (imports)
│     │  ├─ core_modules/*.nix
│     │  └─ [feature].nix
│     │
│     ├─ hardware-configuration.nix (generated)
│     │
│     └─ home-manager.users.<username>
│        └─ hosts/<hostname>/home.nix
│           ├─ home_modules/*.nix (imports)
│           │  ├─ packages.nix (aggregates packages/*/*.nix)
│           │  ├─ theme.nix (applies Rose Pine theme)
│           │  └─ [app]-config.nix
│           │
│           └─ (optional) hosts/<hostname>/hypr_config/
│              └─ hyprland.nix (overrides hypr_config/)
│                 └─ hypr_modules/*.nix
│
├─ overlays (final: prev:)
│  ├─ flake_modules/overlays.nix (imports)
│  │  ├─ rose-pine-*.nix (theme packages)
│  │  ├─ rocm-pinned.nix (ROCm version lock)
│  │  ├─ rocm-hipblas.nix (ROCm hipblas compatibility)
│  │  └─ fcitx5-fix.nix (input method fix)
│  │
│  └─ nur.overlays.default (NUR packages)
│
└─ user-config.nix (pure function)
   ├─ Input: { machine ? "nixos0", username ? "popcat19", system ? "x86_64-linux", hostname ? null }
   ├─ Output: Structured user/host metadata
   └─ Used by: All system and home modules
   └─ Note: 'machine' parameter replaces direct hostname specification
```

### Pure vs Impure Operations
```
Pure (Nix sandbox):
├─ Package installation
├─ Configuration file generation
├─ Module evaluation
└─ Derivation building

Impure (requires privileges):
├─ nixos-rebuild switch (system activation)
├─ Home Manager activation (user environment)
├─ Distributed build SSH connections
├─ Bootloader installation (boot.nix)
└─ Hardware probing (hardware-configuration.nix)
```

---

## 5. Configuration System

### User Configuration Entry Point
```
user-config.nix (pure function)
├─ host.hostname               - Computed or explicit hostname
├─ host.system                 - System architecture
├─ hosts.machines              - List of defined hosts
├─ user.username               - Primary user account
├─ user.extraGroups            - User group memberships
├─ defaultApps.*               - Default application settings
├─ directories.*               - XDG directory paths
├─ git.*                       - Git configuration
├─ panel.weather.*             - Weather widget settings
└─ arch.*                      - Architecture-specific helpers
```

### Global Nix Settings
```
system_modules/environment.nix
├─ experimental-features        - nix-command, flakes, fetch-tree, impure-derivations
├─ accept-flake-config          - Automatic flake acceptance
├─ auto-optimise-store          - Storage optimization
├─ max-jobs                     - Set to "auto" for optimal build performance
├─ cores                        - Set to 0 for optimal CPU utilization
├─ substituters                 - cache.nixos.org, shimboot-systemd-nixos.cachix.org, ezkea.cachix.org
├─ trusted-public-keys          - Corresponding keys for substituters
├─ download-buffer-size         - 64MB for faster downloads
└─ trusted-users                - root + primary user
```

### Configuration Layers
```
┌─────────────────────────────────────┐
│ Host-Specific Config                │ ← Highest priority
│ hosts/<hostname>/configuration.nix  │
│ hosts/<hostname>/home.nix           │
├─────────────────────────────────────┤
│ Shared Feature Modules              │
│ system_modules/*.nix                │
│ home_modules/*.nix                  │
├─────────────────────────────────────┤
│ User Preferences                    │
│ user-config.nix                     │
├─────────────────────────────────────┤
│ Flake Inputs (Pinned)               │
│ flake.lock                          │
├─────────────────────────────────────┤
│ NixOS Defaults                      │ ← Lowest priority
└─────────────────────────────────────┘
```

### Module Structure
```
user-config.nix                        - Centralized user metadata
├─ flake.nix                           - Flake definition + host declarations
│
├─ system_modules/
│  ├─ core_modules/
│  │  ├─ boot.nix                      - Bootloader + kernel + module blacklist
│  │  ├─ hardware.nix                  - Hardware devices (Bluetooth, i2c)
│  │  ├─ networking.nix                - Network + firewall rules
│  │  └─ users.nix                     - User account creation
│  ├─ audio.nix                        - PipeWire audio server
│  ├─ display.nix                      - Hyprland + SDDM
│  ├─ virtualisation.nix               - Docker, libvirt, Waydroid
│  ├─ distributed-builds.nix           - Remote build client
│  ├─ distributed-builds-server.nix    - Remote build server
│  ├─ ssh.nix                          - SSH server + keys
│  ├─ vpn.nix                          - Mullvad VPN
│  ├─ environment.nix                  - Nix settings + system environment
│  ├─ openrgb.nix                      - OpenRGB RGB control
│  ├─ tablet.nix                       - OpenTabletDriver for graphics tablets
│  └─ [other].nix                      - Additional system features
│
├─ home_modules/
│  ├─ packages.nix                     - Package aggregator
│  │  └─ Imports: packages/home/*.nix + packages/system/*.nix
│  ├─ ollama-rocm.nix                  - Ollama with ROCm acceleration
│  │  └─ Note: Currently CPU fallback (ROCm stdenv issue)
│  ├─ mangohud.nix                     - Gaming performance overlay
│  │  └─ Includes Rose Pine themed config
│  ├─ screenshot.nix                   - Screenshot wrapper
│  │  └─ Uses: screenshot.fish (hyprshot + hyprshade integration)
│  ├─ zen-browser.nix                  - Browser with extensions
│  │  └─ Includes: uBlock, Dark Reader, SponsorBlock, firefoxpwa
│  ├─ theme.nix                        - Rose Pine theme application
│  │  └─ Uses: home_modules/lib/theme.nix
│  ├─ fish.nix                         - Fish shell + config
│  │  └─ Imports: fish-functions.nix
│  ├─ starship.nix                     - Shell prompt
│  ├─ kitty.nix                        - Terminal emulator
│  ├─ kde-apps.nix                     - Dolphin, Gwenview, Okular
│  ├─ fuzzel-config.nix                - Application launcher
│  ├─ privacy.nix                      - KeePassXC + Syncthing integration
│  ├─ generative.nix                   - AI/ML packages (VOICEVOX)
│  └─ [other].nix                      - Additional user features
│
├─ hypr_config/                        - Shared Hyprland config
│  ├─ hyprland.nix                     - Module entry point
│  ├─ hypr_modules/
│  │  ├─ colors.nix                    - Rose Pine color definitions
│  │  ├─ keybinds.nix                  - Keyboard shortcuts
│  │  ├─ window-rules.nix              - Window opacity, floating rules
│  │  ├─ animations.nix                - Animation curves
│  │  ├─ general.nix                   - Layout, gaps, borders
│  │  ├─ hyprlock.nix                  - Screen locker config
│  │  ├─ autostart.nix                 - Autostart applications
│  │  └─ environment.nix               - Hyprland-specific env vars
│  │  └─ [other].nix                   - Other Hyprland settings
│  ├─ hyprpanel-common.nix             - Shared panel config
│  ├─ shaders/                         - GLSL shader files
│  └─ wallpaper.nix                    - Dynamic wallpaper selection
│
└─ hosts/<hostname>/
   ├─ configuration.nix                - Host system config
   ├─ hardware-configuration.nix       - Generated hardware config
   ├─ home.nix                         - Host home-manager config
   ├─ hypr_config/                     - Host-specific Hyprland overrides
   │  ├─ hyprland.nix                  - Imports shared modules + host-specific files
   │  ├─ monitors.conf                 - Host-specific monitor layout
   │  ├─ hyprpanel.nix                 - Host-specific panel layout
   │  └─ [overrides].nix               - Additional overrides
   ├─ system_modules/                  - Host-specific system modules
   └─ github-runner/                   - GitHub Actions runner (nixos0 only, temporarily disabled)
      ├─ github-runner.nix             - Runner service configuration
      ├─ secrets/                      - Encrypted token management
      └─ README.md                     - Setup documentation
```

---

## 6. Host Management Mechanism

### Host Declaration Tree
```
flake.nix (outputs.nixosConfigurations)
└─ mkHostConfig function (from flake_modules/hosts.nix)
   ├─ Input: hostname, system, hostConfigPath, homeConfigPath
   ├─ Creates: nixosSystem
   │  ├─ Applies overlays (flake_modules/overlays.nix)
   │  ├─ Imports hostConfigPath (hosts/<hostname>/configuration.nix)
   │  ├─ Imports external modules (chaotic, home-manager)
   │  ├─ Applies feature modules (gaming, home-manager)
   │  └─ Links homeConfigPath (hosts/<hostname>/home.nix)
   │
   └─ User metadata injection
      └─ userConfig = user-config.nix { machine = <machine>; hostname = hostname; }
         └─ Passed to all system/home modules via specialArgs
```

### Multi-Host Support
```
Hosts (defined in user-config.nix → flake.nix):
├─ nixos0     (popcat19-nixos0)
├─ surface0   (popcat19-surface0)
└─ thinkpad0  (popcat19-thinkpad0)

Each host provides:
├─ configuration.nix         - System configuration
├─ hardware-configuration.nix - Hardware detection
├─ home.nix                  - User environment
└─ (optional) host-specific modules

Building a specific host:
└─ nixos-rebuild switch --flake .#popcat19-nixos0
```

### Distributed Builds Integration
```
nixos0 (Build Server)
├─ distributed-builds-server.nix
│  ├─ Optimized for 12-thread builds (max-jobs = 12)
│  ├─ Accepts SSH connections from clients
│  └─ Serves as remote builder for surface0/thinkpad0
│
surface0/thinkpad0 (Build Clients)
├─ distributed-builds.nix
│  ├─ Offloads builds to nixos0 (192.168.50.172)
│  ├─ Uses SSH key: ~/.ssh/id_ed25519
│  └─ Fallback to local builds if remote unavailable
│
Why distributed builds?
├─ Faster compilation on slower machines (Surface, ThinkPad)
├─ Shared cache between hosts (no redundant rebuilds)
└─ Centralized build artifacts on primary workstation
```

---

## 7. Known Constraints

### Hardware/Platform Support
```
Feature       | Status      | Notes
--------------|-------------|----------------------------------
x86_64-linux  | Working     | Primary architecture
aarch64-linux | Untested    | Infrastructure exists, no hardware
AMD Radeon    | Working     | ROCm pinned to stable version
NVIDIA        | Unavailable | No NVIDIA hardware in fleet
Surface       | Working     | Surface-specific modules functional
ThinkPad      | Working     | External HDMI + ddcutil functional
```

### Software Limitations
```
fcitx5-qt6
├─ Qt6 variant broken in nixpkgs
├─ Workaround: fcitx5-fix.nix (removes Qt6 support)
└─ Status: Disabled, using Qt5 version only

ROCm Acceleration
├─ Ollama ROCm support disabled (stdenv issue)
├─ Workaround: CPU fallback (rocm-pinned.nix ready for re-enable)
└─ Status: Awaiting upstream nixpkgs fix

Resource Constraints (surface0, thinkpad0)
├─ Lower CPU power vs nixos0
├─ Relies on distributed builds to nixos0
└─ May experience slower local builds without remote

Performance Notes (All Hosts)
├─ Hyprland animations tuned for 60Hz displays
├─ Theme overlays may slow first rebuild (SCSS compilation)
├─ Distributed builds require stable LAN connection
└─ GitHub runners increase nixos0 resource usage during CI jobs
```

### Input Method (fcitx5)
- Temporarily disabled due to fcitx5-qt6 build issues
- Will be re-enabled when nixpkgs resolves Qt6 compatibility
- Placeholder config exists in home_modules/fcitx5.nix

### Incompatible Configurations
```
Architecture Mismatches
└─ Reason: ROCm, gaming, some overlays are x86_64-only
   └─ Workaround: arch.onlyX86_64 function in user-config.nix

Remote Build Failures
└─ Affected: surface0, thinkpad0 when nixos0 unreachable
   └─ Reason: Builds fall back to local (slower)
```

---

## 8. Extension Points

### Adding New Hosts
```
Required steps:
1. Generate hardware-configuration.nix on new machine:
   └─ nixos-generate-config --show-hardware-config > hardware-configuration.nix

2. Create hosts/<hostname>/ directory:
   ├─ configuration.nix (copy from hosts/minimal.nix template)
   ├─ home.nix (copy from hosts/home-minimal.nix template)
   └─ hardware-configuration.nix (from step 1)

3. Add hostname to user-config.nix:
   └─ hosts.machines = [ ... "<hostname>" ];

4. (Optional) Add host-specific modules:
   ├─ hosts/<hostname>/system_modules/*.nix
   └─ hosts/<hostname>/hypr_config/*.nix

5. Build and test:
   └─ nixos-rebuild dry-run --flake .#<username>-<hostname>
```

### Adding System Modules
```
system_modules/<feature>.nix
└─ { pkgs, userConfig, ... }: {
     # NixOS configuration options
   }

Import in hosts/<hostname>/configuration.nix:
└─ imports = [ ../../system_modules/<feature>.nix ];
```

### Adding Home Modules
```
home_modules/<feature>.nix
└─ { pkgs, userConfig, ... }: {
     # Home Manager configuration options
   }

Import in hosts/<hostname>/home.nix:
└─ imports = [ ../../home_modules/<feature>.nix ];
```

### Adding Packages
```
packages/home/<category>.nix or packages/system/<category>.nix
└─ { pkgs, ... }: with pkgs; [
     package1
     package2
   ]

Automatically imported by home_modules/packages.nix
```

### Adding Host-Specific System Modules
```
hosts/<hostname>/system_modules/<feature>.nix
└─ { pkgs, lib, ... }: {
     # Host-specific system configuration
   }

Import in hosts/<hostname>/configuration.nix
```

### Adding Overlays
```
overlays/<name>.nix
└─ final: prev: {
     <package-name> = prev.<package-name>.overrideAttrs (old: {
       # Modifications
     });
   }

Import in flake_modules/overlays.nix:
└─ Add to list: [ (import ../overlays/<name>.nix) ]
```

### Hyprland Customization
```
Current: Shared config in hypr_config/
Proposed: Per-host overrides in hosts/<hostname>/hypr_config/

1. Create hosts/<hostname>/hypr_config/:
   ├─ hyprland.nix (imports shared hypr_modules + host files)
   ├─ monitors.conf (host-specific monitor layout)
   └─ hyprpanel.nix (host-specific panel layout)

2. hyprland.nix imports:
   └─ ../../../hypr_config/hypr_modules/*.nix (shared)

3. Define host-specific settings in monitors.conf

Example per-host monitor layout:
├─ nixos0:    Dual DP-3/DP-4 (2560x1440 + 3840x2160)
├─ surface0:  Single eDP-1 (2736x1824 @ 1.5 scale)
└─ thinkpad0: Internal + Dell S2415H via HDMI

Example per-host panel layout (hyprpanel.nix bar.layouts):
└─ Laptop configs include battery widget, desktop configs omit it
```

### Theme Customization
```
Current: Rose Pine Main variant (home_modules/theme.nix)
Alternative: Rose Pine Moon (darker)

1. Edit home_modules/theme.nix:
   └─ Change: selectedVariant = variants.moon;

2. Rebuild: nixos-rebuild switch --flake .

Available variants (defined in home_modules/lib/theme.nix):
├─ main   - Default Rose Pine (lighter)
└─ moon   - Rose Pine Moon (darker)
```

---

## 9. Maintenance Guide

### When to Update This Spec

**Component Changes:**
```
flake.nix modified
└─ Update: Section 4 (Build Pipeline)
          Section 6 (Host Management)

user-config.nix modified
└─ Update: Section 5 (Configuration System)

New system_module added
└─ Update: Section 3 (Component Reference)

New home_module added
└─ Update: Section 3 (Component Reference)

New host added/removed
└─ Update: Section 1 (Tested Hardware)
          Section 6 (Host Management)

New overlay added
└─ Update: Section 2 (Critical Patches)
          Section 3 (Component Reference)

Known issue discovered
└─ Update: Section 7 (Known Constraints)

New extension pattern created
└─ Update: Section 8 (Extension Points)
```

### Updating Flake Inputs
```
nix flake update (updates all inputs)
├─ Updates: flake.lock
└─ Triggers: Full system rebuild on next switch

Per-input update:
└─ nix flake lock --update-input <input-name>
```

### Distributed Builds Maintenance
```
Build server (nixos0):
├─ Ensure SSH keys are current
├─ Monitor disk space (build artifacts)
└─ Verify SSH access: ssh popcat19@192.168.50.172

Build clients (surface0, thinkpad0):
├─ Keep ~/.ssh/id_ed25519 synchronized
├─ Test remote builds: nix build --builders ssh://...
└─ Fallback to local builds if nixos0 unavailable
```

### Spec File Organization
```
Each section is independently updateable
└─ Changes to Section N should not require rewriting Section M

Avoid:
├─ Cross-references between sections (prefer duplication)
├─ Time-sensitive data (use "current state" language)
├─ Feature priority markers ("important", "critical")
└─ Implementation timelines ("will be added", "coming soon")

Prefer:
├─ State descriptions ("exists", "works", "fails")
├─ Component relationships (parent/child)
├─ Decision rationale ("why this approach")
└─ Failure modes ("when this breaks")
```

### Spec Validation Checklist
```
□ No flowcharts (use tree structures)
□ No 'NEW' or priority markers
□ No dates or version numbers (use git history)
□ No unverified performance claims
□ Each section independently comprehensible
□ Token-efficient (avoid prose, use lists)
□ Scannable headings with clear hierarchy
□ Code examples are copy-pasteable
```

---

## 10. Quick Reference

### Common Commands
```
Build current host:
└─ sudo nixos-rebuild switch --flake .

Build specific host:
└─ sudo nixos-rebuild switch --flake .#popcat19-<hostname>

Dry-run build (test):
└─ nixos-rebuild dry-run --flake .

Update flake inputs:
└─ nix flake update

Update specific input:
└─ nix flake lock --update-input <input-name>

Format Nix files:
└─ nix fmt

Garbage collect:
└─ nix-collect-garbage -d
└─ sudo nix-collect-garbage -d (system profiles)

List generations:
└─ sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

Rollback to previous generation:
└─ sudo nixos-rebuild switch --rollback

Test distributed builds:
└─ nix build --builders 'ssh://popcat19@192.168.50.172 x86_64-linux' nixpkgs#hello
```

### Custom Fish Functions
```
nixos-commit-rebuild-push '<message>':
└─ Git add/commit + rebuild + push in one command

nixos-rebuild-basic:
└─ Simple rebuild without git integration

nixos-flake-update:
└─ Update flake + show changes + create backup

dev-to-main:
└─ Merge dev branch to main with conflict checking

list-fish-helpers:
└─ Show all available fish functions and abbreviations

fix-fish-history:
└─ Repair corrupted fish history file
```

### File Paths
```
Configuration:
├─ ~/nixos-config/                     - Project root
├─ ~/nixos-config/flake.nix            - Flake definition
├─ ~/nixos-config/user-config.nix      - User metadata
├─ ~/nixos-config/system_modules/      - System modules
├─ ~/nixos-config/home_modules/        - Home modules
├─ ~/nixos-config/hosts/<hostname>/    - Host-specific config
└─ ~/nixos-config/hosts/minimal.nix    - System config template
└─ ~/nixos-config/hosts/home-minimal.nix - Home config template

Build artifacts:
├─ /nix/store/                         - Immutable package store
├─ /run/current-system/                - Active system generation
├─ /etc/nixos/                         - Legacy config (unused in flake)
└─ ~/.local/state/nix/profiles/        - User profiles

Runtime state:
├─ ~/.config/hypr/                     - Hyprland config (generated)
├─ ~/.local/share/fish/                - Fish shell data
├─ ~/.local/share/syncthing/           - Syncthing state
└─ ~/syncthing-shared/                 - Synced files
```

### Troubleshooting Entry Points
```
Build fails:
└─ Section 4 (Build Pipeline) → Reproducibility Matrix

Surface-specific thermal issues:
└─ Section 2 (Critical Patches) → surface0 Thermal Management
   Section 7 (Known Constraints) → Software Limitations

Surface WiFi disconnections:
└─ Section 2 (Critical Patches) → surface0 WiFi Stability
   hosts/surface0/system_modules/services.nix

ThinkPad power management:
└─ hosts/thinkpad0/system_modules/power-management.nix

Host-specific monitor layout:
└─ hosts/<hostname>/hypr_config/monitors.conf

Module not found:
└─ Section 3 (Component Reference) → Module Organization

Host configuration issues:
└─ Section 6 (Host Management) → Host Declaration Tree

Theme not applying:
└─ Section 5 (Configuration System) → Configuration Layers

Distributed builds failing:
└─ Section 7 (Known Constraints) → Incompatible Configurations

Want to add new host:
└─ Section 8 (Extension Points) → Adding New Hosts

Want to customize per-host Hyprland:
└─ Section 8 (Extension Points) → Hyprland Customization
   hosts/<hostname>/hypr_config/

Package missing:
└─ Section 3 (Component Reference) → Module Organization
   Section 8 (Extension Points) → Adding Packages
```

---

**End of Specification**  
For implementation details, see source files in repository.  
For community support, see NixOS Discourse or Matrix channels.  
For upstream documentation, see NixOS Manual and Home Manager Manual.