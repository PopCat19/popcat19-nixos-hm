{ pkgs, ... }:

{
  # Fuzzel Launcher Configuration - Enhanced with Rose Pine theme and QoL features.
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        layer = "overlay"; # Display as an overlay.
        exit-on-click = true; # Close on click outside.
        prompt = "  "; # Unicode search icon with space.
        placeholder = "Search applications...";
        width = 50; # Width in characters.
        lines = 12; # Number of lines to display.
        horizontal-pad = 20; # Horizontal padding.
        vertical-pad = 12; # Vertical padding.
        inner-pad = 8; # Padding between border and content.
        image-size-ratio = 0.8; # Size ratio for application icons.
        show-actions = true; # Show application actions.
        terminal = "kitty"; # Terminal for launching terminal applications.
        launch-prefix = ""; # Prefix for launching applications.
        filter-desktop = true; # Filter desktop files.
        icon-theme = "Papirus-Dark"; # Icon theme to use.
        icons-enabled = true; # Enable application icons.
        fields = "name,generic,comment,categories,filename,keywords"; # Search fields.
        password-character = "*"; # Character for password fields.
        tab-cycles = true; # Tab cycles through results.
        match-mode = "fzf"; # Use fuzzy matching algorithm.
        sort-result = true; # Sort search results.
        list-executables-in-path = false; # Don't list PATH executables.
      };
      colors = {
        background = "191724f0"; # Rose Pine base with higher opacity.
        text = "e0def4ff"; # Rose Pine text.
        match = "eb6f92ff"; # Rose Pine love (red) for matches.
        selection = "403d52ff"; # Rose Pine highlight medium for selection.
        selection-text = "e0def4ff"; # Rose Pine text for selected.
        selection-match = "f6c177ff"; # Rose Pine gold for selected matches.
        border = "ebbcbaff"; # Rose Pine rose for border.
        placeholder = "908caaff"; # Rose Pine subtle for placeholder.
      };
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
        delete-line = "Control+k";
        prev = "Up Control+p";
        next = "Down Control+n";
        page-up = "Page_Up Control+v";
        page-down = "Page_Down Mod1+v";
        first = "Control+Home";
        last = "Control+End";
      };
    };
  };
}