{
  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 4;
      gaps_out = 4;
      border_size = 2;
      resize_on_border = false;
      allow_tearing = false;
      layout = "dwindle";
    };

    decoration = {
      rounding = 16;  # PMD spec: 1rem (16px) radius
      active_opacity = 1.0;
      inactive_opacity = 1.0;

      shadow = {
        enabled = false;
        range = 4;
        render_power = 3;
      };

      blur = {
        enabled = true;
        size = 2;
        passes = 2;
        vibrancy = 0.1696;
      };
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    master = {
      new_status = "master";
    };

    misc = {
      force_default_wallpaper = -1;
      vfr = true;
    };

    debug = {
      damage_tracking = 0;
    };

    layerrule = [
      "blur,bar-0"
      "blur,bar-1"
      "blur,fuzzel"
      "blur,noctalia-shell"
      "ignorezero,fuzzel"
    ];
  };
}
