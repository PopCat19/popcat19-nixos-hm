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

  # GTK Theme Configuration - Minimal setup for cursor only.
  gtk = {
    enable = true;
    cursorTheme = {
      name = "rose-pine-hyprcursor";
      size = 24;
      package = inputs.rose-pine-hyprcursor.packages.${system}.default;
    };
    # Theme, icon theme, and font management disabled for manual control
    # Use nwg-look to configure GTK themes manually
  };

  # QT Theme Configuration - Minimal setup for platform theme only.
  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
    # Style management disabled for manual control via qt6ct/kvantum
  };

  # Make Kvantum themes available but don't force configuration
  # Use kvantum manager to configure themes manually
  home.file.".config/Kvantum/RosePine".source = "${pkgs.rose-pine-kvantum}/share/Kvantum/RosePine";

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
  # Fuzzel Launcher Configuration.
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Noto Sans:size=16";
        layer = "overlay"; # Display as an overlay.
        exit-on-click = true; # Close on click outside.
        prompt = " "; # Empty prompt.
      };
      colors = {
        background = "191724ee";
        text = "e0def4ff";
        match = "eb6f92ff";
        selection = "26233aff";
        selection-text = "e0def4ff";
        border = "ebbcbaee";
      };
      border = {
        radius = 8;
        width = 2;
      };
    };
  };

  # Fish Shell Configuration.
  programs.fish = {
    enable = true;
    shellInit = ''
      set -Ux NIXOS_CONFIG_DIR $HOME/nixos-config
      set -Ux NIXOS_FLAKE_HOSTNAME popcat19-nixos0
      set -g fish_greeting "" # Disable fish greeting.
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
    mangohud
    goverlay
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
}
