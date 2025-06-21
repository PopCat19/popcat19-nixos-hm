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
    theme = {
      name = "Rose-Pine-Main-BL";           # Must match GTK_THEME environment variable
      package = pkgs.rose-pine-gtk-theme-full;  # Custom package built in pkgs/
    };

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
      gtk-application-prefer-dark-theme = true;    # Force dark theme preference
      gtk-decoration-layout = "appmenu:minimize,maximize,close";  # macOS-style window controls
      gtk-enable-animations = true;                # Enable smooth animations
      gtk-primary-button-warps-slider = false;    # Disable confusing slider behavior
    };

    # ─── GTK4 SPECIFIC SETTINGS ───
    # GTK4 applications need separate configuration for the same settings
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
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

  # ─── THEME INITIALIZATION SERVICE ───
  # Ensures themes are properly loaded and applied at session start
  # Runs our theme checker to verify everything is working
  systemd.user.services.theme-init = {
    Unit = {
      Description = "Initialize desktop themes";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.homeDirectory}/.local/bin/check-rose-pine-theme";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # 📦 THEME-RELATED PACKAGES
  # ═══════════════════════════════════════════════════════════════════════════════
  # These packages provide theming components, tools, and dependencies

  home.packages = with pkgs; [
    # ─── THEME MANAGEMENT TOOLS ───
    nwg-look                           # GTK theme configuration GUI
    dconf-editor                       # dconf settings editor
    libsForQt5.qt5ct                   # Qt5 configuration tool
    qt6ct                              # Qt6 configuration tool (used in environment vars)
    themechanger                       # Theme switching utility

    # ─── ROSE PINE THEME PACKAGES ───
    rose-pine-kvantum                  # Kvantum Rose Pine themes
    rose-pine-gtk-theme-full           # Complete Rose Pine GTK theme (custom package)
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
  ];
}
