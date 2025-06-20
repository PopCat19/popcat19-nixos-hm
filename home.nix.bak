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
    QT_QPA_PLATFORMTHEME = "qt5ct"; # Qt5 platform theme.
    QT_STYLE_OVERRIDE = "kvantum"; # Qt style override.
    QT_QPA_PLATFORM = "wayland;xcb"; # Qt Wayland and XCB platform.
  };

  # **XDG MIME APPLICATIONS**
  # Configures default applications for specific MIME types.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = ["app.zen_browser.zen.desktop"];
      "x-scheme-handler/https" = ["app.zen_browser.zen.desktop"];
      "text/html" = ["app.zen_browser.zen.desktop"];
      "application/xhtml+xml" = ["app.zen_browser.zen.desktop"];
    };
  };

  # **THEMING CONFIGURATION**
  # Sets up GTK, Qt, and cursor themes.
  # GTK Theme Configuration.
  gtk = {
    enable = true;
    theme = {
      name = "rose-pine-gtk";
      package = pkgs.rose-pine-gtk-theme;
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
      package = pkgs.noto-fonts; # Using Noto fonts here, but consider a dedicated font package.
    };
  };

  # QT Theme Configuration.
  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    style.name = "kvantum";
  };

  # Kvantum Configuration file.
  home.file.".config/Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=RosePine
  '';

  # Dconf Settings for GTK theme consistency.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "rose-pine-gtk";
      icon-theme = "Papirus-Dark";
      cursor-theme = "rose-pine-hyprcursor";
    };
  };

  # **PROGRAM CONFIGURATIONS**
  # Configures specific user programs.
  # Fuzzel Launcher Configuration.
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "MPLUSRounded1c_Medium:size=16";
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
    # -------------------------
    # System & Desktop Utilities
    # -------------------------
    kitty                           # Fast, feature-rich, GPU-based terminal emulator.
    fuzzel                          # Application launcher.
    jq                              # Command-line JSON processor.
    hyprpolkitagent                 # Polkit agent for Hyprland.
    hyprutils                       # Utilities for Hyprland.
    hyprshade                       # Screen shader utility for Hyprland.
    hyprpanel                       # Panel for Hyprland.

    # -------------------------
    # Applications
    # -------------------------
    vesktop                         # Discord client with Vencord support.
    zed-editor_git                  # Modern code editor.
    kdePackages.dolphin             # KDE file manager.
    kdePackages.ark                 # Archive manager for KDE.
    kdePackages.gwenview            # Image viewer for KDE.
    nautilus                        # GNOME file manager.
    nemo                            # Cinnamon file manager.

    # -------------------------
    # Media & Entertainment
    # -------------------------
    mpv                             # Highly customizable video player.
    audacious                       # Lightweight audio player.
    audacious-plugins               # Plugins for Audacious.
    obs-studio                      # Screen recording and streaming software.

    # -------------------------
    # Gaming
    # -------------------------
    lutris                          # Open gaming platform.
    mangohud                        # Vulkan/OpenGL overlay for monitoring.
    goverlay                        # GUI for MangoHud.
    osu-lazer-bin                   # Rhythm game client.

    # -------------------------
    # System Tools & Monitoring
    # -------------------------
    pavucontrol                     # PulseAudio Volume Control.
    playerctl                       # Command-line tool for controlling media players.
    btop-rocm                       # Resource monitor optimized for ROCm.
    glances                         # Cross-platform system monitoring tool.
    tree                            # Displays directory tree.
    ddcui                           # GUI for DDC/CI display control.
    openrgb-with-all-plugins        # OpenRGB with all available plugins.

    # -------------------------
    # Development & Android Tools
    # -------------------------
    universal-android-debloater     # Tool for debloating Android devices.
    android-tools                   # ADB and Fastboot tools.
    sunxi-tools                     # Tools for Allwinner ARM devices.
    binwalk                         # Firmware analysis tool.
    pv                              # Pipe viewer: monitors data progress.
    git-lfs                         # Git Large File Storage.
    vboot_reference                 # Chrome OS verified boot tools.

    # -------------------------
    # File System & Archive Tools
    # -------------------------
    parted                          # Disk partitioning tool.
    squashfsTools                   # Utilities for SquashFS filesystems.
    nixos-install-tools             # Tools useful for NixOS installation.
    nixos-generators                # Tools to generate NixOS images.

    # -------------------------
    # Network & Communication
    # -------------------------
    scrcpy                          # Android screen mirroring.
    localsend                       # Local file sharing utility.
    zrok                            # Secure tunneling application.

    # -------------------------
    # Productivity & Utilities
    # -------------------------
    keepassxc                       # Cross-platform password manager.
    mangayomi                       # Manga reader.

    # -------------------------
    # AI/ML
    # -------------------------
    ollama-rocm                     # Local AI model runner with ROCm support.

    # -------------------------
    # Shell & Terminal Tools
    # -------------------------
    starship                        # Cross-shell prompt.
    eza                             # Modern `ls` replacement.

    # -------------------------
    # Theming & Appearance
    # -------------------------
    libsForQt5.qtstyleplugin-kvantum # Kvantum style plugin for Qt5.
    libsForQt5.qt5ct                 # Qt5 configuration tool.
    qt6ct                            # Qt6 configuration tool.
    rose-pine-kvantum                # Rose Pine theme for Kvantum.
    themechanger                     # Theme switching utility.
    nwg-look                         # GTK theme configuration tool.
    dconf-editor                     # GUI editor for dconf database.
    papirus-icon-theme               # Papirus icon theme.

    # -------------------------
    # Fonts
    # -------------------------
    noto-fonts                      # Google Noto fonts.
    noto-fonts-cjk-sans             # CJK fonts for Noto.
    noto-fonts-emoji                # Emoji fonts for Noto.
    font-awesome                    # Font Awesome icons.
    nerd-fonts.jetbrains-mono       # JetBrains Mono Nerd Font.

    # -------------------------
    # Custom Packages from Inputs
    # -------------------------
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default # Rose Pine cursor.
    inputs.zen-browser.packages."${system}".default             # Zen Browser.
  ];
}
