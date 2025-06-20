# ~/nixos-config/home.nix
{ pkgs, config, system, lib, inputs, ... }:

{
  home.username = "popcat19";
  home.homeDirectory = "/home/popcat19";
  home.stateVersion = "24.05";

  home.sessionVariables = {
    EDITOR = "micro";
    VISUAL = "$EDITOR"; # or "micro" directly
    BROWSER = "flatpak run app.zen_browser.zen";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE    = "kvantum";
  };

  # Declaratively set Zen Browser as the default
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/http" = ["app.zen_browser.zen.desktop"];
    "x-scheme-handler/https" = ["app.zen_browser.zen.desktop"];
    "text/html" = ["app.zen_browser.zen.desktop"];
    "application/xhtml+xml" = ["app.zen_browser.zen.desktop"];
  };

  # GTK Theme, Icons, and Fonts Configuration
  # This uses Catppuccin theme (Mocha variant) as it's directly available.
  # Papirus-Dark is chosen for icons, and your preferred font is set.
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Mauve-Dark";
      package = pkgs.catppuccin-gtk.override {
        variant = "mocha";
        accents = ["mauve"];
        size = "standard";
        # tweaks = [ "rimless" "black" ]; # optional
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "rose-pine-hyprcursor";
      size = 24;
      package = inputs.rose-pine-hyprcursor.packages.${system}.default;
    };
    font = {
      name = "MPLUSRounded1c_Medium 10";
      package = pkgs.noto-fonts;
    };
  };

  # QT Theme Configuration
  # This sets Kvantum as the QT style and applies the Rose Pine theme to it.
  qt = {
    enable = true;
    platformTheme.name = "qt5ct"; # Use qt6ct for QT6 apps
    # Fallback for QT5 apps if qt5ct is not explicitly set as platformTheme
    # qt5.platformTheme = "qt5ct";
    style = {
      name = "kvantum"; # Kvantum is the rendering engine
    };
    # Set the Kvantum theme to Rose Pine (this requires the theme to be installed via Kvantum Manager)
    # The actual Kvantum theme is often set in ~/.config/Kvantum/kvantum.kvconfig,
    # but ensuring rose-pine-kvantum is installed and qt.style is set to Kvantum helps.
    # Users will then select 'Rose-Pine' within Kvantum Manager.
    # We ensure kvantum packages are present below.
  };

  home.file.".config/Kvantum/kvantum.kvconfig".text = ''
    [Desktop Entry]
    Name=kvantum
    Comment=Use Rose-Pine for Kvantum

    [General]
    theme=rose-pine
  '';

  # Fuzzel Configuration
  # This block sets the theme for Fuzzel using colors from Rose Pine.
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "MPLUSRounded1c_Medium:size=10";
        layer = "overlay"; # Or "top"
        exit-on-click = true;
        prompt = " "; # No prompt text for clean look
      };

      colors = {
        background = "191724ee"; # $base (with alpha for transparency)
        text = "e0def4ff";       # $text
        match = "eb6f92ff";      # $love
        selection = "26233aff";  # $overlay
        selection-text = "e0def4ff"; # $text
        border = "ebbcbaee";     # $rose (with alpha)
      };

      border = {
        radius = 8; # Matches Hyprland's rounding (or close to it)
        width = 2;
      };

      # Optional: Input section if you want to customize input behavior
      # input = {
      #   insensitive = true;
      #   grab-keyboard = true;
      # };

      # Optional: Location for fuzzel
      # placement = {
      #   y = 0.05; # 5% from top
      #   x = 0.5; # Centered
      #   anchor = "center";
      # };

      # Optional: Size for fuzzel
      # size = {
      #   width = 0.4; # 40% of screen width
      #   height = 0.4; # 40% of screen height
      # };
    };
  };

  home.packages = with pkgs; [
    # Terminals, Launchers, Notifications
    kitty
    fuzzel
    jq
    hyprpolkitagent
    hyprutils
    hyprshade
    hyprpanel
    # Desktop Utilities
    vesktop
    zed-editor_git
    kdePackages.dolphin
    pavucontrol
    starship # programs.starship.enable is also below
    eza
    # QT/GTK Theming tools and dependencies
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    qt6ct # Make sure qt6ct is explicitly listed
    pkgs.rose-pine-kvantum # The Kvantum theme itself
    pkgs.libsForQt5.qtstyleplugin-kvantum # The Kvantum engine
    pkgs.themechanger # Unsure if this is directly used but kept for consistency
    nwg-look # GTK theme configuration tool
    pkgs.papirus-icon-theme # Icon theme
    # Other existing packages...
    kdePackages.ark
    ddcui
    papirus-icon-theme
    kdePackages.gwenview
    mpv
    ollama-rocm
    audacious
    audacious-plugins
    lutris
    mangohud
    goverlay
    scrcpy
    openrgb-with-all-plugins
    btop-rocm
    tree
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default # Rose Pine cursor
    zrok
    osu-lazer-bin
    playerctl
    universal-android-debloater
    android-tools
    sunxi-tools
    binwalk
    pv
    localsend
    nautilus
    nemo
    nixos-install-tools
    nixos-generators
    git-lfs
    vboot_reference
    mangayomi
    parted
    squashfsTools
    glances
    obs-studio
    keepassxc
    inputs.zen-browser.packages."${system}".default
    # Fonts should also be in `home.packages` for user accessibility
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  services.playerctld.enable = true;
  services.mpris-proxy.enable = true;

  services.udiskie.enable = true;
  services.easyeffects.enable = true;

  services.cliphist = {
    enable = true;
  };

  services.ollama = {
    enable = true;
    acceleration = "rocm";
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      libsForQt5.fcitx5-qt
      fcitx5-mozc
    ];
  };

  home.file.".config/hypr" = {
    source = ./hypr_config; # Path relative to home.nix
    recursive = true;
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      set -Ux NIXOS_CONFIG_DIR $HOME/nixos-config
      set -Ux NIXOS_FLAKE_HOSTNAME popcat19-nixos0 # Confirm this is still correct
      set -g fish_greeting "" # Clears the default greeting
      # Prepend $HOME/bin to the PATH if it exists and isn't already there
      fish_add_path $HOME/bin
      # Starship init
      if status is-interactive
          starship init fish | source
      end
    '';
    shellAbbrs = {
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";
      mkdir = "mkdir -p";
      nconf = "nixconf-edit";
      nixos-ed = "nixconf-edit";
      hconf = "homeconf-edit";
      home-ed = "homeconf-edit";
      flconf = "flake-edit";
      flake-ed = "flake-edit";
      flup = "flake-update";
      flake-up = "flake-update";
      ngit = "nixos-git";

      nrb = "nixos-apply-config";
      nixos-sw = "nixos-apply-config";
      nerb = "nixos-edit-rebuild";
      nixoss = "nixos-edit-rebuild";
      herb = "home-edit-rebuild";
      home-sw = "home-edit-rebuild";
      nup = "nixos-upgrade";
      nixos-up = "nixos-upgrade";

      pkgls = "nixpkg list";
      pkgadd = "nixpkg add";
      pkgrm = "nixpkg remove";
      pkgs = "nixpkg search";
      pkghelp = "nixpkg help";
      pkgman = "nixpkg manual";
      pkgaddr = "nixpkg add --rebuild";
      pkgrmr = "nixpkg remove --rebuild";

      l = "eza -lh --icons=auto";
      ls = "eza -1 --icons=auto";
      ll = "eza -lha --icons=auto --sort=name --group-directories-first";
      ld = "eza -lhD --icons=auto";
      lt = "eza --tree --icons=auto";
      o = "open_smart";
    };
  };

  home.file.".config/fish/functions" = {
    source = ./fish_functions;
    recursive = true;
  };

  home.file.".config/fish/themes" = {
    source = ./fish_themes;
    recursive = true;
  };

  programs.starship = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "PopCat19";
    userEmail = "atsuo11111@gmail.com";
  };
}
