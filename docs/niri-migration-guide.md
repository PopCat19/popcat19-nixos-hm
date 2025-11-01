# Migration Guide: Hyprland to Niri

This guide helps you migrate from Hyprland to Niri, a scrollable-tiling Wayland compositor with a different approach to window management.

## Key Differences Between Hyprland and Niri

### Layout System
- **Hyprland**: Dynamic tiling with manual window arrangement
- **Niri**: Scrollable-tiling (like scrolling through paper) - more automatic and fluid

### Configuration Format
- **Hyprland**: Mixed config syntax (sections, key=value pairs)
- **Niri**: KDL (Keyboard Layout Definition) format, very clean and structured

### Workspace Management
- **Hyprland**: Traditional workspace switching
- **Niri**: Scrollable workspace system, no traditional workspace switching

### Window Groups
- **Hyprland**: Tab groups (like tabbed browsers)
- **Niri**: More integrated column/tile system

## Migration Steps

### Step 1: Update Flake Configuration

Add Niri to your `flake.nix` inputs:
```nix
# Niri Wayland compositor
niri = {
  url = "github:sodiboo/niri-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

### Step 2: Replace Hyprland with Niri in Host Configuration

Replace the Hyprland import in your host configuration files:
```nix
# OLD (Hyprland)
imports = [
  ./hypr_config/hyprland.nix
];

# NEW (Niri)  
imports = [
  ../niri_config/niri.nix  # Replace with your path
];
```

### Step 3: Keybinding Conversion

| Hyprland | Niri | Notes |
|----------|------|-------|
| `bind = $mainMod, Q, killactive` | `"mod+q".action = "close-window";` | Similar close window behavior |
| `bind = $mainMod, G, togglegroup` | `"mod+g".action = "toggle-group";` | Tab groups |
| `bind = $mainMod, W, togglefloating` | `"mod+w".action = "toggle-floating";` | Same functionality |
| `bind = $mainMod, J, togglesplit` | `"mod+j".action = "togglesplit";` | Split layouts |
| `bind = $mainMod, L, exec, hyprlock` | `"mod+l".action.spawn = "hyprlock";` | Lock screen |

### Step 4: Environment Variable Migration

Most Hyprland environment variables work the same in Niri:

```nix
# Similar environment setup
environment = {
  QT_QPA_PLATFORM = "wayland";
  QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  XDG_CURRENT_DESKTOP = "Niri";
  XDG_SESSION_DESKTOP = "Niri";
  ELECTRON_OZONE_PLATFORM_HINT = "auto";
};
```

### Step 5: Window Rules Conversion

**Hyprland window rules:**
```nix
windowrulev2 = [
  "opacity 0.85 0.85,class:^(kitty)$"
  "float,class:^(vlc)$"
];
```

**Niri layer rules:**
```nix
layer-rules = [
  {
    match.namespace = "kitty";
    opacity = 0.85;
  }
];
```

### Step 6: Animation Configuration

**Hyprland animations:**
```nix
animations = {
  enabled = true;
  animation = [
    "windows,1,4.79,easeOutQuint"
  ];
};
```

**Niri animations (spring-based):**
```nix
animations = {
  window-open = {
    duration-ms = 200;
    curve = "ease-out-expo";
  };
  workspace-switch = {
    spring.damping-ratio = 1.0;
    spring.stiffness = 1000;
  };
};
```

## Alternative KDL Configuration

You can also use direct KDL format for more control:

```nix
programs.niri.config = ''
  output "eDP-1" {
    mode "1920x1080@120.030"
    scale 1.0
    background-color "#0a0a0a"
  }

  input {
    keyboard {
      xkb {
        layout "us"
        options "compose:ralt,ctrl:nocaps"
      }
    }
    
    touchpad {
      tap
      natural-scroll
      scroll-method "two-finger"
    }
  }

  layout {
    gaps 8
    default-column-display "tabbed"
    
    focus-ring {
      width 2
      active-color "#f6c177"
    }
    
    border {
      width 2
      active-color "#f6c177"
    }
  }

  animations {
    workspace-switch {
      spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
    }
    
    window-open {
      duration-ms 200
      curve "ease-out-expo"
    }
  }

  spawn-at-startup "hyprpaper"
  spawn-at-startup "fcitx5"
'';
```

## Testing Your Migration

### 1. Dry Run Test
```bash
# Test configuration without switching
nixos-rebuild dry-run --flake .#your-hostname
```

### 2. Check Niri Flake
```bash
# Check if Niri is available
nix flake check --impure --accept-flake-config
nix search niri
```

### 3. Gradual Migration Strategy

1. **Test with a single host**: Start with one machine to verify the configuration
2. **Backup current config**: Keep your Hyprland config for rollback
3. **Test keybindings**: Ensure critical shortcuts work
4. **Verify applications**: Check that all your apps launch correctly

### 4. Key Applications to Test

- **Terminal** (kitty)
- **File manager** (dolphin)
- **Browser** (firefox/zen-browser)
- **Code editor** (code)
- **System tools** (fcitx5, hyprpaper, openrgb)

## Troubleshooting Common Issues

### 1. Missing Window Decorations
Niri handles window decorations differently. Configure in `layout.border` settings.

### 2. Keybindings Not Working
Niri uses different action names. Check the [Niri documentation](https://github.com/yalter/niri/wiki/Configuration:-Keybinds) for correct action names.

### 3. Application Launch Issues
Some apps might need environment variables set:
```nix
environment.ELECTRON_OZONE_PLATFORM_HINT = "auto";
```

### 4. Cursor Theme Issues
```nix
cursor = {
  xcursor-theme = "rose-pine-hyprcursor";
  xcursor-size = 24;
};
```

## Rollback Plan

If you need to rollback to Hyprland:

1. Remove Niri imports from your host configuration
2. Restore Hyprland imports
3. Rebuild system:
   ```bash
   sudo nixos-rebuild switch --flake .#your-hostname
   ```

## Further Customization

### Layer Rules Examples
```nix
layer-rules = [
  {
    match.namespace = "waybar";
    opacity = 0.8;
    shadow.on = true;
  }
  {
    match.class = "pavucontrol";
    baba-is-float = true;
  }
];
```

### Advanced Gesture Configuration
```kdl
gestures {
  dnd-edge-workspace-switch {
    trigger-height 100
    max-speed 3000
  }
  
  hot-corners {
    top-left
  }
}
```

## Resources

- [Niri GitHub Repository](https://github.com/yalter/niri)
- [Niri Flake Documentation](https://github.com/sodiboo/niri-flake)
- [Niri Wiki](https://github.com/yalter/niri/wiki)
- [KDL Format Documentation](https://kdl.dev/)

## Post-Migration Tips

1. **Explore Niri's scrolling workspace** - It's a key feature that changes how you work
2. **Customize spring animations** - Adjust damping and stiffness for personal preference
3. **Layer rules** - Use them extensively for better window management
4. **Window focus** - Niri's focus behavior is different; configure to taste

Remember: Niri's philosophy is different from Hyprland - it's more about automatic tiling with scrollable interfaces rather than manual window management.