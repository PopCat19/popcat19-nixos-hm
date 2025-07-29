# ~/nixos-config/home.nix
{
  pkgs,
  config,
  system,
  lib,
  inputs,
  ...
}:

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
    BROWSER = "zen-beta"; # Default web browser.
    TERMINAL = "kitty";
    FILE_MANAGER = "dolphin";
    # Ensure thumbnails work properly
    WEBKIT_DISABLE_COMPOSITING_MODE = "1";

    # Input Method (fcitx5) with Wayland support
    GTK_IM_MODULE = lib.mkForce "fcitx5";
    QT_IM_MODULE = lib.mkForce "fcitx5";
    XMODIFIERS = lib.mkForce "@im=fcitx5";
    # Firefox/Zen Browser specific for Wayland input method
    MOZ_ENABLE_WAYLAND = "1";
    GTK4_IM_MODULE = "fcitx5";
  };

  # Add local bin to PATH
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🎨 THEME CONFIGURATION
  # ═══════════════════════════════════════════════════════════════════════════════
  # All theme-related configurations are imported from home-theme.nix
  # This includes GTK, Qt, cursors, fonts, and all theming components

  imports = [
    ./home-theme.nix
    ./home-screenshot.nix
    ./home-mangohud.nix
    # ./home-hyprpanel.nix  # Temporarily disabled due to Home Manager module issues
    ./modules/gaming.nix
    ./modules/development.nix
    ./modules/android-tools.nix
    ./modules/shimboot-project.nix
    ./modules/desktop-theme.nix
    ./modules/dolphin.nix
    ./modules/qt-gtk-config.nix
    ./modules/fuzzel-config.nix
    ./modules/kitty.nix
    ./modules/fish.nix
    ./modules/starship.nix
    ./modules/micro.nix
    ./modules/fcitx5.nix
    ./modules/rose-pine-checker.nix
    ./modules/syncthing.nix
  ];

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

  # Git Configuration for user details.
  programs.git = {
    enable = true;
    userName = "PopCat19";
    userEmail = "atsuo11111@gmail.com";
  };

  # **CONFIGURATION FILE MANAGEMENT**
  # Manages symlinks for configuration files.
  home.file.".config/hypr" = {
    source = ./hypr_config;
    recursive = true;
  };

  # NPM global configuration for reproducible package management
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';



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
  # All user packages are imported from home-packages.nix for better organization
  home.packages = import ./home-packages.nix { inherit pkgs inputs system; };


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


}
