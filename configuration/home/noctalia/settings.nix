# settings.nix
#
# Purpose: Provides complete Noctalia v5 settings as Nix attribute set
#
# This module:
# - Exports settings attribute set for Noctalia shell configuration
# - v5 native C++/TOML schema
# - Theme colors set via builtin palette; Stylix target needs upstream v5 update
{
  config,
  ...
}:
let
  wallpaperDir = "${config.home.homeDirectory}/popcat19-nixos-hm/configuration/home/wallpaper";
  settings = {
    shell = {
      ui_scale = 1.0;
      corner_radius_scale = 1.0;
      font_family = "Rounded Mplus 1c Medium";
      clipboard_enabled = false;
      clipboard_auto_paste = "off";
      clipboard_history_max_entries = 100;
      middle_click_opens_widget_settings = true;
      settings_show_advanced = true;
      avatar_path = "${config.home.homeDirectory}/.face";
      lang = "";

      animation = {
        enabled = true;
        speed = 1.2;
      };

      shadow = {
        direction = "down_right";
        alpha = 0.55;
      };

      panel = {
        transparency_mode = "solid";
        borders = false;
        shadow = false;
        launcher_placement = "centered";
        control_center_placement = "floating";
        open_near_click_control_center = true;
        wallpaper_placement = "attached";
        clipboard_placement = "centered";
        session_placement = "attached";
      };

      mpris = {
        blacklist = [ ];
      };
    };

    theme = {
      mode = "dark";
      source = "builtin";
      builtin = "Rosé Pine";

      templates = {
        enable_builtin_templates = false;
        enable_community_templates = false;
      };
    };

    wallpaper = {
      enabled = true;
      fill_mode = "crop";
      fill_color = "#000000";
      transition = [ "fade" ];
      transition_duration = 1500;
      edge_smoothness = 0.05;
      directory = wallpaperDir;

      automation = {
        enabled = false;
        order = "random";
        interval_minutes = 5;
      };

      default = {
        path = "${wallpaperDir}/wallpaper0.png";
      };

      last = {
        path = "${wallpaperDir}/wallpaper0.png";
      };
    };

    backdrop = {
      enabled = false;
    };

    bar.main = {
      position = "top";
      thickness = 32;
      background_opacity = 1.0;
      radius = 16;
      margin_edge = 6;
      margin_ends = 6;
      margin_h = 5;
      margin_v = 5;
      padding = 12;
      widget_spacing = 12;
      scale = 1.0;
      shadow = false;
      auto_hide = false;
      reserve_space = true;
      capsule = false;

      start = [
        "control-center"
        "workspaces"
        "cpu"
        "cpu-temp"
        "ram"
        "disk"
        "media"
      ];
      center = [ ];
      end = [
        "cat"
        "tray"
        "network"
        "bluetooth"
        "volume"
        "battery"
        "clock"
        "notifications"
      ];
    };

    widget = {
      workspaces = {
        display = "name";
        max_label_chars = 2;
        labels_only_when_occupied = true;
        hide_when_empty = false;
        pill_scale = 0.6;
        scale = 1.2;
        minimal = true;
      };

      cpu = {
        type = "sysmon";
        stat = "cpu_usage";
        display = "text";
      };

      "cpu-temp" = {
        type = "sysmon";
        stat = "cpu_temp";
        display = "text";
      };

      ram = {
        type = "sysmon";
        stat = "ram_used";
        display = "text";
      };

      disk = {
        type = "sysmon";
        stat = "disk_pct";
        path = "/";
        display = "text";
      };

      media = {
        min_length = 80;
        max_length = 256;
        art_size = 24;
        title_scroll = "on_hover";
        hide_when_no_media = false;
      };

      tray = {
        hidden = [ ];
        pinned = [ ];
        drawer = true;
        drawer_columns = 3;
      };

      battery = {
        display_mode = "icon";
        show_label = true;
        device = "auto";
        warning_threshold = 20;
      };

      volume = {
        device = "output";
        scroll_step = 4;
        show_label = true;
      };

      network = {
        show_label = false;
      };

      bluetooth = {
        show_label = false;
      };

      clock = {
        format = "{:%H:%M %a, %b %d}";
        vertical_format = "{:%H\n%M}";
        tooltip_format = "{:%H:%M %a, %b %d}";
      };

      notifications = {
        hide_when_no_unread = false;
      };

      cat = {
        type = "noctalia/bongocat:cat";
        color = "primary";
        scale = 1.4;
        tappy_mode = true;
        audio_spectrum = true;
      };
    };

    notification = {
      enable_daemon = true;
      show_app_name = true;
      position = "top_right";
      layer = "overlay";
      scale = 1.0;
      background_opacity = 0.97;
      offset_x = 20;
      offset_y = 8;
      blacklist = [ ];
      blacklist_allow_critical = true;
    };

    osd = {
      position = "top_center";
      orientation = "horizontal";
      scale = 1.0;
      background_opacity = 1.0;
      offset_x = 20;
      offset_y = 8;

      kinds = {
        volume = true;
        volume_output = true;
        volume_input = true;
        brightness = true;
        wifi = true;
        bluetooth = true;
        power_profile = true;
        caffeine = true;
        dnd = true;
        lock_keys = true;
        keyboard_layout = true;
      };
    };

    plugins = {
      enabled = [ "noctalia/bongocat" ];
    };

    system.monitor = {
      enabled = true;
      cpu_poll_seconds = 1.0;
      gpu_poll_seconds = 3.0;
      memory_poll_seconds = 1.0;
      network_poll_seconds = 1.0;
      disk_poll_seconds = 3.0;
    };

    weather = {
      enabled = false;
      refresh_minutes = 30;
      unit = "celsius";
      effects = true;
    };

    audio = {
      enable_overdrive = true;
      enable_sounds = false;
      sound_volume = 0.5;
    };

    brightness = {
      enable_ddcutil = false;
    };

    nightlight = {
      enabled = false;
      force = false;
      temperature_day = 6500;
      temperature_night = 4000;
    };

    location = {
      auto_locate = false;
      address = "New York";
      sunset = "18:30";
      sunrise = "06:30";
    };

    hooks = {
      battery_low_percent_threshold = 0;
    };

    desktop_widgets = {
      enabled = false;
    };

    dock = {
      enabled = false;
      position = "bottom";
      icon_size = 48;
      background_opacity = 0.88;
      radius = 16;
      margin_h = 0;
      margin_v = 8;
      shadow = true;
      show_running = true;
      auto_hide = true;
      reserve_space = true;
      active_scale = 1.0;
      inactive_scale = 0.85;
      magnification = true;
      magnification_scale = 1.45;
      active_opacity = 1.0;
      inactive_opacity = 0.6;
      show_dots = false;
      show_instance_count = true;
      active_monitor_only = true;
      pinned = [ ];
    };
  };
in
{
  inherit settings;
}
