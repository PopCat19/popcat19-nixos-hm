{ pkgs, ... }:

{
  # Kitty Terminal Configuration with Rose Pine theme
  programs.kitty = {
    enable = true;
    settings = {
      # Shell
      shell = "fish";
      shell_integration = "enabled";

      # Window behavior
      confirm_os_window_close = 1;

      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = 0.5;
      cursor_stop_blinking_after = 15.0;

      # Scrollback
      scrollback_lines = 10000;

      # Mouse
      mouse_hide_wait = 3.0;
      url_color = "#c4a7e7";
      url_style = "curly";
      detect_urls = "yes";

      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";

      # Audio
      enable_audio_bell = "no";
      visual_bell_duration = 0.0;

      # Window
      remember_window_size = "yes";
      window_border_width = 0.5;
      window_margin_width = 8;
      window_padding_width = 12;
      active_border_color = "#ebbcba";
      inactive_border_color = "#26233a";

      # Tab bar
      tab_bar_edge = "bottom";
      tab_bar_style = "separator";
      tab_separator = " ┇ ";
      active_tab_foreground = "#e0def4";
      active_tab_background = "#26233a";
      inactive_tab_foreground = "#908caa";
      inactive_tab_background = "#191724";

      # Rose Pine colors
      foreground = "#e0def4";
      background = "#191724";
      selection_foreground = "#e0def4";
      selection_background = "#403d52";

      # Terminal colors
      color0 = "#26233a";
      color1 = "#eb6f92";
      color2 = "#9ccfd8";
      color3 = "#f6c177";
      color4 = "#31748f";
      color5 = "#c4a7e7";
      color6 = "#ebbcba";
      color7 = "#e0def4";
      color8 = "#6e6a86";
      color9 = "#eb6f92";
      color10 = "#9ccfd8";
      color11 = "#f6c177";
      color12 = "#31748f";
      color13 = "#c4a7e7";
      color14 = "#ebbcba";
      color15 = "#e0def4";

      # Theme tweaks
      background_opacity = "0.85";
      dynamic_background_opacity = "yes";
      background_blur = 20;
    };
  };
}