{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.niri.nixosModules.default
  ];

  # Enable Niri
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri-unstable;

  # Configure Niri using Nix-native settings
  programs.niri.settings = {
    # Environment variables
    environment = {
      # Qt configuration
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_STYLE_OVERRIDE = "kvantum";
      
      # Desktop session identifiers
      XDG_CURRENT_DESKTOP = "Niri";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Niri";
      
      # Cursor theme (keep existing)
      XCURSOR_SIZE = "24";
      HYPRCURSOR_SIZE = "28";
      HYPRCURSOR_THEME = "rose-pine-hyprcursor";
      
      # Electron apps
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    # Monitor configuration
    outputs."eDP-1".mode = "1920x1080@120.030";
    outputs."eDP-1".scale = 1.0;
    outputs."eDP-1".background-color = "#0a0a0a";
    outputs."eDP-1".backdrop-color = "#000000";

    # Input configuration
    input.keyboard.xkb.layout = "us";
    input.keyboard.numlock = true;
    input.touchpad = {
      tap = true;
      natural-scroll = true;
      scroll-method = "two-finger";
      scroll-factor = 0.2;
      tap-button-map = "left-middle-right";
      middle-emulation = true;
      disabled-on-external-mouse = false;
    };
    input.mouse.accel-profile = "flat";
    input.mouse.scroll-factor = 0.3;
    input.mouse.natural-scroll = true;

    # Layout configuration (tiling)
    layout = {
      gaps = 8;
      default-column-display = "tabbed";
      always-center-single-column = true;
      preset-column-widths = [
        { proportion = 1./3.; }
        { proportion = 0.5; }
        { proportion = 2./3.; }
      ];
      default-column-width = { proportion = 0.5; };
      focus-ring = {
        width = 2;
        active-color = "#f6c177";
        inactive-color = "#565f89";
      };
      border = {
        width = 2;
        active-color = "#f6c177";
        inactive-color = "#565f89";
      };
      shadow = {
        on = false;
      };
    };

    # Animation configuration
    animations = {
      workspace-switch = {
        spring.damping-ratio = 1.0;
        spring.stiffness = 1000;
        spring.epsilon = 0.0001;
      };
      window-open = {
        duration-ms = 200;
        curve = "ease-out-expo";
      };
      window-close = {
        duration-ms = 150;
        curve = "ease-out-quad";
      };
      overview-open-close = {
        spring.damping-ratio = 1.0;
        spring.stiffness = 800;
        spring.epsilon = 0.0001;
      };
    };

    # Spawn applications at startup
    spawn-at-startup = [
      "hyprpaper"
      "fcitx5"
      "openrgb -p orang-full"
    ];

    # Hotkey overlay configuration
    hotkey-overlay.skip-at-startup = true;

    # Keybindings - Converted from Hyprland
    binds = {
      # Main modifier
      modifier = "mod4"; # Super key
      
      # System actions
      "mod+r".action = { quit.skip-confirmation = true; };
      "mod+shift+q".action = "quit";
      "mod+l".action.spawn = "hyprlock";
      "mod+delete".action = "quit";

      # Window management
      "mod+w".action = "toggle-floating";
      "mod+shift+g".action = "toggle-group";
      "alt+return".action = "fullscreen";
      "mod+j".action = "togglesplit";

      # Application shortcuts
      "mod+t".action.spawn = "kitty";
      "mod+e".action.spawn = "dolphin";
      "mod+c".action.spawn = "code";
      "mod+f".action.spawn = "firefox";
      "mod+a".action.spawn = "fuzzel";

      # Utilities
      "mod+shift+c".action.spawn = "hyprpicker -a";
      "mod+v".action.spawn = "bash -lc \"cliphist list | fuzzel --dmenu --with-nth 2 | cliphist decode | wl-copy\"";
      "mod+shift+v".action.spawn = "bash -lc 'cliphist list | head -n1 | cliphist decode | wl-copy'";
      "ctrl+alt+w".action.spawn = "systemctl --user restart hyprpanel.service";

      # Screenshots
      "mod+p".action.spawn = "~/.local/bin/screenshot monitor";
      "mod+shift+p".action.spawn = "~/.local/bin/screenshot region";

      # Media controls
      "XF86AudioPlay".action.spawn = "playerctl play-pause";
      "XF86AudioPause".action.spawn = "playerctl play-pause";
      "XF86AudioNext".action.spawn = "playerctl next";
      "XF86AudioPrev".action.spawn = "playerctl previous";
      "alt+f8".action.spawn = "playerctl play-pause";
      "alt+f6".action.spawn = "playerctl previous";
      "alt+f7".action.spawn = "playerctl next";

      # Window focus (Niri uses different approach)
      "mod+left".action = "focus-direction-left";
      "mod+right".action = "focus-direction-right";
      "mod+up".action = "focus-direction-up";
      "mod+down".action = "focus-direction-down";
      "alt+tab".action = "focus-next-window";

      # Workspace management (Niri handles this differently)
      "mod+1".action.focus-workspace = 1;
      "mod+2".action.focus-workspace = 2;
      "mod+3".action.focus-workspace = 3;
      "mod+4".action.focus-workspace = 4;
      "mod+5".action.focus-workspace = 5;
      "mod+6".action.focus-workspace = 6;
      "mod+7".action.focus-workspace = 7;
      "mod+8".action.focus-workspace = 8;
      "mod+9".action.focus-workspace = 9;
      "mod+0".action.focus-workspace = 10;

      # Move windows to workspaces
      "mod+shift+1".action.spawn = "niri msg action move-to-workspace 1";
      "mod+shift+2".action.spawn = "niri msg action move-to-workspace 2";
      "mod+shift+3".action.spawn = "niri msg action move-to-workspace 3";
      "mod+shift+4".action.spawn = "niri msg action move-to-workspace 4";
      "mod+shift+5".action.spawn = "niri msg action move-to-workspace 5";
      "mod+shift+6".action.spawn = "niri msg action move-to-workspace 6";
      "mod+shift+7".action.spawn = "niri msg action move-to-workspace 7";
      "mod+shift+8".action.spawn = "niri msg action move-to-workspace 8";
      "mod+shift+9".action.spawn = "niri msg action move-to-workspace 9";
      "mod+shift+0".action.spawn = "niri msg action move-to-workspace 10";

      # Window movement (Niri different approach)
      "mod+shift+left".action = "move-window-left";
      "mod+shift+right".action = "move-window-right";
      "mod+shift+up".action = "move-window-up";
      "mod+shift+down".action = "move-window-down";

      # Volume and brightness controls
      "XF86AudioRaiseVolume".action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "4%+"];
      "XF86AudioLowerVolume".action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "4%-"];
      "XF86AudioMute".action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
      "XF86AudioMicMute".action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
      "F12".action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "4%+"];
      "F11".action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "4%-"];
      "F10".action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
      "XF86MonBrightnessUp".action.spawn = "brightnessctl s 10%+";
      "XF86MonBrightnessDown".action.spawn = "brightnessctl s 10%-";
    };

    # Window rules (Niri uses layer-rules)
    layer-rules = [
      {
        match.namespace = "waybar";
        opacity = 0.8;
        shadow.on = true;
        place-within-backdrop = true;
      }
    ];
  };

  # Alternative: Direct KDL configuration
  # programs.niri.config = ''
  #   output "eDP-1" {
  #     mode "1920x1080@120.030"
  #     scale 1.0
  #     background-color "#0a0a0a"
  #   }
  # '';

  # File generation for configuration
  home.file = {
    # Niri config directory
    ".config/niri".recursive = true;
    
    # Environment file (optional, as we use settings above)
    ".config/niri/environment".text = ''
      # Niri environment variables
      QT_QPA_PLATFORM=wayland
      QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      QT_STYLE_OVERRIDE=kvantum
      XDG_CURRENT_DESKTOP=Niri
      ELECTRON_OZONE_PLATFORM_HINT=auto
    '';
  };
}