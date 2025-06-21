# ~/nixos-config/home.nix
{ pkgs, config, system, lib, inputs, ... }:

{
  # **BASIC HOME CONFIGURATION**
  # Sets up basic user home directory parameters.
  home.username = "popcat19";
  home.homeDirectory = "/home/popcat19";
  home.stateVersion = "24.05"; # Home Manager state version.

  # **ENVIRONMENT VARIABLES**
  # Defines user-specific environment variables for various applications.
  home.sessionVariables = {
    EDITOR = "micro"; # Default terminal editor.
    VISUAL = "$EDITOR"; # Visual editor alias.
    BROWSER = "flatpak run app.zen_browser.zen"; # Default web browser.
    QT_QPA_PLATFORMTHEME = "qt6ct"; # Qt6 platform theme.
    QT_STYLE_OVERRIDE = "kvantum"; # Qt style override.
    QT_QPA_PLATFORM = "wayland;xcb"; # Qt Wayland and XCB platform.

    # GTK theming environment variables
    GTK_THEME = "Rose-Pine-Main-BL"; # Force GTK theme
    GDK_BACKEND = "wayland,x11,*"; # GTK backend preference
    XCURSOR_THEME = "rose-pine-hyprcursor"; # X11 cursor theme
    XCURSOR_SIZE = "24"; # Cursor size
  };

  # Add local bin to PATH
  home.sessionPath = [ "$HOME/.local/bin" ];

  # **XDG MIME APPLICATIONS**
  # Disabled to allow manual configuration of default applications.
  # You can manually edit ~/.config/mimeapps.list to set Zen browser as default.
  # Example content for mimeapps.list:
  # [Default Applications]
  # x-scheme-handler/http=app.zen_browser.zen.desktop
  # x-scheme-handler/https=app.zen_browser.zen.desktop
  # XDG MIME Applications Configuration
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Web browsers
      "x-scheme-handler/http" = ["zen.desktop"];
      "x-scheme-handler/https" = ["zen.desktop"];
      "text/html" = ["zen.desktop"];
      "application/xhtml+xml" = ["zen.desktop"];

      # Terminal
      "application/x-terminal-emulator" = ["kitty.desktop"];
      "x-scheme-handler/terminal" = ["kitty.desktop"];

      # Text files
      "text/plain" = ["micro.desktop"];
      "text/x-readme" = ["micro.desktop"];
      "text/x-log" = ["micro.desktop"];
      "application/json" = ["micro.desktop"];
      "text/x-python" = ["micro.desktop"];
      "text/x-shellscript" = ["micro.desktop"];
      "text/x-script" = ["micro.desktop"];

      # Images
      "image/jpeg" = ["org.kde.gwenview.desktop"];
      "image/png" = ["org.kde.gwenview.desktop"];
      "image/gif" = ["org.kde.gwenview.desktop"];
      "image/webp" = ["org.kde.gwenview.desktop"];
      "image/svg+xml" = ["org.kde.gwenview.desktop"];

      # Videos
      "video/mp4" = ["mpv.desktop"];
      "video/mkv" = ["mpv.desktop"];
      "video/avi" = ["mpv.desktop"];
      "video/webm" = ["mpv.desktop"];
      "video/x-matroska" = ["mpv.desktop"];

      # Audio
      "audio/mpeg" = ["mpv.desktop"];
      "audio/ogg" = ["mpv.desktop"];
      "audio/wav" = ["mpv.desktop"];
      "audio/flac" = ["mpv.desktop"];

      # Archives
      "application/zip" = ["org.kde.ark.desktop"];
      "application/x-tar" = ["org.kde.ark.desktop"];
      "application/x-compressed-tar" = ["org.kde.ark.desktop"];
      "application/x-7z-compressed" = ["org.kde.ark.desktop"];

      # File manager
      "inode/directory" = ["org.kde.dolphin.desktop"];

      # PDF
      "application/pdf" = ["org.kde.okular.desktop"];
    };
    associations.added = {
      "application/x-terminal-emulator" = ["kitty.desktop"];
      "x-scheme-handler/terminal" = ["kitty.desktop"];
    };
  };

  # **THEMING CONFIGURATION**
  # Minimal theming setup - allows manual configuration via nwg-look and kvantum manager.
  # Only manages Hyprcursor for Hyprland compatibility.
  #
  # MANUAL THEMING INSTRUCTIONS:
  # - Use 'nwg-look' to configure GTK themes, icons, and fonts
  # - Use 'qt6ct' and kvantum manager for Qt theming
  # - Kvantum themes are available in ~/.config/Kvantum/ directory
  # - Available themes: RosePine, Catppuccin variants via packages

  # GTK Theme Configuration - Rose Pine themed.
  gtk = {
    enable = true;
    cursorTheme = {
      name = "rose-pine-hyprcursor";
      size = 24;
      package = inputs.rose-pine-hyprcursor.packages.${system}.default;
    };
    theme = {
      name = "Rose-Pine-Main-BL";
      package = pkgs.rose-pine-gtk-theme-full;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Rounded Mplus 1c Medium";
      size = 11;
    };

    # GTK3 specific settings
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-decoration-layout = "appmenu:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-primary-button-warps-slider = false;
    };


    # GTK4 specific settings
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-decoration-layout = "appmenu:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-primary-button-warps-slider = false;
    };
    # Force Medium weight for GTK applications
    gtk3.extraCss = ''
      * {
        font-family: "Rounded Mplus 1c Medium";
      }
    '';
    gtk4.extraCss = ''
      * {
        font-family: "Rounded Mplus 1c Medium";
      }
    '';

  };

  # QT Theme Configuration - Rose Pine themed.
  qt = {
    enable = true;
    style = {
      name = "kvantum";
      package = pkgs.libsForQt5.qtstyleplugin-kvantum;
    };
  };

  # Kvantum theme configuration
  home.file.".config/Kvantum/RosePine".source = "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/rose-pine-rose";

  # Kvantum configuration with application-specific overrides
  home.file.".config/Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=rose-pine-rose

    [Applications]
    dolphin=rose-pine-rose
    ark=rose-pine-rose
    gwenview=rose-pine-rose
    systemsettings=rose-pine-rose
    kate=rose-pine-rose
    kwrite=rose-pine-rose
  '';

  # Critical: kdeglobals configuration for KDE applications like Dolphin
  home.file.".config/kdeglobals" = {
    text = ''
      [ColorScheme]
      Name=Rose-Pine-Main-BL

      [Colors:Button]
      BackgroundAlternate=49,46,77
      BackgroundNormal=49,46,77
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=224,222,244
      ForegroundInactive=144,140,170
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [Colors:Selection]
      BackgroundAlternate=156,207,216
      BackgroundNormal=156,207,216
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=25,23,36
      ForegroundInactive=25,23,36
      ForegroundLink=25,23,36
      ForegroundNegative=25,23,36
      ForegroundNeutral=25,23,36
      ForegroundNormal=25,23,36
      ForegroundPositive=25,23,36
      ForegroundVisited=25,23,36

      [Colors:View]
      BackgroundAlternate=31,29,46
      BackgroundNormal=25,23,36
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=224,222,244
      ForegroundInactive=144,140,170
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [Colors:Window]
      BackgroundAlternate=49,46,77
      BackgroundNormal=25,23,36
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=224,222,244
      ForegroundInactive=144,140,170
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [General]
      ColorScheme=Rose-Pine-Main-BL
      Name=Rose Pine
      shadeSortColumn=true

      [KDE]
      contrast=4
      widgetStyle=kvantum

      [WM]
      activeBackground=49,46,77
      activeForeground=224,222,244
      inactiveBackground=25,23,36
      inactiveForeground=144,140,170
      activeBlend=156,207,216
      inactiveBlend=110,106,134

      [Icons]
      Theme=Papirus-Dark

      [General]
      TerminalApplication=kitty
      TerminalService=kitty.desktop

      [KFileDialog Settings]
      Allow Expansion=false
      Automatically select filename extension=true
      Breadcrumb Navigation=true
      Decoration position=2
      LocationCombo Completionmode=5
      PathCombo Completionmode=5
      Show Bookmarks=false
      Show Full Path=false
      Show Inline Previews=true
      Show Preview=false
      Show Speedbar=true
      Show hidden files=false
      Sort by=Name
      Sort directories first=true
      Sort hidden files last=false
      Sort reversed=false
      Speedbar Width=138
      View Style=DetailTree

      [PreviewSettings]
      Plugins=appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,textthumbnail,ffmpegthumbs
      MaximumSize=10485760
      EnableRemoteFolderThumbnail=false
    '';
    force = true;
  };

  # Qt6ct configuration for Rose Pine
  home.file.".config/qt6ct/qt6ct.conf" = {
    text = ''
      [Appearance]
      color_scheme_path=/home/popcat19/.config/Kvantum/RosePine/rose-pine-rose.kvconfig
      custom_palette=false
      icon_theme=Papirus-Dark
      standard_dialogs=default
      style=kvantum

      [Fonts]
      fixed="JetBrainsMono Nerd Font,11,-1,5,50,0,0,0,0,0"
      general="Rounded Mplus 1c Medium,11,-1,5,50,0,0,0,0,0"

      [Interface]
      activate_item_on_single_click=1
      buttonbox_layout=0
      cursor_flash_time=1000
      dialog_buttons_have_icons=1
      double_click_interval=400
      gui_effects=@Invalid()
      keyboard_scheme=2
      menus_have_icons=true
      show_shortcuts_in_context_menus=true
      stylesheets=@Invalid()
      toolbutton_style=4
      underline_shortcut=1
      wheel_scroll_lines=3
    '';
  };

  # Comprehensive dconf settings for theme consistency and thumbnails
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "rose-pine-hyprcursor";
      cursor-size = 24;
      gtk-theme = "Rose-Pine-Main-BL";
      icon-theme = "Papirus-Dark";
      font-name = "Rounded Mplus 1c Medium 11";
      document-font-name = "Rounded Mplus 1c Medium 11";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
      color-scheme = "prefer-dark";
    };
    "org/gnome/desktop/wm/preferences" = {
      theme = "Rose-Pine-Main-BL";
    };
    "org/gnome/desktop/thumbnailers" = {
      disable-all = false;
    };
    "org/gnome/nautilus/preferences" = {
      show-image-thumbnails = "always";
      thumbnail-limit = 10;
      show-directory-item-counts = "always";
    };
    "org/nemo/preferences" = {
      show-image-thumbnails = true;
      thumbnail-limit = 10485760;
      show-thumbnails = true;
    };
    "org/gnome/desktop/privacy" = {
      remember-recent-files = true;
      recent-files-max-age = 30;
    };
  };

  # Services for proper theme integration
  # Manual polkit authentication agent service
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = [ "graphical-session.target" ];
      WantedBy = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Systemd services for theme initialization
  systemd.user.services.theme-init = {
    Unit = {
      Description = "Initialize theme settings";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 2 && ${pkgs.dconf}/bin/dconf update'";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # **PROGRAM CONFIGURATIONS**
  # Configures specific user programs.

  # Kitty Terminal Configuration with Rose Pine theme
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
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

  # Fuzzel Launcher Configuration - Enhanced with Rose Pine theme and QoL features.
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Rounded Mplus 1c Medium:size=14";
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

  # Fish Shell Configuration.
  programs.fish = {
    enable = true;
    shellInit = ''
      set -Ux NIXOS_CONFIG_DIR $HOME/nixos-config
      set -Ux NIXOS_FLAKE_HOSTNAME popcat19-nixos0
      set -g fish_greeting "" # Disable default fish greeting.

      # Custom greeting disabled - fastfetch removed
      function fish_greeting
          # Empty greeting
      end
      fish_add_path $HOME/bin # Add user's bin directory to PATH.
      if status is-interactive
          starship init fish | source # Initialize Starship prompt.
      end
    '';
    # Custom shell abbreviations for convenience.
    shellAbbrs = {
      # Navigation shortcuts.
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";

      # File Operations using eza.
      mkdir = "mkdir -p";
      l = "eza -lh --icons=auto";
      ls = "eza -1 --icons=auto";
      ll = "eza -lha --icons=auto --sort=name --group-directories-first";
      ld = "eza -lhD --icons=auto";
      lt = "eza --tree --icons=auto";
      o = "open_smart"; # Custom function to open files.

      # NixOS Configuration Management.
      nconf = "nixconf-edit";
      nixos-ed = "nixconf-edit";
      hconf = "homeconf-edit";
      home-ed = "homeconf-edit";
      flconf = "flake-edit";
      flake-ed = "flake-edit";
      flup = "flake-update";
      flake-up = "flake-update";
      ngit = "nixos-git";

      # NixOS Build and Switch operations.
      nrb = "nixos-apply-config";
      nixos-sw = "nixos-apply-config";
      nerb = "nixos-edit-rebuild";
      nixoss = "nixos-edit-rebuild";
      herb = "home-edit-rebuild";
      home-sw = "home-edit-rebuild";
      nup = "nixos-upgrade";
      nixos-up = "nixos-upgrade";

      # Package Management with nixpkg.
      pkgls = "nixpkg list";
      pkgadd = "nixpkg add";
      pkgrm = "nixpkg remove";
      pkgs = "nixpkg search";
      pkghelp = "nixpkg help";
      pkgman = "nixpkg manual";
      pkgaddr = "nixpkg add --rebuild";
      pkgrmr = "nixpkg remove --rebuild";
    };
  };

  # Starship Prompt: a cross-shell prompt with Rose Pine theme.
  programs.starship = {
    enable = true;
    settings = {
      format = "$all$character";

      palette = "rose_pine";

      palettes.rose_pine = {
        base = "#191724";
        surface = "#1f1d2e";
        overlay = "#26233a";
        muted = "#6e6a86";
        subtle = "#908caa";
        text = "#e0def4";
        love = "#eb6f92";
        gold = "#f6c177";
        rose = "#ebbcba";
        pine = "#31748f";
        foam = "#9ccfd8";
        iris = "#c4a7e7";
        highlight_low = "#21202e";
        highlight_med = "#403d52";
        highlight_high = "#524f67";
      };

      character = {
        success_symbol = "[❯](bold foam)";
        error_symbol = "[❯](bold love)";
        vimcmd_symbol = "[❮](bold iris)";
      };

      directory = {
        style = "bold iris";
        truncation_length = 3;
        truncate_to_repo = false;
        format = "[$path]($style)[$read_only]($read_only_style) ";
        read_only = " 󰌾";
        read_only_style = "love";
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
        symbol = " ";
        style = "bold pine";
      };

      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        style = "bold rose";
        conflicted = "=";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        up_to_date = "";
        untracked = "?\${count}";
        stashed = "$\${count}";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»\${count}";
        deleted = "✘\${count}";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "bold gold";
        min_time = 2000;
      };

      hostname = {
        ssh_only = true;
        format = "[$hostname]($style) in ";
        style = "bold foam";
      };

      username = {
        show_always = false;
        format = "[$user]($style)@";
        style_user = "bold text";
        style_root = "bold love";
      };

      package = {
        format = "[$symbol$version]($style) ";
        symbol = "📦 ";
        style = "bold rose";
      };

      nodejs = {
        format = "[$symbol($version)]($style) ";
        symbol = " ";
        style = "bold pine";
      };

      python = {
        format = "[\${symbol}\${pyenv_prefix}(\${version})(\\($virtualenv\\))]($style) ";
        symbol = " ";
        style = "bold gold";
      };

      rust = {
        format = "[$symbol($version)]($style) ";
        symbol = " ";
        style = "bold love";
      };

      nix_shell = {
        format = "[$symbol$state(\\($name\\))]($style) ";
        symbol = " ";
        style = "bold iris";
        impure_msg = "[impure](bold love)";
        pure_msg = "[pure](bold foam)";
      };

      memory_usage = {
        disabled = false;
        threshold = 70;
        format = "[$symbol\${ram}(\${swap})]($style) ";
        symbol = "🐏 ";
        style = "bold subtle";
      };

      time = {
        disabled = false;
        format = "[$time]($style) ";
        style = "bold muted";
        time_format = "%T";
        utc_time_offset = "local";
      };

      status = {
        disabled = false;
        format = "[$symbol$status]($style) ";
        symbol = "✖ ";
        style = "bold love";
      };
    };
  };

  # Git Configuration for user details.
  programs.git = {
    enable = true;
    userName = "PopCat19";
    userEmail = "atsuo11111@gmail.com";
  };

  # **INPUT METHOD CONFIGURATION**
  # Configures Fcitx5 for input methods.
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk # GTK module.
      libsForQt5.fcitx5-qt # Qt module.
      fcitx5-mozc # Mozc input method engine for Japanese.
      fcitx5-rose-pine # Rose Pine theme for fcitx5.
    ];
  };

  # fcitx5 Rose Pine theme configuration
  home.file.".config/fcitx5/conf/classicui.conf".text = ''
    # Vertical Candidate List
    Vertical Candidate List=False
    # Use Per Screen DPI
    PerScreenDPI=True
    # Use mouse wheel to go to prev or next page
    WheelForPaging=True
    # Font
    Font="Rounded Mplus 1c Medium 11"
    # Menu Font
    MenuFont="Rounded Mplus 1c Medium 11"
    # Tray Font
    TrayFont="Rounded Mplus 1c Medium 11"
    # Tray Label Outline Color
    TrayOutlineColor=#000000
    # Tray Label Text Color
    TrayTextColor=#ffffff
    # Prefer Text Icon
    PreferTextIcon=False
    # Show Layout Name In Icon
    ShowLayoutNameInIcon=True
    # Use input method language to display text
    UseInputMethodLangaugeToDisplayText=True
    # Rose Pine Theme
    Theme=rose-pine
    # Dark Theme
    DarkTheme=rose-pine
    # Follow system light/dark color scheme
    UseDarkTheme=True
    # Use accent color
    UseAccentColor=True
    # Use system tray icon
    EnableTray=True
    # Show preedit in application
    ShowPreeditInApplication=False
  '';

  # Manually link fcitx5 rose pine themes to user directory
  home.file.".local/share/fcitx5/themes/rose-pine".source = "${pkgs.fcitx5-rose-pine}/share/fcitx5/themes/rose-pine";
  home.file.".local/share/fcitx5/themes/rose-pine-dawn".source = "${pkgs.fcitx5-rose-pine}/share/fcitx5/themes/rose-pine-dawn";
  home.file.".local/share/fcitx5/themes/rose-pine-moon".source = "${pkgs.fcitx5-rose-pine}/share/fcitx5/themes/rose-pine-moon";

  # Fontconfig alias to ensure GTK finds the Medium weight
  home.file.".config/fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>Rounded Mplus 1c Medium</family>
        </prefer>
      </alias>
      <alias>
        <family>Rounded Mplus 1c Medium</family>
        <default>
          <family>sans-serif</family>
        </default>
      </alias>
    </fontconfig>
  '';

  # **FONTS CONFIGURATION**
  # Manages symlinks for configuration files.
  home.file.".config/hypr" = {
    source = ./hypr_config;
    recursive = true;
  };

  home.file.".config/fish/functions" = {
    source = ./fish_functions;
    recursive = true;
  };

  home.file.".config/fish/themes" = {
    source = ./fish_themes;
    recursive = true;
  };



  # Micro editor colorscheme - temporarily disabled for build
  home.file.".config/micro/colorschemes/rose-pine.micro" = {
    source = ./micro_config/rose-pine.micro;
  };

  # MangoHud configuration with Rose Pine theme
  home.file.".config/MangoHud/MangoHud.conf" = {
    text = ''
      ################### Declarative MangoHud Configuration ###################
      legacy_layout=false

      background_alpha=0.0
      round_corners=0
      background_color=191724
      font_file=
      font_size=14
      text_color=e0def4
      position=middle-left
      toggle_hud=Shift_R+F12
      hud_compact
      pci_dev=0:12:00.0
      table_columns=2

      gpu_text=
      gpu_stats
      gpu_load_change
      gpu_load_value=50,90
      gpu_load_color=e0def4,f6c177,eb6f92
      gpu_voltage
      gpu_core_clock
      gpu_temp
      gpu_mem_temp
      gpu_junction_temp
      gpu_fan
      gpu_power
      gpu_color=9ccfd8

      cpu_text=
      cpu_stats
      cpu_load_change
      cpu_load_value=50,90
      cpu_load_color=e0def4,f6c177,eb6f92
      cpu_mhz
      cpu_temp
      cpu_color=31748f

      vram
      vram_color=c4a7e7
      ram
      ram_color=c4a7e7
      battery
      battery_color=9ccfd8

      fps
      fps_metrics=avg,0.01
      frame_timing
      frametime_color=ebbcba
      throttling_status_graph
      fps_limit_method=early
      toggle_fps_limit=none
      fps_limit=0
      fps_color_change
      fps_color=eb6f92,f6c177,9ccfd8
      fps_value=60,90

      af=8
      output_folder=/home/popcat19
      log_duration=30
      autostart_log=0
      log_interval=100
      toggle_logging=Shift_L+F2
    '';
  };

  # Screenshot scripts
  home.file.".local/bin/screenshot-full" = {
    text = ''
      #!/usr/bin/env bash

      # Enhanced Full Screen Screenshot Script
      # Takes a screenshot of the current monitor with hyprshade support

      set -euo pipefail

      # Configuration
      SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
      TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
      FILENAME="screenshot_''${TIMESTAMP}.png"
      FILEPATH="''${SCREENSHOT_DIR}/''${FILENAME}"

      # Ensure screenshot directory exists
      mkdir -p "$SCREENSHOT_DIR"

      # Function to get current monitor
      get_current_monitor() {
          if command -v hyprctl &> /dev/null; then
              hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'
          else
              echo ""
          fi
      }

      # Function to manage hyprshade
      manage_hyprshade() {
          local action="$1"
          if command -v hyprshade &> /dev/null; then
              case "$action" in
                  "off")
                      CURRENT_SHADER=$(hyprshade current 2>/dev/null || echo "")
                      if [[ -n "$CURRENT_SHADER" && "$CURRENT_SHADER" != "Off" ]]; then
                          hyprshade off >/dev/null 2>&1
                          echo "$CURRENT_SHADER"
                      else
                          echo ""
                      fi
                      ;;
                  "restore")
                      local shader="$2"
                      if [[ -n "$shader" ]]; then
                          hyprshade on "$shader" >/dev/null 2>&1
                      fi
                      ;;
              esac
          fi
      }

      # Take screenshot using grim (Wayland screenshot tool)
      if command -v grim &> /dev/null; then
          # Get current monitor
          CURRENT_MONITOR=$(get_current_monitor)

          # Save current shader and turn off hyprshade for clean capture
          SAVED_SHADER=$(manage_hyprshade "off")

          # Small delay to ensure shader is off
          sleep 0.1

          # Take screenshot
          if [[ -n "$CURRENT_MONITOR" ]]; then
              grim -o "$CURRENT_MONITOR" "$FILEPATH"
              echo "Screenshot of monitor '$CURRENT_MONITOR' saved to: $FILEPATH"
          else
              grim "$FILEPATH"
              echo "Screenshot saved to: $FILEPATH"
          fi

          # Restore shader if it was active
          if [[ -n "$SAVED_SHADER" ]]; then
              manage_hyprshade "restore" "$SAVED_SHADER"
          fi

          # Copy to clipboard if wl-copy is available
          if command -v wl-copy &> /dev/null; then
              wl-copy < "$FILEPATH"
              echo "Screenshot copied to clipboard"
          else
              echo "wl-copy not found - screenshot not copied to clipboard"
          fi

          # Show notification if notify-send is available
          if command -v notify-send &> /dev/null; then
              notify-send "Screenshot" "Full screenshot saved to Pictures/Screenshots" -i "$FILEPATH"
          fi

      else
          echo "Error: grim not found. Please install grim for Wayland screenshots."
          exit 1
      fi
    '';
    executable = true;
  };

  home.file.".local/bin/screenshot-region" = {
    text = ''
      #!/usr/bin/env bash

      # Enhanced Region Screenshot Script
      # Takes a screenshot of a selected region with hyprshade support

      set -euo pipefail

      # Configuration
      SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
      TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
      FILENAME="screenshot_region_''${TIMESTAMP}.png"
      FILEPATH="''${SCREENSHOT_DIR}/''${FILENAME}"

      # Ensure screenshot directory exists
      mkdir -p "$SCREENSHOT_DIR"

      # Function to get current monitor
      get_current_monitor() {
          if command -v hyprctl &> /dev/null; then
              hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'
          else
              echo ""
          fi
      }

      # Function to manage hyprshade
      manage_hyprshade() {
          local action="$1"
          if command -v hyprshade &> /dev/null; then
              case "$action" in
                  "off")
                      CURRENT_SHADER=$(hyprshade current 2>/dev/null || echo "")
                      if [[ -n "$CURRENT_SHADER" && "$CURRENT_SHADER" != "Off" ]]; then
                          hyprshade off >/dev/null 2>&1
                          echo "$CURRENT_SHADER"
                      else
                          echo ""
                      fi
                      ;;
                  "restore")
                      local shader="$2"
                      if [[ -n "$shader" ]]; then
                          hyprshade on "$shader" >/dev/null 2>&1
                      fi
                      ;;
              esac
          fi
      }

      # Cleanup function to restore hyprshade on exit
      cleanup() {
          if [[ -n "''${SAVED_SHADER:-}" ]]; then
              manage_hyprshade "restore" "$SAVED_SHADER"
          fi
      }

      # Set trap to restore hyprshade on script exit (including ESC/SIGINT)
      trap cleanup EXIT INT TERM

      # Take region screenshot using grim + slurp (Wayland screenshot tools)
      if command -v grim &> /dev/null && command -v slurp &> /dev/null; then
          # Get current monitor for slurp constraint
          CURRENT_MONITOR=$(get_current_monitor)

          # Save current shader and turn off hyprshade for clean capture
          SAVED_SHADER=$(manage_hyprshade "off")

          # Small delay to ensure shader is off
          sleep 0.1

          # Use slurp to select region (constrain to current monitor if available)
          if [[ -n "$CURRENT_MONITOR" ]]; then
              REGION=$(slurp -o "$CURRENT_MONITOR" 2>/dev/null || slurp)
          else
              REGION=$(slurp)
          fi

          if [[ -n "$REGION" ]]; then
              grim -g "$REGION" "$FILEPATH"

              echo "Region screenshot saved to: $FILEPATH"

              # Copy to clipboard if wl-copy is available
              if command -v wl-copy &> /dev/null; then
                  wl-copy < "$FILEPATH"
                  echo "Screenshot copied to clipboard"
              else
                  echo "wl-copy not found - screenshot not copied to clipboard"
              fi

              # Show notification if notify-send is available
              if command -v notify-send &> /dev/null; then
                  notify-send "Screenshot" "Region screenshot saved to Pictures/Screenshots" -i "$FILEPATH"
              fi
          else
              echo "Screenshot cancelled - no region selected"
              exit 0
          fi

      elif command -v grim &> /dev/null; then
          echo "Error: slurp not found. Please install slurp for region selection."
          exit 1
      else
          echo "Error: grim not found. Please install grim for Wayland screenshots."
          exit 1
      fi
    '';
    executable = true;
  };

  # Theme checker utility script
  home.file.".local/bin/check-rose-pine-theme" = {
    text = ''
      #!/usr/bin/env bash

      # Rose Pine Theme Status Checker
      # Simple script to verify Rose Pine theming is working correctly

      set -euo pipefail

      # Color codes
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      YELLOW='\033[1;33m'
      BLUE='\033[0;34m'
      PURPLE='\033[0;35m'
      NC='\033[0m'

      print_header() {
          echo -e "''${PURPLE} Rose Pine Theme Status''${NC}"
          echo -e "''${PURPLE}══════════════════════════''${NC}"
          echo ""
      }

      check_environment() {
          echo -e "''${BLUE} Environment Variables''${NC}"

          if [[ "''${QT_QPA_PLATFORMTHEME:-}" == "qt6ct" ]]; then
              echo -e "''${GREEN} QT_QPA_PLATFORMTHEME: qt6ct''${NC}"
          else
              echo -e "''${RED} QT_QPA_PLATFORMTHEME: ''${QT_QPA_PLATFORMTHEME:-unset} (should be 'qt6ct')''${NC}"
          fi

          if [[ "''${QT_STYLE_OVERRIDE:-}" == "kvantum" ]]; then
              echo -e "''${GREEN} QT_STYLE_OVERRIDE: kvantum''${NC}"
          else
              echo -e "''${RED} QT_STYLE_OVERRIDE: ''${QT_STYLE_OVERRIDE:-unset} (should be 'kvantum')''${NC}"
          fi
          echo ""
      }

      check_theme_files() {
          echo -e "''${BLUE} Theme Files''${NC}"

          local rosepine_dir="$HOME/.config/Kvantum/RosePine"
          if [[ -d "$rosepine_dir" ]] || [[ -L "$rosepine_dir" ]]; then
              echo -e "''${GREEN} Rose Pine theme directory found''${NC}"
              if [[ -f "$rosepine_dir/rose-pine-rose.kvconfig" ]]; then
                  echo -e "''${GREEN} Rose Pine Kvantum config found''${NC}"
              else
                  echo -e "''${YELLOW} Rose Pine Kvantum config missing''${NC}"
              fi
          else
              echo -e "''${RED} Rose Pine theme directory missing: $rosepine_dir''${NC}"
          fi
          echo ""
      }

      check_configuration() {
          echo -e "''${BLUE} Configuration Files''${NC}"

          # Check kdeglobals
          if [[ -f "$HOME/.config/kdeglobals" ]]; then
              if grep -q "ColorScheme=Rose-Pine-Main-BL" "$HOME/.config/kdeglobals" 2>/dev/null; then
                  echo -e "''${GREEN} kdeglobals: Rose Pine configured''${NC}"
              else
                  echo -e "''${YELLOW} kdeglobals: exists but may not be Rose Pine''${NC}"
              fi
          else
              echo -e "''${RED} kdeglobals: missing''${NC}"
          fi

          # Check Kvantum config
          if [[ -f "$HOME/.config/Kvantum/kvantum.kvconfig" ]]; then
              if grep -q "theme=rose-pine-rose" "$HOME/.config/Kvantum/kvantum.kvconfig" 2>/dev/null; then
                  echo -e "''${GREEN} Kvantum: Rose Pine configured''${NC}"
              else
                  echo -e "''${YELLOW} Kvantum: exists but theme may not be Rose Pine''${NC}"
              fi
          else
              echo -e "''${RED} Kvantum config: missing''${NC}"
          fi

          # Check Qt6ct config
          if [[ -f "$HOME/.config/qt6ct/qt6ct.conf" ]]; then
              if grep -q "style=kvantum" "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null; then
                  echo -e "''${GREEN} Qt6ct: Kvantum style configured''${NC}"
              else
                  echo -e "''${YELLOW} Qt6ct: exists but style may not be Kvantum''${NC}"
              fi
          else
              echo -e "''${RED} Qt6ct config: missing''${NC}"
          fi
          echo ""
      }

      test_applications() {
          echo -e "''${BLUE} Test Applications''${NC}"

          if command -v dolphin &> /dev/null; then
              echo -e "''${GREEN} Dolphin available''${NC}"
              echo -e "''${YELLOW}  Run 'dolphin' to test theming''${NC}"
          else
              echo -e "''${RED} Dolphin not found''${NC}"
          fi

          if command -v kvantummanager &> /dev/null; then
              echo -e "''${GREEN} Kvantum Manager available''${NC}"
              echo -e "''${YELLOW}  Run 'kvantummanager' for theme management''${NC}"
          else
              echo -e "''${YELLOW} Kvantum Manager not found''${NC}"
          fi

          if command -v qt6ct &> /dev/null; then
              echo -e "''${GREEN} Qt6ct available''${NC}"
              echo -e "''${YELLOW}  Run 'qt6ct' for Qt configuration''${NC}"
          else
              echo -e "''${YELLOW} Qt6ct not found''${NC}"
          fi
          echo ""
      }

      show_troubleshooting() {
          echo -e "''${BLUE} Troubleshooting Tips''${NC}"
          echo ""
          echo -e "''${YELLOW}If theming is not working:''${NC}"
          echo "1. Restart KDE applications: pkill dolphin && dolphin &"
          echo "2. Logout and login to reload environment variables"
          echo "3. Restart Hyprland session"
          echo "4. Check Home Manager rebuild: home-manager switch"
          echo ""
          echo -e "''${YELLOW}Manual theme tools:''${NC}"
          echo " kvantummanager - Kvantum theme manager"
          echo " qt6ct - Qt6 configuration tool"
          echo " nwg-look - GTK theme configuration"
          echo ""
      }

      print_summary() {
          echo -e "''${PURPLE} Summary''${NC}"
          echo ""
          echo "Your system is configured for Rose Pine theming with:"
          echo " Rose Pine GTK theme (Rose-Pine-Main-BL) for GTK applications"
          echo " Rose Pine Kvantum theme for Qt applications"
          echo " KDE kdeglobals for Dolphin and KDE apps"
          echo " Qt6ct for Qt6 application theming"
          echo ""
          echo -e "''${GREEN} Enjoy your Rose Pine themed desktop!''${NC}"
      }

      main() {
          print_header
          check_environment
          check_theme_files
          check_configuration
          test_applications
          show_troubleshooting
          print_summary
      }

      main "$@"
    '';
    executable = true;
  };

  # **SYSTEM SERVICES**
  # Enables user-level services.
  services = {
    # Media Control services.
    playerctld.enable = true; # D-Bus interface for media players.
    mpris-proxy.enable = true; # MPRIS proxy for media players.

    # Storage Management.
    udiskie.enable = true; # Automount removable media.

    # Audio Effects.
    easyeffects.enable = true; # Audio effects for PipeWire.

    # Clipboard Management.
    cliphist.enable = true; # Clipboard history manager.

    # AI/ML Services.
    ollama = {
      enable = true;
      acceleration = "rocm"; # Enable ROCm acceleration for Ollama.
    };
  };

  # **INSTALLED PACKAGES**
  # List of packages installed for the user via Home Manager.
  home.packages = with pkgs; [
    # GTK theme management
    nwg-look
    dconf-editor
    kitty
    fuzzel
    jq
    fastfetch
    # Fonts
    nerd-fonts.caskaydia-cove
    nerd-fonts.fantasque-sans-mono
    # Gaming and monitoring
    mangohud
    goverlay
    # Additional theme packages
    catppuccin-cursors
    # Screenshot utilities
    grim
    slurp
    wl-clipboard
    swappy
    satty
    libnotify
    zenity
    hyprpicker
    hyprpolkitagent
    hyprutils
    hyprshade
    hyprpanel
    vesktop
    zed-editor_git
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.gwenview
    # KDE theming packages
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    nautilus
    nemo
    mpv
    audacious
    audacious-plugins
    obs-studio
    lutris
    osu-lazer-bin
    pavucontrol
    playerctl
    btop-rocm
    glances
    tree
    ddcui
    openrgb-with-all-plugins
    universal-android-debloater
    android-tools
    sunxi-tools
    binwalk
    pv
    git-lfs
    vboot_reference
    parted
    squashfsTools
    nixos-install-tools
    nixos-generators
    scrcpy
    localsend
    zrok
    keepassxc
    mangayomi
    ollama-rocm
    starship
    eza
    libsForQt5.qt5ct
    qt6ct
    rose-pine-kvantum
    rose-pine-gtk-theme-full
    themechanger
    nwg-look
    dconf-editor
    # Essential applications
    kdePackages.okular
    micro
    # Thumbnail generation
    ffmpegthumbnailer
    poppler_utils
    libgsf
    webp-pixbuf-loader
    # KDE thumbnail generators
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kimageformats
    kdePackages.kio-extras
    # Additional theming packages for manual configuration
    catppuccin-gtk
    papirus-icon-theme
    adwaita-icon-theme
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    polkit_gnome
    gsettings-desktop-schemas
    nerd-fonts.jetbrains-mono
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    inputs.zen-browser.packages."${system}".default
  ];

  # Additional GTK theme files for better consistency
  home.file.".config/gtk-3.0/bookmarks".text = ''
    file:///home/${config.home.username}/Documents Documents
    file:///home/${config.home.username}/Downloads Downloads
    file:///home/${config.home.username}/Pictures Pictures
    file:///home/${config.home.username}/Videos Videos
    file:///home/${config.home.username}/Music Music
    file:///home/${config.home.username}/syncthing-shared syncthing-shared
    file:///home/${config.home.username}/Desktop Desktop
    trash:/// Trash
  '';

  # Dolphin file manager bookmarks
  home.file.".local/share/user-places.xbel".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE xbel PUBLIC "+//IDN python.org//DTD XML Bookmark Exchange Language 1.0//EN//XML" "http://www.python.org/topics/xml/dtds/xbel-1.0.dtd">
    <xbel version="1.0">
     <bookmark href="file:///home/${config.home.username}">
      <title>Home</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/Documents">
      <title>Documents</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/Downloads">
      <title>Downloads</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/Pictures">
      <title>Pictures</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/Videos">
      <title>Videos</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/Music">
      <title>Music</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/syncthing-shared">
      <title>syncthing-shared</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/Desktop">
      <title>Desktop</title>
     </bookmark>
     <bookmark href="trash:/">
      <title>Trash</title>
     </bookmark>
    </xbel>
  '';


  # Dolphin configuration with enhanced thumbnails and better opacity
  home.file.".config/dolphinrc".text = ''
    [General]
    BrowseThroughArchives=true
    EditableUrl=false
    GlobalViewProps=false
    HomeUrl=file:///home/${config.home.username}
    ModifiedStartupSettings=true
    OpenExternallyCalledFolderInNewTab=false
    RememberOpenedTabs=true
    ShowFullPath=false
    ShowFullPathInTitlebar=false
    ShowSpaceInfo=false
    ShowZoomSlider=true
    SortingChoice=CaseSensitiveSorting
    SplitView=false
    UseTabForSwitchingSplitView=false
    Version=202
    ViewPropsTimestamp=2024,1,1,0,0,0

    [KFileDialog Settings]
    Places Icons Auto-resize=false
    Places Icons Static Size=22

    [MainWindow]
    MenuBar=Disabled
    ToolBarsMovable=Disabled

    [PlacesPanel]
    IconSize=22

    [PreviewSettings]
    Plugins=appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,textthumbnail,ffmpegthumbs
    MaximumSize=10485760
    EnableRemoteFolderThumbnail=false
    MaximumRemoteSize=0

    [DesktopIcons]
    Size=48

    [CompactMode]
    PreviewSize=32

    [DetailsMode]
    PreviewSize=32

    [IconsMode]
    PreviewSize=128
  '';

  # KDE thumbnail configuration for better thumbnail support
  home.file.".config/kservices5/ServiceMenus/konsole.desktop".text = ''
    [Desktop Entry]
    Type=Service
    ServiceTypes=KonqPopupMenu/Plugin
    MimeType=inode/directory;
    Actions=konsole_here;

    [Desktop Action konsole_here]
    Name=Open Terminal Here
    Icon=utilities-terminal
    Exec=kitty --working-directory %f
  '';

  # Create directory for syncthing-shared
  home.activation.createSyncthingDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/syncthing-shared
  '';

  # Additional desktop files for better integration
  home.file.".local/share/applications/kitty.desktop".text = ''
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Kitty
    GenericName=Terminal
    Comment=A modern, hackable, featureful, OpenGL-based terminal emulator
    TryExec=kitty
    Exec=kitty
    Icon=kitty
    Categories=System;TerminalEmulator;
    StartupNotify=true
    MimeType=application/x-terminal-emulator;x-scheme-handler/terminal;
  '';

  home.file.".local/share/applications/micro.desktop".text = ''
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Micro
    GenericName=Text Editor
    Comment=A modern and intuitive terminal-based text editor
    TryExec=micro
    Exec=micro %F
    Icon=text-editor
    Categories=Utility;TextEditor;Development;
    StartupNotify=false
    MimeType=text/plain;text/x-readme;text/x-log;application/json;text/x-python;text/x-shellscript;text/x-script;
    Terminal=true
  '';

  # Nemo file manager configuration with Rose Pine theme and kitty terminal
  home.file.".config/nemo/nemo.conf".text = ''
    [preferences]
    default-folder-viewer=list-view
    show-hidden-files=false
    show-location-entry=false
    start-with-dual-pane=false
    inherit-folder-viewer=true
    ignore-view-metadata=false
    default-sort-order=name
    default-sort-type=ascending
    size-prefixes=base-10
    quick-renames-with-pause-in-between=true
    show-compact-view-icon-toolbar=false
    show-compact-view-icon-toolbar-icons-small=false
    show-compact-view-text-beside-icons=false
    show-full-path-titles=true
    show-new-folder-icon-toolbar=true
    show-open-in-terminal-toolbar=true
    show-reload-icon-toolbar=true
    show-search-icon-toolbar=true
    show-edit-icon-toolbar=false
    show-home-icon-toolbar=true
    show-computer-icon-toolbar=false
    show-up-icon-toolbar=true
    terminal-command=kitty
    close-device-view-on-device-eject=true
    thumbnail-limit=10485760
    executable-text-activation=ask
    show-image-thumbnails=true
    show-thumbnails=true

    [window-state]
    geometry=800x600+0+0
    maximized=false
    sidebar-width=200
    start-with-sidebar=true
    start-with-status-bar=true
    start-with-toolbar=true
    sidebar-bookmark-breakpoint=5

    [list-view]
    default-zoom-level=standard
    default-visible-columns=name,size,type,date_modified
    default-column-order=name,size,type,date_modified

    [icon-view]
    default-zoom-level=standard

    [compact-view]
    default-zoom-level=standard
  '';

  # Nemo actions for better context menu integration
  home.file.".local/share/nemo/actions/open-in-kitty.nemo_action".text = ''
    [Nemo Action]
    Name=Open in Terminal
    Comment=Open a terminal in this location
    Exec=kitty --working-directory %f
    Icon-Name=utilities-terminal
    Selection=None
    Extensions=dir;
  '';

  home.file.".local/share/nemo/actions/edit-as-root.nemo_action".text = ''
    [Nemo Action]
    Name=Edit as Root
    Comment=Edit this file with root privileges
    Exec=pkexec micro %F
    Icon-Name=accessories-text-editor
    Selection=S
    Extensions=any;
  '';

  # Thumbnail cache update script
  home.file.".local/bin/update-thumbnails".text = ''
    #!/usr/bin/env bash

    # Clear thumbnail cache
    rm -rf ~/.cache/thumbnails/*

    # Update desktop database
    update-desktop-database ~/.local/share/applications 2>/dev/null || true

    # Update MIME database
    update-mime-database ~/.local/share/mime 2>/dev/null || true

    # Regenerate thumbnails for common directories by touching files
    find ~/Pictures ~/Downloads ~/Videos ~/Music -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" -o -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" \) -exec touch {} \; 2>/dev/null || true

    echo "Thumbnail cache cleared and databases updated"
  '';

  home.file.".local/bin/update-thumbnails".executable = true;

  # KDE Service Menu for terminal integration
  home.file.".local/share/kio/servicemenus/open-terminal-here.desktop".text = ''
    [Desktop Entry]
    Type=Service
    ServiceTypes=KonqPopupMenu/Plugin
    MimeType=inode/directory;
    Actions=openTerminalHere;

    [Desktop Action openTerminalHere]
    Name=Open Terminal Here
    Name[en_US]=Open Terminal Here
    Icon=utilities-terminal
    Exec=kitty --working-directory %f
  '';

  # Micro text editor configuration
  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "rose-pine";
      mkparents = true;
      softwrap = true;
      wordwrap = true;
      tabsize = 4;
      autoclose = true;
      autoindent = true;
      autosave = 5;
      clipboard = "terminal";
      cursorline = true;
      diffgutter = true;
      ignorecase = true;
      scrollbar = true;
      smartpaste = true;
      statusline = true;
      syntax = true;
      tabstospaces = true;
    };
  };

  # Systemd user service for thumbnail cache updates
  systemd.user.services.thumbnail-update = {
    Unit = {
      Description = "Update thumbnail cache on login";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/.local/bin/update-thumbnails";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Additional environment variables for better integration
  home.sessionVariables = {
    TERMINAL = "kitty";
    FILE_MANAGER = "dolphin";
    # Ensure thumbnails work properly
    WEBKIT_DISABLE_COMPOSITING_MODE = "1";
  };
}
