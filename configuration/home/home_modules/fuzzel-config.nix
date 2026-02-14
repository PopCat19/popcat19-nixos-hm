# fuzzel-config.nix
#
# Purpose: Configure Fuzzel application launcher with Rose Pine theme
#
# This module:
# - Enables Fuzzel with custom key bindings
# - Configures display and layout settings
# - Sets up terminal integration via userConfig

{ userConfig, ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      border = {
        radius = 12;
        width = 2;
      };
      key-bindings = {
        cancel = "Escape Control+c Control+g";
        cursor-end = "End Control+e";
        cursor-home = "Home Control+a";
        cursor-left = "Left Control+b";
        cursor-left-word = "Control+Left Mod1+b";
        cursor-right = "Right Control+f";
        cursor-right-word = "Control+Right Mod1+f";
        delete-next = "Delete Control+d";
        delete-next-word = "Mod1+d";
        delete-prev = "BackSpace Control+h";
        delete-prev-word = "Mod1+BackSpace Control+w";
        execute = "Return KP_Enter Control+m";
        execute-or-next = "Tab";
        first = "Control+Home";
        last = "Control+End";
        next = "Down Control+n";
        prev = "Up Control+p";
      };
      main = {
        filter-desktop = true;
        horizontal-pad = 20;
        icons-enabled = true;
        image-size-ratio = 0.8;
        inner-pad = 8;
        layer = "overlay";
        lines = 12;
        list-executables-in-path = false;
        password-character = "*";
        placeholder = "Search applications...";
        show-actions = true;
        terminal = userConfig.defaultApps.terminal.command;
        vertical-pad = 12;
        width = 50;
      };
    };
  };
}
