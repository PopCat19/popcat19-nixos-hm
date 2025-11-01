# Niri Integration Guide for Your Multi-Host Setup

This guide shows how to integrate Niri into your existing multi-host NixOS configuration structure.

## Understanding Your Current Structure

Your current setup has:
- **Shared Hyprland config**: `hypr_config/` (imported by all hosts)
- **Host-specific configs**: `hosts/{nixos0,surface0,thinkpad0}/hypr_config/`
- **Home Manager integration**: Each host's `home.nix` imports its Hyprland config

## Migration Strategy for Your Setup

### Option 1: Replace Hyprland Globally (Recommended)

Replace the shared Hyprland import with Niri in all host configurations:

```nix
# In hosts/nixos0/home.nix (and similar for other hosts)
imports = [
  # OLD
  ./hypr_config/hyprland.nix
  ./hypr_config/hyprpanel.nix
  
  # NEW  
  ../../niri_config/niri.nix
  ./hypr_config/hyprpanel.nix  # Keep this if you use hyprpanel
  ...
];
```

### Option 2: Gradual Migration (Host by Host)

Migrate one host at a time to test the configuration:

```nix
# Example for nixos0 (desktop machine)
# hosts/nixos0/home.nix
imports = [
  # Test Niri on this host only
  ../../niri_config/niri.nix
  ./hypr_config/hyprpanel.nix
  # ... rest of modules
];

# Keep other hosts on Hyprland for now
# hosts/surface0/home.nix and hosts/thinkpad0/home.nix remain unchanged
```

## Creating Host-Specific Niri Configurations

### For nixos0 (Desktop/Multi-monitor)

Create `hosts/nixos0/hypr_config/niri.nix`:

```nix
# nixos0-specific Niri Configuration
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../../niri_config/niri.nix  # Base Niri config
  ];

  # nixos0-specific overrides
  programs.niri.settings = {
    # Dual monitor setup (if you have one)
    outputs."eDP-1" = {
      mode = "1920x1080@120.030";
      scale = 1.0;
      position.x = 0;
      position.y = 0;
    };
    
    outputs."HDMI-A-1" = {
      mode = "1920x1080@60.0";
      scale = 1.0;
      position.x = 1920;
      position.y = 0;
    };

    # Desktop-specific spawns
    spawn-at-startup = [
      "hyprpaper"
      "fcitx5"
      "openrgb -p orang-full"
      "waybar"
    ];
  };

  # Copy nixos0-specific config files
  home.file = {
    ".config/niri/config.kdl".source = ./niri.conf;
  };
}
```

### For surface0 (Laptop)

Create `hosts/surface0/hypr_config/niri.nix`:

```nix
# surface0-specific Niri Configuration
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../../niri_config/niri.nix  # Base Niri config
  ];

  # Laptop-specific settings
  programs.niri.settings = {
    # Single monitor laptop setup
    outputs."eDP-1" = {
      mode = "1920x1080@60.0";
      scale = 1.0;
    };

    # Laptop-specific touchpad settings
    input.touchpad = {
      tap = true;
      natural-scroll = true;
      dwt = true;  # Disable while typing
    };

    # Power management
    spawn-at-startup = [
      "fcitx5"
      # No openrgb for laptop
    ];
  };
}
```

### For thinkpad0 (Performance Laptop)

Create `hosts/thinkpad0/hypr_config/niri.nix`:

```nix
# thinkpad0-specific Niri Configuration
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../../../niri_config/niri.nix  # Base Niri config
  ];

  # Performance-focused settings
  programs.niri.settings = {
    outputs."eDP-1" = {
      mode = "1920x1080@120.0";
      scale = 1.0;
    };

    # More aggressive animations for performance
    animations = {
      window-open = {
        duration-ms = 100;  # Faster animations
        curve = "linear";
      };
    };

    # Performance spawns
    spawn-at-startup = [
      "fcitx5"
      "openrgb -p orang-full"
    ];
  };
}
```

## Updating Your Home Manager Imports

### Update hosts/nixos0/home.nix:

```nix
# Home Manager configuration for nixos0
{
  pkgs,
  config,
  system,
  lib,
  inputs,
  userConfig,
  ...
}: {
  # Basic home configuration
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  # Imports (migrated to Niri)
  imports = [
    # NEW: Niri configuration
    ./hypr_config/niri.nix  # Replace hypr_config/hyprland.nix
    
    # Keep other modules
    ./hypr_config/hyprpanel.nix
    ../../home_modules/theme.nix
    ../../home_modules/fonts.nix
    ../../home_modules/screenshot.nix
    ../../home_modules/zen-browser.nix
    ../../home_modules/generative.nix
    ../../home_modules/ollama-rocm.nix
    ../../home_modules/environment.nix
    ../../home_modules/services.nix
    ../../home_modules/home-files.nix
    ../../home_modules/systemd-services.nix
    ../../home_modules/kde-apps.nix
    ../../home_modules/qt-gtk-config.nix
    ../../home_modules/fuzzel-config.nix
    ../../home_modules/kitty.nix
    ../../home_modules/fish.nix
    ../../home_modules/starship.nix
    ../../home_modules/micro.nix
    ../../home_modules/fcitx5.nix
    ../../home_modules/privacy.nix
    ../../quickshell_config/quickshell.nix
    ../../syncthing_config/home.nix
  ];

  home.packages = import ../../home_modules/packages.nix {inherit pkgs inputs system userConfig;};
}
```

## Host-Specific Configuration Files

### Create monitors.conf equivalents for Niri

**For nixos0 dual-monitor** (`hosts/nixos0/hypr_config/niri.conf`):

```kdl
output "eDP-1" {
    mode "1920x1080@120.030"
    scale 1.0
    position x=0 y=0
    focus-at-startup
    background-color "#0a0a0a"
}

output "HDMI-A-1" {
    mode "1920x1080@60.0"
    scale 1.0
    position x=1920 y=0
    background-color "#0a0a0a"
}
```

**For surface0 laptop** (`hosts/surface0/hypr_config/niri.conf`):

```kdl
output "eDP-1" {
    mode "1920x1080@60.0"
    scale 1.0
    focus-at-startup
    background-color "#0a0a0a"
}
```

**For thinkpad0 performance** (`hosts/thinkpad0/hypr_config/niri.conf`):

```kdl
output "eDP-1" {
    mode "1920x1080@120.0"
    scale 1.0
    focus-at-startup
    background-color "#0a0a0a"
}
```

## Testing Your Migration

### Step 1: Test One Host
```bash
# Test nixos0 configuration first
nixos-rebuild dry-run --flake .#popcat19-nixos0
```

### Step 2: Build and Test
```bash
# If dry-run passes, actually build
sudo nixos-rebuild switch --flake .#popcat19-nixos0
```

### Step 3: Verify Functionality
After switching to Niri, test:
- Window management (opening/closing/moving)
- Keybindings (especially Mod+key combinations)
- Application launching
- Multi-monitor functionality (if applicable)

## Rollback Strategy

If something goes wrong, rollback is simple:

### Quick Rollback
```bash
# Restore Hyprland configuration
sudo nixos-rebuild switch --flake .#popcat19-nixos0 --rollback
```

### Manual Rollback
1. Edit `hosts/nixos0/home.nix`
2. Change back to Hyprland imports:
   ```nix
   imports = [
     ./hypr_config/hyprland.nix  # Back to Hyprland
     ./hypr_config/hyprpanel.nix
     # ... rest unchanged
   ];
   ```
3. Rebuild:
   ```bash
   sudo nixos-rebuild switch --flake .#popcat19-nixos0
   ```

## Advanced Configuration Tips

### Using Both Hyprland and Niri (Dual-Boot Approach)

Keep both configurations and switch between them:

```nix
# Option in your configuration
{ config, pkgs, lib, ... }: {
  # Enable either Hyprland OR Niri, not both
  wayland.windowManager.hyprland.enable = false;  # Disable Hyprland
  
  programs.niri.enable = true;  # Enable Niri
  # ... Niri configuration
}
```

### Per-Host Theme Integration

Your existing theme.nix should work with Niri. If you use Stylix:

```nix
# In your Niri config
stylix.targets.niri.enable = true;  # Apply Stylix theme to Niri
```

## Performance Considerations

### For Lower-End Hardware
```nix
programs.niri.settings = {
  animations.off = true;  # Disable all animations
  
  layout.gaps = 4;  # Smaller gaps
  
  spawn-at-startup = [
    # Minimal startup applications
  ];
};
```

### For High-End Hardware
```nix
programs.niri.settings = {
  animations = {
    window-open.duration-ms = 300;  # Slower, more elegant
    workspace-switch.spring.stiffness = 1200;  # Snappier
  };
  
  layout.border.width = 3;  # Thicker borders
};
```

## Common Issues and Solutions

### 1. Keybinding Conflicts
Niri may handle some keybindings differently. Check available actions:
```bash
niri msg action-list
```

### 2. Application Compatibility
Some apps may need additional environment variables:
```nix
environment = {
  # For Electron apps
  ELECTRON_OZONE_PLATFORM_HINT = "auto";
  
  # For Qt apps
  QT_QPA_PLATFORM = "wayland";
};
```

### 3. Performance Issues
If Niri feels slow on lower-end hardware:
```nix
programs.niri.settings = {
  debug.render-drm-device = "/dev/dri/renderD128";  # Use specific GPU
  animations.off = true;  # Disable animations
};
```

This approach lets you migrate gradually while maintaining your existing multi-host structure.