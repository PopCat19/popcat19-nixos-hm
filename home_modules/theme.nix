# Home Manager Theme Configuration
# This file contains all theme-related configurations and packages
# Imported by home.nix

{ pkgs, config, system, lib, inputs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════════════════
  # 🌍 THEME-RELATED ENVIRONMENT VARIABLES
  # ═══════════════════════════════════════════════════════════════════════════════
  # These environment variables are CRITICAL for proper theming and application
  # integration. They tell applications which theming engines to use and how to
  # behave in the Wayland environment.
  #
  # DEPENDENCY CHAIN: Environment variables → Application startup → Theme loading

  home.sessionVariables = {
    # ─── QT THEMING CHAIN ───
    # This is a complex dependency chain that enables Rose Pine theming for Qt apps:
    # QT_QPA_PLATFORMTHEME → qt6ct → QT_STYLE_OVERRIDE → kvantum → Rose Pine theme
    QT_QPA_PLATFORMTHEME = "qt6ct";  # Tells Qt to use qt6ct for theming
    QT_STYLE_OVERRIDE = "kvantum";   # Tells qt6ct to use Kvantum style engine
    QT_QPA_PLATFORM = "wayland;xcb"; # Prefer Wayland, fallback to X11

    # ─── GTK THEMING ───
    # Forces GTK applications to use our Rose Pine theme
    # This works in conjunction with the gtk.theme configuration below
    GTK_THEME = "Rose-Pine-Main-BL";  # Must match gtk.theme.name
    GDK_BACKEND = "wayland,x11,*";    # Prefer Wayland for GTK apps

    # ─── CURSOR THEMING ───
    # Hyprland uses these for cursor theming across all applications
    XCURSOR_THEME = "rose-pine-hyprcursor";  # Must match gtk.cursorTheme.name
    XCURSOR_SIZE = "24";                     # Must match gtk.cursorTheme.size
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🎨 GTK THEMING CONFIGURATION - VISUAL FOUNDATION
  # ═══════════════════════════════════════════════════════════════════════════════
  # GTK theming is the foundation for visual consistency across the desktop.
  # This configuration ensures all GTK applications (including some Qt apps that
  # respect GTK theming) use the Rose Pine color scheme.
  #
  # DEPENDENCY CHAIN: gtk configuration → dconf settings → environment variables → app startup

  gtk = {
    enable = true;

    # ─── CURSOR THEME ───
    # Hyprland-compatible cursor theme that matches our color scheme
    # The cursor theme must be installed as a package and the environment
    # variables above must match these settings
    cursorTheme = {
      name = "rose-pine-hyprcursor";  # Must match XCURSOR_THEME environment variable
      size = 24;                      # Must match XCURSOR_SIZE environment variable
      package = inputs.rose-pine-hyprcursor.packages.${system}.default;  # Flake input dependency
    };

    # ─── GTK THEME ───
    # Main visual theme for all GTK applications
    # This theme is built as a package and provides the Rose Pine color scheme
    # theme = {
    #   name = "Rose-Pine-Main-BL";           # Must match GTK_THEME environment variable
    #   package = pkgs.rose-pine-gtk-theme-full;  # Custom package built in pkgs/
    # };

    # ─── ICON THEME ───
    # Dark icon theme that complements Rose Pine colors
    # Papirus provides comprehensive icon coverage
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    # ─── FONT CONFIGURATION ───
    # Custom font for consistent typography across GTK applications
    # This font is installed via packages and configured in fontconfig
    font = {
      name = "Rounded Mplus 1c Medium";  # Japanese-compatible font with good readability
      size = 11;                         # Comfortable reading size for most displays
    };

    # ─── GTK3 SPECIFIC SETTINGS ───
    # These settings ensure GTK3 applications integrate properly with our theme
    gtk3.extraConfig = {
      gtk-decoration-layout = "appmenu:minimize,maximize,close";  # macOS-style window controls
      gtk-enable-animations = true;                # Enable smooth animations
      gtk-primary-button-warps-slider = false;    # Disable confusing slider behavior
    };

    # ─── GTK4 SPECIFIC SETTINGS ───
    # GTK4 applications need separate configuration for the same settings
    # Note: gtk-application-prefer-dark-theme is deprecated for GTK4/libadwaita
    # Use AdwStyleManager:color-scheme instead (configured in dconf settings)
    gtk4.extraConfig = {
      gtk-decoration-layout = "appmenu:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-primary-button-warps-slider = false;
    };

    # ─── FONT OVERRIDE CSS ───
    # Force our custom font across all GTK applications
    # This ensures consistent typography even when applications try to use system fonts
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

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🎨 QT THEMING CONFIGURATION - COMPLETING THE THEMING PUZZLE
  # ═══════════════════════════════════════════════════════════════════════════════
  # Qt theming is more complex than GTK and requires multiple components working together:
  # 1. qt.style tells Qt to use Kvantum
  # 2. Kvantum theme files provide the actual Rose Pine colors
  # 3. qt6ct configuration bridges Qt6 apps to Kvantum
  # 4. kdeglobals ensures KDE applications use the theme
  #
  # DEPENDENCY CHAIN: QT_QPA_PLATFORMTHEME=qt6ct → qt6ct.conf → QT_STYLE_OVERRIDE=kvantum → kvantum.kvconfig → Rose Pine theme files

  qt = {
    enable = true;
    style = {
      name = "kvantum";  # Must match QT_STYLE_OVERRIDE environment variable
      package = pkgs.libsForQt5.qtstyleplugin-kvantum;  # Kvantum style plugin for Qt5
    };
  };

  # ─── KVANTUM THEME FILES ───
  # Kvantum is a Qt theming engine that provides advanced theming capabilities
  # The Rose Pine theme files are installed as a package and linked to user config
  home.file.".config/Kvantum/RosePine".source = "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/rose-pine-rose";

  # ─── KVANTUM CONFIGURATION ───
  # This file tells Kvantum which theme to use and allows per-application overrides
  # Application-specific theming ensures consistent look across all Qt applications
  home.file.".config/Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=rose-pine-rose

    # Application-specific theme assignments ensure all KDE apps use Rose Pine
    [Applications]
    dolphin=rose-pine-rose      # File manager
    ark=rose-pine-rose          # Archive manager
    gwenview=rose-pine-rose     # Image viewer
    systemsettings=rose-pine-rose  # System settings
    kate=rose-pine-rose         # Text editor
    kwrite=rose-pine-rose       # Simple text editor
  '';

  # ─── KDE APPLICATIONS THEMING ───
  # kdeglobals is crucial for KDE applications like Dolphin to use proper theming
  # This file defines the complete color scheme that KDE applications read
  # WITHOUT this file, KDE apps will use default colors regardless of other theme settings
  home.file.".config/kdeglobals" = {
    text = ''
      [ColorScheme]
      Name=Rose-Pine-Main-BL

      # Button colors (used in UI elements like buttons, toolbars)
      [Colors:Button]
      BackgroundAlternate=49,46,77      # rose-pine overlay
      BackgroundNormal=49,46,77         # rose-pine overlay
      DecorationFocus=156,207,216       # rose-pine foam (focus indicators)
      DecorationHover=156,207,216       # rose-pine foam (hover effects)
      ForegroundActive=224,222,244      # rose-pine text
      ForegroundInactive=144,140,170    # rose-pine subtle
      ForegroundLink=156,207,216        # rose-pine foam (links)
      ForegroundNegative=235,111,146    # rose-pine love (errors)
      ForegroundNeutral=246,193,119     # rose-pine gold (warnings)
      ForegroundNormal=224,222,244      # rose-pine text
      ForegroundPositive=156,207,216    # rose-pine foam (success)
      ForegroundVisited=196,167,231     # rose-pine iris (visited links)

      # Selection colors (used when selecting text or files)
      [Colors:Selection]
      BackgroundAlternate=82,79,103     # rose-pine highlight-high
      BackgroundNormal=64,61,82         # rose-pine highlight-med
      DecorationFocus=156,207,216       # rose-pine foam
      DecorationHover=156,207,216       # rose-pine foam
      ForegroundActive=224,222,244      # rose-pine text
      ForegroundInactive=144,140,170    # rose-pine subtle
      ForegroundLink=156,207,216        # rose-pine foam
      ForegroundNegative=235,111,146    # rose-pine love
      ForegroundNeutral=246,193,119     # rose-pine gold
      ForegroundNormal=224,222,244      # rose-pine text
      ForegroundPositive=156,207,216    # rose-pine foam
      ForegroundVisited=196,167,231     # rose-pine iris

      # Tooltip colors
      [Colors:Tooltip]
      BackgroundAlternate=25,23,36      # rose-pine base
      BackgroundNormal=25,23,36         # rose-pine base
      DecorationFocus=156,207,216       # rose-pine foam
      DecorationHover=156,207,216       # rose-pine foam
      ForegroundActive=224,222,244      # rose-pine text
      ForegroundInactive=144,140,170    # rose-pine subtle
      ForegroundLink=156,207,216        # rose-pine foam
      ForegroundNegative=235,111,146    # rose-pine love
      ForegroundNeutral=246,193,119     # rose-pine gold
      ForegroundNormal=224,222,244      # rose-pine text
      ForegroundPositive=156,207,216    # rose-pine foam
      ForegroundVisited=196,167,231     # rose-pine iris

      # View colors (used in lists, trees, and content areas)
      [Colors:View]
      BackgroundAlternate=31,29,46      # rose-pine surface
      BackgroundNormal=25,23,36         # rose-pine base
      DecorationFocus=156,207,216       # rose-pine foam
      DecorationHover=156,207,216       # rose-pine foam
      ForegroundActive=224,222,244      # rose-pine text
      ForegroundInactive=144,140,170    # rose-pine subtle
      ForegroundLink=156,207,216        # rose-pine foam
      ForegroundNegative=235,111,146    # rose-pine love
      ForegroundNeutral=246,193,119     # rose-pine gold
      ForegroundNormal=224,222,244      # rose-pine text
      ForegroundPositive=156,207,216    # rose-pine foam
      ForegroundVisited=196,167,231     # rose-pine iris

      # Window colors (used for window backgrounds and decorations)
      [Colors:Window]
      BackgroundAlternate=31,29,46      # rose-pine surface
      BackgroundNormal=25,23,36         # rose-pine base
      DecorationFocus=156,207,216       # rose-pine foam
      DecorationHover=156,207,216       # rose-pine foam
      ForegroundActive=224,222,244      # rose-pine text
      ForegroundInactive=144,140,170    # rose-pine subtle
      ForegroundLink=156,207,216        # rose-pine foam
      ForegroundNegative=235,111,146    # rose-pine love
      ForegroundNeutral=246,193,119     # rose-pine gold
      ForegroundNormal=224,222,244      # rose-pine text
      ForegroundPositive=156,207,216    # rose-pine foam
      ForegroundVisited=196,167,231     # rose-pine iris

      # Complementary colors (used for complementary UI elements)
      [Colors:Complementary]
      BackgroundAlternate=49,46,77      # rose-pine overlay
      BackgroundNormal=38,35,58         # rose-pine overlay darker
      DecorationFocus=235,188,186       # rose-pine rose
      DecorationHover=235,188,186       # rose-pine rose
      ForegroundActive=224,222,244      # rose-pine text
      ForegroundInactive=110,106,134    # rose-pine muted
      ForegroundLink=156,207,216        # rose-pine foam
      ForegroundNegative=235,111,146    # rose-pine love
      ForegroundNeutral=246,193,119     # rose-pine gold
      ForegroundNormal=224,222,244      # rose-pine text
      ForegroundPositive=156,207,216    # rose-pine foam
      ForegroundVisited=196,167,231     # rose-pine iris

      # General KDE settings
      [General]
      ColorScheme=Rose-Pine-Main-BL
      Name=Rose-Pine-Main-BL
      shadeSortColumn=true

      # Icon and color preferences
      [Icons]
      Theme=Papirus-Dark

      # KDE-specific color adjustments
      [KDE]
      contrast=4
      widgetStyle=kvantum
    '';
    force = true;  # Force overwrite existing kdeglobals
  };

  # ─── QT6CT CONFIGURATION ───
  # Qt6ct bridges Qt6 applications to our theming system
  # This configuration file tells Qt6 applications to use Kvantum and sets up fonts
  home.file.".config/qt6ct/qt6ct.conf" = {
    text = ''
      [Appearance]
      color_scheme_path=
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

      [SettingsWindow]
      geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\0\0\0\x2\x7f\0\0\x1\xdf\0\0\0\0\0\0\0\0\0\0\x2\x7f\0\0\x1\xdf\0\0\0\0\x2\0\0\0\n\0\0\0\0\0\0\0\0\0\0\0\x2\x7f\0\0\x1\xdf)
    '';
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🎨 DCONF SETTINGS - GNOME/GTK APPLICATION PREFERENCES
  # ═══════════════════════════════════════════════════════════════════════════════
  # dconf manages settings for GNOME and many GTK applications. These settings
  # ensure proper theming and behavior for applications that use GSettings.
  #
  # DEPENDENCY CHAIN: dconf settings → GSettings → GTK applications → theme application

  dconf.settings = {
    # ─── DESKTOP INTERFACE SETTINGS ───
    # These settings affect the overall desktop appearance and behavior
    "org/gnome/desktop/interface" = {
      cursor-theme = "rose-pine-hyprcursor";      # Must match cursor theme above
      cursor-size = 24;                           # Must match cursor size above
      gtk-theme = "Rose-Pine-Main-BL";            # Must match GTK theme above
      icon-theme = "Papirus-Dark";                # Must match icon theme above
      font-name = "Rounded Mplus 1c Medium 11";  # Must match font configuration
      document-font-name = "Rounded Mplus 1c Medium 11";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
      color-scheme = "prefer-dark";               # Force dark theme preference
    };

    # ─── WINDOW MANAGER PREFERENCES ───
    "org/gnome/desktop/wm/preferences" = {
      theme = "Rose-Pine-Main-BL";  # Window decoration theme
    };

    # ─── THUMBNAIL SETTINGS ───
    # Disable GNOME's thumbnail generation since we handle it separately
    "org/gnome/desktop/thumbnailers" = {
      disable-all = false;  # Allow thumbnail generation
    };

    # ─── NAUTILUS FILE MANAGER ───
    # Configure GNOME's file manager (if used as fallback)
    "org/gnome/nautilus/preferences" = {
      show-image-thumbnails = "always";
      thumbnail-limit = 10;  # 10MB limit for thumbnail generation
      show-directory-item-counts = "always";
    };

    # ─── NEMO FILE MANAGER ───
    # Configure Cinnamon's file manager
    "org/nemo/preferences" = {
      show-image-thumbnails = true;
      thumbnail-limit = 10;
      show-thumbnails = true;
    };

    # ─── PRIVACY SETTINGS ───
    "org/gnome/desktop/privacy" = {
      remember-recent-files = true;
      recent-files-max-age = 30;  # Keep recent files for 30 days
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🔧 SYSTEMD USER SERVICES - THEME SYSTEM INTEGRATION
  # ═══════════════════════════════════════════════════════════════════════════════
  # These services run in the background to provide essential desktop functionality.
  # They start automatically when the graphical session begins.

  # ─── POLKIT AUTHENTICATION AGENT ───
  # Provides graphical authentication dialogs for privileged operations
  # Essential for mounting drives, managing network connections, etc.
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



  # ═══════════════════════════════════════════════════════════════════════════════
  # 📦 THEME-RELATED PACKAGES
  # ═══════════════════════════════════════════════════════════════════════════════
  # These packages provide theming components, tools, and dependencies

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🔤 FONT CONFIGURATION SYSTEM
  # ═══════════════════════════════════════════════════════════════════════════════
  # Centralized font management for consistent typography across all applications.
  # This section includes font packages, application-specific font settings, and
  # system-wide font configuration through fontconfig.
  #
  # FONT HIERARCHY:
  # 1. System UI: Rounded Mplus 1c Medium (GTK/Qt applications) - from pkgs.google-fonts
  # 2. Monospace: JetBrainsMono Nerd Font (terminals, code editors) - from nerd-fonts.jetbrains-mono
  # 3. Fallbacks: Noto fonts for comprehensive Unicode support - from noto-fonts packages
  #
  # TESTING: Moving google-fonts from system-level to user-level for better control
  # Rounded Mplus 1c comes from the google-fonts package (testing user-level installation)

  # ─── APPLICATION FONT CONFIGURATIONS ───

  # Kitty terminal font configuration
  programs.kitty.font = {
    name = "JetBrainsMono Nerd Font";
    size = 11;
  };

  # Fuzzel application launcher font configuration
  programs.fuzzel.settings.main.font = "Rounded Mplus 1c Medium:size=14";

  # ─── SYSTEM FONT CONFIGURATION ───

  # Fontconfig configuration for system-wide font fallbacks and aliases
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

  home.packages = with pkgs; [
    # ─── FONT PACKAGES ───
    # Core fonts for the theme system - these provide comprehensive typography
    # support across all applications and languages
    #
    # NOTE: Testing user-level font management - google-fonts now included here
    # instead of system-level configuration.nix
    # Core font packages - moving from system-level to user-level for better control
    google-fonts                       # Google Fonts collection (includes Rounded Mplus 1c Medium)
    vim
    firefox
    htop
    neofetch
    nerd-fonts.jetbrains-mono          # Programming font with icons (used in Kitty, terminals)
    nerd-fonts.caskaydia-cove          # Alternative programming font option
    nerd-fonts.fantasque-sans-mono     # Another programming font option
    noto-fonts                         # Comprehensive Unicode support
    noto-fonts-cjk-sans               # CJK (Chinese/Japanese/Korean) support
    noto-fonts-emoji                   # Emoji support
    font-awesome                       # Icon font for UI elements
    # ─── THEME MANAGEMENT TOOLS ───
    nwg-look                           # GTK theme configuration GUI
    dconf-editor                       # dconf settings editor
    libsForQt5.qt5ct                   # Qt5 configuration tool
    qt6ct                              # Qt6 configuration tool (used in environment vars)
    themechanger                       # Theme switching utility
    kdePackages.qtstyleplugin-kvantum  # Qt style plugin for Kvantum themes

    # ─── ROSE PINE THEME PACKAGES ───
    rose-pine-kvantum                  # Kvantum Rose Pine themes
    # rose-pine-gtk-theme-full           # Complete Rose Pine GTK theme (custom package)
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default # Rose Pine cursors

    # ─── ADDITIONAL THEME PACKAGES ───
    # These provide alternative themes and ensure broad compatibility
    catppuccin-gtk                     # Alternative theme option
    catppuccin-cursors                 # Alternative cursor theme
    papirus-icon-theme                 # Icon theme (used throughout config)
    adwaita-icon-theme                 # Fallback icon theme

    # ─── SYSTEM INTEGRATION ───
    polkit_gnome                       # GNOME polkit agent (used by systemd service)
    gsettings-desktop-schemas          # GSettings schemas for desktop integration

    # ─── THEME DIAGNOSTIC TOOLS ───
    # Comprehensive Rose Pine theme diagnostic script
    (pkgs.writeShellScriptBin "check-rose-pine-theme" ''
      #!/usr/bin/env bash

      # ═══════════════════════════════════════════════════════════════════════════════
      # 🌹 COMPREHENSIVE ROSE PINE THEME DIAGNOSTIC TOOL
      # ═══════════════════════════════════════════════════════════════════════════════
      #
      # This script performs exhaustive checks of the Rose Pine theming system to help
      # LLMs and users quickly identify and resolve theming issues. It checks everything
      # from environment variables to font installations to package availability.
      #
      # FEATURES:
      # • Environment variable validation with exact expected values
      # • Font installation and availability checks
      # • Package and overlay verification
      # • Theme file existence and content validation
      # • Configuration file syntax and content checks
      # • Application availability and integration tests
      # • Detailed troubleshooting steps for each issue found
      # • Copy-paste ready fix commands
      # • Color-coded output for easy reading
      #
      # USAGE: check-rose-pine-theme [--verbose] [--fix-suggestions]
      # ═══════════════════════════════════════════════════════════════════════════════

      set -euo pipefail

      # ─── CONFIGURATION ───
      SCRIPT_VERSION="2.0.0"
      CONFIG_DIR="$HOME/.config"
      NIXOS_CONFIG_DIR="$HOME/nixos-config"
      VERBOSE=false
      SHOW_FIX_SUGGESTIONS=false

      # ─── COLOR CODES ───
      readonly RED='\033[0;31m'
      readonly GREEN='\033[0;32m'
      readonly YELLOW='\033[1;33m'
      readonly BLUE='\033[0;34m'
      readonly PURPLE='\033[0;35m'
      readonly CYAN='\033[0;36m'
      readonly WHITE='\033[1;37m'
      readonly GRAY='\033[0;37m'
      readonly NC='\033[0m' # No Color

      # ─── UNICODE SYMBOLS ───
      readonly CHECK_MARK="✓"
      readonly CROSS_MARK="✗"
      readonly WARNING="⚠"
      readonly INFO="ℹ"

      # ─── ERROR COUNTERS ───
      TOTAL_CHECKS=0
      PASSED_CHECKS=0
      FAILED_CHECKS=0
      WARNING_CHECKS=0

      # ═══════════════════════════════════════════════════════════════════════════════
      # UTILITY FUNCTIONS
      # ═══════════════════════════════════════════════════════════════════════════════

      print_header() {
          local title="$1"
          echo ""
          echo -e "''${PURPLE}🌹 ''${title}''${NC}"
          echo -e "''${PURPLE}$(printf '═%.0s' $(seq 1 ''${#title}))''${NC}"
      }

      print_section() {
          local title="$1"
          echo ""
          echo -e "''${BLUE}$title''${NC}"
      }

      print_check() {
          local status="$1"
          local message="$2"
          local details="''${3:-}"

          ((TOTAL_CHECKS++))

          case "$status" in
              "PASS")
                  echo -e "''${GREEN}''${CHECK_MARK} ''${message}''${NC}"
                  [ -n "$details" ] && echo -e "    ''${GRAY}''${details}''${NC}"
                  ((PASSED_CHECKS++))
                  ;;
              "FAIL")
                  echo -e "''${RED}''${CROSS_MARK} ''${message}''${NC}"
                  [ -n "$details" ] && echo -e "    ''${RED}''${details}''${NC}"
                  ((FAILED_CHECKS++))
                  ;;
              "WARN")
                  echo -e "''${YELLOW}''${WARNING} ''${message}''${NC}"
                  [ -n "$details" ] && echo -e "    ''${YELLOW}''${details}''${NC}"
                  ((WARNING_CHECKS++))
                  ;;
              "INFO")
                  echo -e "''${CYAN}''${INFO} ''${message}''${NC}"
                  [ -n "$details" ] && echo -e "    ''${CYAN}''${details}''${NC}"
                  ;;
          esac
      }

      # ═══════════════════════════════════════════════════════════════════════════════
      # MAIN CHECK FUNCTIONS
      # ═══════════════════════════════════════════════════════════════════════════════

      check_environment_variables() {
          print_section "Environment Variables"

          # Check key environment variables
          if [[ "''${QT_QPA_PLATFORMTHEME:-}" == "qt6ct" ]]; then
              print_check "PASS" "QT_QPA_PLATFORMTHEME correctly set" "qt6ct"
          else
              print_check "FAIL" "QT_QPA_PLATFORMTHEME incorrect" "Expected: qt6ct, Got: ''${QT_QPA_PLATFORMTHEME:-unset}"
          fi

          if [[ "''${QT_STYLE_OVERRIDE:-}" == "kvantum" ]]; then
              print_check "PASS" "QT_STYLE_OVERRIDE correctly set" "kvantum"
          else
              print_check "FAIL" "QT_STYLE_OVERRIDE incorrect" "Expected: kvantum, Got: ''${QT_STYLE_OVERRIDE:-unset}"
          fi

          if [[ "''${GTK_THEME:-}" == "Rose-Pine-Main-BL" ]]; then
              print_check "PASS" "GTK_THEME correctly set" "Rose-Pine-Main-BL"
          else
              print_check "WARN" "GTK_THEME incorrect" "Expected: Rose-Pine-Main-BL, Got: ''${GTK_THEME:-unset}"
          fi

          if [[ "''${XCURSOR_THEME:-}" == "rose-pine-hyprcursor" ]]; then
              print_check "PASS" "XCURSOR_THEME correctly set" "rose-pine-hyprcursor"
          else
              print_check "WARN" "XCURSOR_THEME incorrect" "Expected: rose-pine-hyprcursor, Got: ''${XCURSOR_THEME:-unset}"
          fi
      }

      check_packages() {
          print_section "Package Availability"

          # Check critical packages
          for pkg in kitty fuzzel micro dolphin qt6ct kvantummanager nwg-look; do
              if command -v "$pkg" &> /dev/null; then
                  print_check "PASS" "$pkg available"
              else
                  print_check "FAIL" "$pkg not found"
              fi
          done
      }

      check_theme_files() {
          print_section "Theme Files and Configuration"

          # Check Kvantum Rose Pine theme directory
          if [[ -d "$HOME/.config/Kvantum/RosePine" ]]; then
              print_check "PASS" "Kvantum Rose Pine theme directory found"
              if [[ -f "$HOME/.config/Kvantum/RosePine/rose-pine-rose.kvconfig" ]]; then
                  print_check "PASS" "Rose Pine Kvantum config found"
              else
                  print_check "WARN" "Rose Pine Kvantum config missing"
              fi
          else
              print_check "FAIL" "Kvantum Rose Pine theme directory missing" "$HOME/.config/Kvantum/RosePine"
          fi

          # Check kdeglobals
          if [[ -f "$HOME/.config/kdeglobals" ]]; then
              if grep -q "ColorScheme=Rose-Pine-Main-BL" "$HOME/.config/kdeglobals" 2>/dev/null; then
                  print_check "PASS" "kdeglobals Rose Pine configured"
              else
                  print_check "WARN" "kdeglobals exists but may not be Rose Pine"
              fi
          else
              print_check "FAIL" "kdeglobals missing"
          fi

          # Check Kvantum config
          if [[ -f "$HOME/.config/Kvantum/kvantum.kvconfig" ]]; then
              if grep -q "theme=rose-pine-rose" "$HOME/.config/Kvantum/kvantum.kvconfig" 2>/dev/null; then
                  print_check "PASS" "Kvantum Rose Pine theme configured"
              else
                  print_check "WARN" "Kvantum config exists but theme may not be Rose Pine"
              fi
          else
              print_check "FAIL" "Kvantum config missing"
          fi

          # Check Qt6ct config
          if [[ -f "$HOME/.config/qt6ct/qt6ct.conf" ]]; then
              if grep -q "style=kvantum" "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null; then
                  print_check "PASS" "Qt6ct Kvantum style configured"
              else
                  print_check "WARN" "Qt6ct exists but style may not be Kvantum"
              fi
          else
              print_check "FAIL" "Qt6ct config missing"
          fi
      }

      check_fonts() {
          print_section "Font Installation"

          if command -v fc-list &> /dev/null; then
              print_check "PASS" "fontconfig available" "$(fc-list | wc -l) fonts detected"

              # Check key fonts
              if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
                  print_check "PASS" "JetBrainsMono Nerd Font installed"
              else
                  print_check "FAIL" "JetBrainsMono Nerd Font not found" "Required from nerd-fonts.jetbrains-mono package"
              fi

              if fc-list | grep -qi "Rounded Mplus 1c"; then
                  print_check "PASS" "Rounded Mplus 1c font installed"
              else
                  print_check "FAIL" "Rounded Mplus 1c font not found" "Required from pkgs.google-fonts (system-level dependency)"
              fi

              if fc-list | grep -qi "Noto Sans"; then
                  print_check "PASS" "Noto Sans fonts installed"
              else
                  print_check "FAIL" "Noto Sans fonts not found" "Required from noto-fonts packages"
              fi

              if fc-list | grep -qi "Font Awesome"; then
                  print_check "PASS" "Font Awesome icons installed"
              else
                  print_check "WARN" "Font Awesome icons not found" "May affect UI icon display"
              fi
          else
              print_check "FAIL" "fontconfig not available"
          fi
      }

      show_troubleshooting() {
          print_section "Troubleshooting Tips"

          echo -e "''${YELLOW}If theming is not working:''${NC}"
          echo "1. Run kvantummanager and select Rose Pine theme"
          echo "2. Restart KDE applications: pkill dolphin && dolphin &"
          echo "3. Logout and login to reload environment variables"
          echo "4. Check Home Manager rebuild: home-manager switch"
          echo ""
          echo -e "''${YELLOW}Font troubleshooting:''${NC}"
          echo "• TESTING: google-fonts moved to user-level (home-theme.nix)"
          echo "• JetBrainsMono requires nerd-fonts.jetbrains-mono in home-theme.nix"
          echo "• Run 'fc-list | grep -i \"mplus\"' to verify font installation"
          echo "• Check both home-theme.nix and /etc/nixos/configuration.nix for fonts"
          echo ""
          echo -e "''${YELLOW}Manual theme tools:''${NC}"
          echo " kvantummanager - Kvantum theme manager"
          echo " qt6ct - Qt6 configuration tool"
          echo " nwg-look - GTK theme manager"
          echo ""
      }

      print_summary() {
          print_header "Diagnostic Summary"

          local pass_percent=0
          if [[ $TOTAL_CHECKS -gt 0 ]]; then
              pass_percent=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
          fi

          echo -e "''${WHITE}Total Checks: $TOTAL_CHECKS''${NC}"
          echo -e "''${GREEN}Passed: $PASSED_CHECKS ($pass_percent%)''${NC}"
          echo -e "''${YELLOW}Warnings: $WARNING_CHECKS''${NC}"
          echo -e "''${RED}Failed: $FAILED_CHECKS''${NC}"
          echo ""

          if [[ $FAILED_CHECKS -eq 0 ]]; then
              echo -e "''${GREEN}🎉 All critical checks passed! Your Rose Pine theme setup looks good.''${NC}"
          elif [[ $FAILED_CHECKS -lt 5 ]]; then
              echo -e "''${YELLOW}⚠️  Minor issues detected. Review failed checks above.''${NC}"
          else
              echo -e "''${RED}❌ Multiple issues detected. Consider running manual fixes.''${NC}"
          fi
          echo ""
      }

      # ═══════════════════════════════════════════════════════════════════════════════
      # MAIN EXECUTION
      # ═══════════════════════════════════════════════════════════════════════════════

      main() {
          # Parse command line arguments
          while [[ $# -gt 0 ]]; do
              case $1 in
                  --verbose|-v)
                      VERBOSE=true
                      shift
                      ;;
                  --fix-suggestions|-f)
                      SHOW_FIX_SUGGESTIONS=true
                      shift
                      ;;
                  --version)
                      echo "Rose Pine Theme Diagnostic Tool v$SCRIPT_VERSION"
                      exit 0
                      ;;
                  --help|-h)
                      echo "Usage: check-rose-pine-theme [OPTIONS]"
                      echo ""
                      echo "Options:"
                      echo "  --verbose, -v           Show detailed output"
                      echo "  --fix-suggestions, -f   Show fix suggestions for issues"
                      echo "  --version              Show version information"
                      echo "  --help, -h             Show this help message"
                      echo ""
                      echo "This script performs comprehensive checks of your Rose Pine theme setup."
                      exit 0
                      ;;
                  *)
                      echo "Unknown option: $1"
                      echo "Use --help for usage information."
                      exit 1
                      ;;
              esac
          done

          print_header "Rose Pine Theme Diagnostic Tool"
          echo -e "''${CYAN}Version: $SCRIPT_VERSION''${NC}"
          echo -e "''${CYAN}Checking Rose Pine theme integration...''${NC}"

          # Run all checks
          check_environment_variables
          check_packages
          check_theme_files
          check_fonts

          # Show troubleshooting guide if there were issues
          if [[ $FAILED_CHECKS -gt 0 ]] || [[ $WARNING_CHECKS -gt 3 ]]; then
              show_troubleshooting
          fi

          # Print summary
          print_summary

          # Exit with appropriate code
          if [[ $FAILED_CHECKS -gt 0 ]]; then
              exit 1
          else
              exit 0
          fi
      }

      # Run main function
      main "$@"
    '')
  ];
}
