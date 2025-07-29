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

  # Script to install global npm packages manually
  home.file.".local/bin/install-npm-globals".text = ''
    #!/usr/bin/env bash

    # Install Google Gemini CLI if not already installed
    if ! command -v gemini &> /dev/null; then
        echo "Installing Google Gemini CLI..."
        npm install -g @google/gemini-cli
    else
        echo "Google Gemini CLI already installed (version: $(gemini --version))"
    fi

    # Add other global npm packages here as needed
    # npm install -g some-other-package
  '';

  home.file.".local/bin/install-npm-globals".executable = true;

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
  # All user packages are imported from home-packages.nix for better organization
  home.packages = import ./home-packages.nix { inherit pkgs inputs system; };

  # Create directories for syncthing
  home.activation.createSyncthingDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/syncthing-shared
    mkdir -p $HOME/.local/share/syncthing
    mkdir -p $HOME/Passwords
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

}
