# kitty.nix
#
# Purpose: Configure Kitty terminal emulator settings
#
# This module:
# - Enables Kitty terminal
# - Configures shell integration with Fish
# - Sets cursor, window, and tab preferences
_: {
  programs.kitty = {
    enable = true;
    settings = {
      background_blur = 16;
      confirm_os_window_close = -1;
      cursor_blink_interval = 0.5;
      cursor_shape = "block";
      cursor_stop_blinking_after = 16.0;
      cursor_trail = 1;
      detect_urls = "yes";
      dynamic_background_opacity = "yes";
      enable_audio_bell = "yes";
      input_delay = 3;
      mouse_hide_wait = 3.0;
      remember_window_size = "yes";
      repaint_delay = 10;
      scrollback_lines = 10000;
      shell = "fish";
      shell_integration = "enabled";
      sync_to_monitor = "yes";
      tab_bar_edge = "bottom";
      tab_bar_style = "separator";
      tab_separator = " | ";
      url_style = "curly";
      visual_bell_duration = 0.0;
      window_border_width = 0.5;
      window_margin_width = 8;
      window_padding_width = 12;
    };
  };
}
