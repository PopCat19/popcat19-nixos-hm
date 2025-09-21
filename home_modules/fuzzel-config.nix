{
  pkgs,
  userConfig,
  ...
}: {
  # Fuzzel Launcher Configuration - Enhanced with Rose Pine theme and QoL features.
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        layer = "overlay"; # Display as an overlay.
        placeholder = "Search applications...";
        width = 50; # Width in characters.
        lines = 12; # Number of lines to display.
        horizontal-pad = 20; # Horizontal padding.
        vertical-pad = 12; # Vertical padding.
        inner-pad = 8; # Padding between border and content.
        image-size-ratio = 0.8; # Size ratio for application icons.
        show-actions = true; # Show application actions.
        terminal = userConfig.defaultApps.terminal.command; # Terminal for launching terminal applications.
        filter-desktop = true; # Filter desktop files.
        icon-theme = "Papirus-Dark"; # Icon theme to use.
        icons-enabled = true; # Enable application icons.
        password-character = "*"; # Character for password fields.
        list-executables-in-path = false; # Don't list PATH executables.
      };
      # Colors are generated dynamically by Matugen into ~/.config/fuzzel/fuzzel.ini
      # See: home_modules/matugen.nix activation (native Material You variables)
      border = {
        radius = 12; # Rounded corners.
        width = 2; # Border width.
      };
      key-bindings = {
        cancel = "Escape Control+c Control+g";
        execute = "Return KP_Enter Control+m";
        execute-or-next = "Tab";
        cursor-left = "Left Control+b";
        cursor-left-word = "Control+Left Mod1+b";
        cursor-right = "Right Control+f";
        cursor-right-word = "Control+Right Mod1+f";
        cursor-home = "Home Control+a";
        cursor-end = "End Control+e";
        delete-prev = "BackSpace Control+h";
        delete-prev-word = "Mod1+BackSpace Control+w";
        delete-next = "Delete Control+d";
        delete-next-word = "Mod1+d";
        prev = "Up Control+p";
        next = "Down Control+n";
        first = "Control+Home";
        last = "Control+End";
      };
    };
  };
}
