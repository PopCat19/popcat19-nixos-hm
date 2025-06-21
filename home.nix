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
  # text/html=app.zen_browser.zen.desktop
  # application/xhtml+xml=app.zen_browser.zen.desktop
  # xdg.mimeApps = {
  #   enable = true;
  #   defaultApplications = {
  #     "x-scheme-handler/http" = ["app.zen_browser.zen.desktop"];
  #     "x-scheme-handler/https" = ["app.zen_browser.zen.desktop"];
  #     "text/html" = ["app.zen_browser.zen.desktop"];
  #     "application/xhtml+xml" = ["app.zen_browser.zen.desktop"];
  #   };
  # };

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
      name = "rose-pine-gtk-theme";
      package = pkgs.rose-pine-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "CaskaydiaCove Nerd Font";
      size = 11;
    };
  };

  # QT Theme Configuration - Rose Pine themed.
  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
    style = {
      name = "kvantum";
      package = pkgs.libsForQt5.qtstyleplugin-kvantum;
    };
  };

  # Kvantum theme configuration
  home.file.".config/Kvantum/RosePine".source = "${pkgs.rose-pine-kvantum}/share/Kvantum/RosePine";

  # Qt6ct configuration for Rose Pine
  home.file.".config/qt6ct/qt6ct.conf" = {
    text = ''
      [Appearance]
      color_scheme_path=/home/popcat19/.config/Kvantum/RosePine/RosePine.kvconfig
      custom_palette=false
      icon_theme=Papirus-Dark
      standard_dialogs=default
      style=kvantum

      [Fonts]
      fixed="CaskaydiaCove Nerd Font,11,-1,5,50,0,0,0,0,0"
      general="CaskaydiaCove Nerd Font,11,-1,5,50,0,0,0,0,0"

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

  # Minimal dconf settings - only for cursor theme consistency in Hyprland
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "rose-pine-hyprcursor";
      cursor-size = 24;
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
      name = "CaskaydiaCove Nerd Font Mono";
      size = 9;
    };
    settings = {
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
      window_margin_width = 0;
      window_padding_width = 25;
      active_border_color = "#ebbcba";
      inactive_border_color = "#26233a";

      # Tab bar
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "angled";
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
      background_opacity = "0.95";
      dynamic_background_opacity = "yes";
      background_blur = 1;
    };
  };

  # Fuzzel Launcher Configuration - Enhanced with Rose Pine theme and QoL features.
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=14";
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

      # Custom greeting with fastfetch
      function fish_greeting
          if command -v fastfetch >/dev/null 2>&1
              fastfetch
          end
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

  # Starship Prompt: a cross-shell prompt.
  programs.starship.enable = true;

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
    ];
  };

  # **FILE CONFIGURATIONS**
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

  # Fastfetch config - temporarily disabled for build
  # home.file.".config/fastfetch" = {
  #   source = ./fastfetch_config;
  #   recursive = true;
  # };

  # Micro editor colorscheme - temporarily disabled for build
  # home.file.".config/micro/colorschemes/rose-pine.micro" = {
  #   source = ./micro_config/rose-pine.micro;
  # };

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

  # Screenshot scripts - temporarily disabled for build
  # home.file.".local/bin/screenshot-full" = {
  #   source = ./scripts/screenshot-full.sh;
  #   executable = true;
  # };

  # home.file.".local/bin/screenshot-region" = {
  #   source = ./scripts/screenshot-region.sh;
  #   executable = true;
  # };

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
    kdePackages.breeze-icons
    catppuccin-cursors
    # Screenshot utilities
    grim
    slurp
    wl-clipboard
    swappy
    satty
    libnotify
    zenity
    hyprpolkitagent
    hyprutils
    hyprshade
    hyprpanel
    vesktop
    zed-editor_git
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.gwenview
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
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    qt6ct
    qt6Packages.qtstyleplugin-kvantum
    rose-pine-kvantum
    themechanger
    nwg-look
    dconf-editor
    # Additional theming packages for manual configuration
    rose-pine-gtk-theme
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

  # Micro text editor configuration
  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "catppuccin-mocha";
      mkparents = true;
      softwrap = true;
      wordwrap = true;
      tabsize = 2;
      autoclose = true;
      autoindent = true;
      autosave = 5;
      clipboard = "external";
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
}
