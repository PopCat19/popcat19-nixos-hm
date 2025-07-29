# General Settings for Hyprland
# ==============================

{
  wayland.windowManager.hyprland.settings = {
    # Monitor Configuration
    monitor = ",preferred,auto,auto";

    # General window management
    general = {
      gaps_in = 6;
      gaps_out = 12;
      border_size = 2;
      "col.active_border" = "$rose";
      "col.inactive_border" = "$muted";
      resize_on_border = false;
      allow_tearing = false;
      layout = "dwindle";
    };

    # Window decoration
    decoration = {
      rounding = 12;
      active_opacity = 1.0;
      inactive_opacity = 1.0;

      shadow = {
        enabled = false;
        range = 4;
        render_power = 3;
        color = "rgba(1a1a1aee)";
      };

      blur = {
        enabled = true;
        size = 3;
        passes = 3;
        vibrancy = 0.1696;
      };
    };

    # Layout configuration
    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    master = {
      new_status = "master";
    };

    # Miscellaneous settings
    misc = {
      force_default_wallpaper = -1;
      disable_hyprland_logo = false;
    };

    # Debug settings
    debug = {
      damage_tracking = 0;
    };

    # Layer rules
    layerrule = [
      "blur,bar-0"
      "blur,bar-1"
      "blur,fuzzel"
      "ignorezero,fuzzel"
    ];
  };
}