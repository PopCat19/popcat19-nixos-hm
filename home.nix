# ~/nixos-config/home.nix
{ pkgs, config, system, lib, inputs, ... }:

{
  # ============================================================================
  # BASIC HOME CONFIGURATION
  # ============================================================================
  
  home.username = "popcat19";
  home.homeDirectory = "/home/popcat19";
  home.stateVersion = "24.05";

  # ============================================================================
  # ENVIRONMENT VARIABLES
  # ============================================================================
  
  home.sessionVariables = {
    EDITOR = "micro";
    VISUAL = "$EDITOR";
    BROWSER = "flatpak run app.zen_browser.zen";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORM = "wayland;xcb";
  };

  # ============================================================================
  # XDG MIME APPLICATIONS
  # ============================================================================
  
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = ["app.zen_browser.zen.desktop"];
      "x-scheme-handler/https" = ["app.zen_browser.zen.desktop"];
      "text/html" = ["app.zen_browser.zen.desktop"];
      "application/xhtml+xml" = ["app.zen_browser.zen.desktop"];
    };
  };

  # ============================================================================
  # THEMING CONFIGURATION
  # ============================================================================
  
  # GTK Theme Configuration
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
      package = pkgs.noto-fonts;
    };
  };

  # QT Theme Configuration
  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    style.name = "kvantum";
  };

  # Kvantum Configuration
  home.file.".config/Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=RosePine
  '';

  # Dconf Settings for GTK
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "rose-pine-gtk";
      icon-theme = "Papirus-Dark";
      cursor-theme = "rose-pine-hyprcursor";
    };
  };

  # ============================================================================
  # PROGRAM CONFIGURATIONS
  # ============================================================================
  
  # Fuzzel Launcher Configuration
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "MPLUSRounded1c_Medium:size=16";
        layer = "overlay";
        exit-on-click = true;
        prompt = " ";
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

  # Fish Shell Configuration
  programs.fish = {
    enable = true;
    shellInit = ''
      set -Ux NIXOS_CONFIG_DIR $HOME/nixos-config
      set -Ux NIXOS_FLAKE_HOSTNAME popcat19-nixos0
      set -g fish_greeting ""
      fish_add_path $HOME/bin
      if status is-interactive
          starship init fish | source
      end
    '';
    shellAbbrs = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";
      
      # File Operations
      mkdir = "mkdir -p";
      l = "eza -lh --icons=auto";
      ls = "eza -1 --icons=auto";
      ll = "eza -lha --icons=auto --sort=name --group-directories-first";
      ld = "eza -lhD --icons=auto";
      lt = "eza --tree --icons=auto";
      o = "open_smart";
      
      # NixOS Configuration Management
      nconf = "nixconf-edit";
      nixos-ed = "nixconf-edit";
      hconf = "homeconf-edit";
      home-ed = "homeconf-edit";
      flconf = "flake-edit";
      flake-ed = "flake-edit";
      flup = "flake-update";
      flake-up = "flake-update";
      ngit = "nixos-git";
      
      # NixOS Build and Switch
      nrb = "nixos-apply-config";
      nixos-sw = "nixos-apply-config";
      nerb = "nixos-edit-rebuild";
      nixoss = "nixos-edit-rebuild";
      herb = "home-edit-rebuild";
      home-sw = "home-edit-rebuild";
      nup = "nixos-upgrade";
      nixos-up = "nixos-upgrade";
      
      # Package Management
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

  # Starship Prompt
  programs.starship.enable = true;

  # Git Configuration
  programs.git = {
    enable = true;
    userName = "PopCat19";
    userEmail = "atsuo11111@gmail.com";
  };

  # ============================================================================
  # INPUT METHOD CONFIGURATION
  # ============================================================================
  
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      libsForQt5.fcitx5-qt
      fcitx5-mozc
    ];
  };

  # ============================================================================
  # FILE CONFIGURATIONS
  # ============================================================================
  
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

  # ============================================================================
  # SYSTEM SERVICES
  # ============================================================================
  
  services = {
    # Media Control
    playerctld.enable = true;
    mpris-proxy.enable = true;
    
    # Storage Management
    udiskie.enable = true;
    
    # Audio Effects
    easyeffects.enable = true;
    
    # Clipboard Management
    cliphist.enable = true;
    
    # AI/ML Services
    ollama = {
      enable = true;
      acceleration = "rocm";
    };
  };

  # ============================================================================
  # INSTALLED PACKAGES
  # ============================================================================
  
  home.packages = with pkgs; [
    # -------------------------
    # System & Desktop Utilities
    # -------------------------
    kitty                           # Terminal emulator
    fuzzel                          # Application launcher
    jq                             # JSON processor
    hyprpolkitagent                # Polkit agent for Hyprland
    hyprutils                      # Hyprland utilities
    hyprshade                      # Screen shader for Hyprland
    hyprpanel                      # Panel for Hyprland
    
    # -------------------------
    # Applications
    # -------------------------
    vesktop                        # Discord client
    zed-editor_git                 # Code editor
    kdePackages.dolphin            # File manager
    kdePackages.ark                # Archive manager
    kdePackages.gwenview           # Image viewer
    nautilus                       # GNOME file manager
    nemo                           # Cinnamon file manager
    
    # -------------------------
    # Media & Entertainment
    # -------------------------
    mpv                           # Video player
    audacious                     # Audio player
    audacious-plugins             # Audacious plugins
    obs-studio                    # Screen recording/streaming
    
    # -------------------------
    # Gaming
    # -------------------------
    lutris                        # Game launcher
    mangohud                      # Gaming overlay
    goverlay                      # MangoHud GUI
    osu-lazer-bin                 # Rhythm game
    
    # -------------------------
    # System Tools & Monitoring
    # -------------------------
    pavucontrol                   # Audio control
    playerctl                     # Media player control
    btop-rocm                     # System monitor (ROCm optimized)
    glances                       # System monitor
    tree                          # Directory tree display
    ddcui                         # Display control
    openrgb-with-all-plugins      # RGB lighting control
    
    # -------------------------
    # Development & Android Tools
    # -------------------------
    universal-android-debloater   # Android debloating tool
    android-tools                 # ADB and Fastboot
    sunxi-tools                   # ARM device tools
    binwalk                       # Firmware analysis
    pv                           # Progress viewer
    git-lfs                      # Git Large File Storage
    vboot_reference              # Chrome OS boot tools
    
    # -------------------------
    # File System & Archive Tools
    # -------------------------
    parted                        # Disk partitioning
    squashfsTools                 # SquashFS utilities
    nixos-install-tools           # NixOS installation tools
    nixos-generators              # NixOS image generators
    
    # -------------------------
    # Network & Communication
    # -------------------------
    scrcpy                        # Android screen mirroring
    localsend                     # Local file sharing
    zrok                          # Secure tunneling
    
    # -------------------------
    # Productivity & Utilities
    # -------------------------
    keepassxc                     # Password manager
    mangayomi                     # Manga reader
    
    # -------------------------
    # AI/ML
    # -------------------------
    ollama-rocm                   # Local AI (ROCm optimized)
    
    # -------------------------
    # Shell & Terminal Tools
    # -------------------------
    starship                      # Shell prompt
    eza                          # Modern ls replacement
    
    # -------------------------
    # Theming & Appearance
    # -------------------------
    libsForQt5.qtstyleplugin-kvantum  # Kvantum Qt5 plugin
    libsForQt5.qt5ct                  # Qt5 configuration tool
    qt6ct                             # Qt6 configuration tool
    rose-pine-kvantum                 # Rose Pine Kvantum theme
    themechanger                      # Theme switching utility
    nwg-look                          # GTK theme configuration
    dconf-editor                      # dconf editor
    papirus-icon-theme                # Papirus icons
    
    # -------------------------
    # Fonts
    # -------------------------
    noto-fonts                    # Google Noto fonts
    noto-fonts-cjk-sans          # CJK fonts
    noto-fonts-emoji              # Emoji fonts
    font-awesome                  # Font Awesome icons
    nerd-fonts.jetbrains-mono     # JetBrains Mono Nerd Font
    
    # -------------------------
    # Custom Packages from Inputs
    # -------------------------
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default  # Rose Pine cursor
    inputs.zen-browser.packages."${system}".default              # Zen Browser
  ];
}
