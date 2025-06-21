# ~/nixos-config/home.nix
# ═══════════════════════════════════════════════════════════════════════════════
# 🏠 HOME MANAGER CONFIGURATION - COMPREHENSIVE ROSE PINE DESKTOP ENVIRONMENT
# ═══════════════════════════════════════════════════════════════════════════════
#
# This file configures a complete desktop environment using Home Manager with
# consistent Rose Pine theming across all applications. The configuration is
# designed for Hyprland compositor on NixOS.
#
# KEY DESIGN PRINCIPLES:
# 1. Consistent Rose Pine theming across ALL applications (GTK, Qt, terminal, etc.)
# 2. Hyprland-native tools preference (grim/slurp vs xorg tools)
# 3. Modern terminal-centric workflow with Fish shell and Kitty
# 4. Comprehensive file management with thumbnails and proper MIME associations
# 5. Japanese input support with Fcitx5
# 6. Gaming and multimedia support with proper audio/video handling
#
# MAJOR DEPENDENCY CHAINS:
# • Theming: rose-pine-gtk-theme → kdeglobals → kvantum → qt6ct → environment vars
# • Terminal: kitty → fish → starship → custom functions → abbreviations
# • Launcher: fuzzel → desktop files → MIME associations → default applications
# • File Management: dolphin/nemo → thumbnails → bookmarks → service menus
# • Input: fcitx5 → mozc → rose-pine theme → font configuration
# • Screenshots: grim/slurp → hyprshade integration → clipboard → notifications
#
{ pkgs, config, system, lib, inputs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════════════════
  # 🔧 BASIC HOME CONFIGURATION
  # ═══════════════════════════════════════════════════════════════════════════════
  # These are the foundational settings that Home Manager needs to function.
  # All other configurations depend on these basic parameters being set correctly.

  home.username = "popcat19";  # Must match system user account
  home.homeDirectory = "/home/popcat19";  # Must match system home directory
  home.stateVersion = "24.05";  # Home Manager state version for compatibility

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🌍 ENVIRONMENT VARIABLES - DESKTOP INTEGRATION FOUNDATION
  # ═══════════════════════════════════════════════════════════════════════════════
  # These environment variables are CRITICAL for proper theming and application
  # integration. They tell applications which theming engines to use and how to
  # behave in the Wayland environment.
  #
  # DEPENDENCY CHAIN: Environment variables → Application startup → Theme loading

  home.sessionVariables = {
    # ─── TEXT EDITORS ───
    # Used by git, crontab, and other CLI tools that need to spawn an editor
    EDITOR = "micro";  # Terminal-based editor with syntax highlighting
    VISUAL = "$EDITOR";  # Visual editor fallback (many tools check both)

    # ─── WEB BROWSER ───
    # Default browser for xdg-open and application launching
    # Using Flatpak Zen browser for better sandboxing and updates
    BROWSER = "flatpak run app.zen_browser.zen";

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

  # ─── PATH CONFIGURATION ───
  # Adds ~/.local/bin to PATH so our custom scripts (screenshot tools, etc.) can be found
  # This is essential for the executable scripts we create later in this file
  home.sessionPath = [ "$HOME/.local/bin" ];

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🎯 XDG MIME APPLICATIONS - DEFAULT APPLICATION ROUTING
  # ═══════════════════════════════════════════════════════════════════════════════
  # This section defines which applications handle which file types. It's crucial
  # for proper desktop integration - when you double-click a file or open a link,
  # these settings determine which application launches.
  #
  # DEPENDENCY CHAIN: File/URL → MIME type detection → xdg.mimeApps → Application launch
  # All applications referenced here must be installed via home.packages

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # ─── WEB PROTOCOLS ───
      # These handle all web links and HTML files
      # Must match the actual .desktop file names from the applications
      "x-scheme-handler/http" = ["zen.desktop"];
      "x-scheme-handler/https" = ["zen.desktop"];
      "text/html" = ["zen.desktop"];
      "application/xhtml+xml" = ["zen.desktop"];

      # ─── TERMINAL EMULATOR ───
      # Used when applications need to spawn a terminal or for terminal:// links
      # Kitty is configured below in programs.kitty
      "application/x-terminal-emulator" = ["kitty.desktop"];
      "x-scheme-handler/terminal" = ["kitty.desktop"];

      # ─── TEXT FILES ───
      # All text editing goes through Micro editor
      # Micro is configured below in programs.micro
      "text/plain" = ["micro.desktop"];
      "text/x-readme" = ["micro.desktop"];
      "text/x-log" = ["micro.desktop"];
      "application/json" = ["micro.desktop"];
      "text/x-python" = ["micro.desktop"];
      "text/x-shellscript" = ["micro.desktop"];
      "text/x-script" = ["micro.desktop"];

      # ─── IMAGE VIEWING ───
      # Gwenview provides excellent image viewing with Rose Pine theming
      # Depends on KDE theming configuration (kdeglobals) below
      "image/jpeg" = ["org.kde.gwenview.desktop"];
      "image/png" = ["org.kde.gwenview.desktop"];
      "image/gif" = ["org.kde.gwenview.desktop"];
      "image/webp" = ["org.kde.gwenview.desktop"];
      "image/svg+xml" = ["org.kde.gwenview.desktop"];

      # ─── VIDEO PLAYBACK ───
      # MPV is lightweight and works well with our theming
      "video/mp4" = ["mpv.desktop"];
      "video/mkv" = ["mpv.desktop"];
      "video/avi" = ["mpv.desktop"];
      "video/webm" = ["mpv.desktop"];
      "video/x-matroska" = ["mpv.desktop"];

      # ─── AUDIO PLAYBACK ───
      # MPV handles audio files as well as video
      "audio/mpeg" = ["mpv.desktop"];
      "audio/ogg" = ["mpv.desktop"];
      "audio/wav" = ["mpv.desktop"];
      "audio/flac" = ["mpv.desktop"];

      # ─── ARCHIVE MANAGEMENT ───
      # Ark integrates with KDE theming and provides good archive support
      "application/zip" = ["org.kde.ark.desktop"];
      "application/x-tar" = ["org.kde.ark.desktop"];
      "application/x-compressed-tar" = ["org.kde.ark.desktop"];
      "application/x-7z-compressed" = ["org.kde.ark.desktop"];

      # ─── FILE MANAGEMENT ───
      # Dolphin is configured extensively below with Rose Pine theming
      "inode/directory" = ["org.kde.dolphin.desktop"];

      # ─── PDF VIEWING ───
      # Okular integrates with KDE theming
      "application/pdf" = ["org.kde.okular.desktop"];
    };

    # Additional associations for applications that might not be caught by defaults
    associations.added = {
      "application/x-terminal-emulator" = ["kitty.desktop"];
      "x-scheme-handler/terminal" = ["kitty.desktop"];
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🎨 GTK THEMING CONFIGURATION - VISUAL CONSISTENCY FOUNDATION
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
    # This font is installed via home.packages and configured in fontconfig
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
  # 🔧 SYSTEMD USER SERVICES - BACKGROUND SYSTEM INTEGRATION
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
  # 💻 TERMINAL CONFIGURATION - KITTY WITH ROSE PINE THEMING
  # ═══════════════════════════════════════════════════════════════════════════════
  # Kitty is our primary terminal emulator, configured with Rose Pine colors
  # and optimized for our workflow. It integrates with Fish shell and supports
  # our custom features like screenshots and Hyprland integration.
  #
  # DEPENDENCY CHAIN: kitty → fish shell → starship prompt → custom functions

  programs.kitty = {
    enable = true;

    # ─── FONT CONFIGURATION ───
    # JetBrains Mono provides excellent programming font with Nerd Font icons
    font = {
      name = "JetBrainsMono Nerd Font";  # Must be installed in home.packages
      size = 11;                         # Comfortable size for coding
    };

    settings = {
      # ─── SHELL INTEGRATION ───
      shell = "fish";                    # Must match programs.fish.enable
      shell_integration = "enabled";     # Enables advanced shell features

      # ─── WINDOW BEHAVIOR ───
      confirm_os_window_close = 1;       # Prevent accidental closure

      # ─── CURSOR CONFIGURATION ───
      cursor_shape = "block";            # Block cursor for visibility
      cursor_blink_interval = 0.5;       # Moderate blink rate
      cursor_stop_blinking_after = 15.0; # Stop blinking after 15 seconds

      # ─── SCROLLBACK ───
      scrollback_lines = 10000;          # Large scrollback buffer

      # ─── MOUSE BEHAVIOR ───
      mouse_hide_wait = 3.0;             # Hide mouse after 3 seconds
      url_color = "#c4a7e7";             # Rose Pine iris for URLs
      url_style = "curly";               # Underline style for URLs
      detect_urls = "yes";               # Enable URL detection

      # ─── PERFORMANCE TUNING ───
      repaint_delay = 10;                # Low latency rendering
      input_delay = 3;                   # Minimal input delay
      sync_to_monitor = "yes";           # Smooth scrolling

      # ─── AUDIO ───
      enable_audio_bell = "no";          # Disable audio bell
      visual_bell_duration = 0.0;        # Disable visual bell

      # ─── WINDOW STYLING ───
      remember_window_size = "yes";      # Remember window dimensions
      window_border_width = 0.5;         # Thin border
      window_margin_width = 8;           # Space around terminal
      window_padding_width = 12;         # Internal padding
      active_border_color = "#ebbcba";   # Rose Pine rose for active border
      inactive_border_color = "#26233a"; # Rose Pine overlay for inactive

      # ─── TAB BAR STYLING ───
      tab_bar_edge = "bottom";           # Tabs at bottom
      tab_bar_style = "separator";       # Separator style
      tab_separator = " ┇ ";             # Unicode separator
      active_tab_foreground = "#e0def4"; # Rose Pine text
      active_tab_background = "#26233a"; # Rose Pine overlay
      inactive_tab_foreground = "#908caa"; # Rose Pine subtle
      inactive_tab_background = "#191724"; # Rose Pine base

      # ─── ROSE PINE COLOR SCHEME ───
      # Main terminal colors using Rose Pine palette
      foreground = "#e0def4";            # Rose Pine text
      background = "#191724";            # Rose Pine base
      selection_foreground = "#e0def4";  # Rose Pine text
      selection_background = "#403d52";  # Rose Pine highlight medium

      # ─── 16-COLOR PALETTE ───
      # Standard terminal colors following Rose Pine theme
      color0 = "#26233a";   # Black (Rose Pine overlay)
      color1 = "#eb6f92";   # Red (Rose Pine love)
      color2 = "#9ccfd8";   # Green (Rose Pine foam)
      color3 = "#f6c177";   # Yellow (Rose Pine gold)
      color4 = "#31748f";   # Blue (Rose Pine pine)
      color5 = "#c4a7e7";   # Magenta (Rose Pine iris)
      color6 = "#ebbcba";   # Cyan (Rose Pine rose)
      color7 = "#e0def4";   # White (Rose Pine text)
      color8 = "#6e6a86";   # Bright Black (Rose Pine muted)
      color9 = "#eb6f92";   # Bright Red (Rose Pine love)
      color10 = "#9ccfd8";  # Bright Green (Rose Pine foam)
      color11 = "#f6c177";  # Bright Yellow (Rose Pine gold)
      color12 = "#31748f";  # Bright Blue (Rose Pine pine)
      color13 = "#c4a7e7";  # Bright Magenta (Rose Pine iris)
      color14 = "#ebbcba";  # Bright Cyan (Rose Pine rose)
      color15 = "#e0def4";  # Bright White (Rose Pine text)

      # ─── TRANSPARENCY AND EFFECTS ───
      background_opacity = "0.85";       # Slight transparency for aesthetics
      dynamic_background_opacity = "yes"; # Allow dynamic opacity changes
      background_blur = 20;              # Blur background for better readability
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🚀 APPLICATION LAUNCHER - FUZZEL WITH ROSE PINE THEMING
  # ═══════════════════════════════════════════════════════════════════════════════
  # Fuzzel is our Wayland-native application launcher, styled with Rose Pine theme
  # and configured for optimal usability. It integrates with our icon theme and
  # launches applications using our MIME associations.
  #
  # DEPENDENCY CHAIN: fuzzel → desktop files → icon theme → applications

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        # ─── VISUAL CONFIGURATION ───
        font = "Rounded Mplus 1c Medium:size=14"; # Must match system font
        layer = "overlay";             # Display above all other windows
        exit-on-click = true;          # Close when clicking outside
        prompt = "  ";               # Unicode search icon
        placeholder = "Search applications..."; # Helpful placeholder text
        width = 50;                    # Width in characters
        lines = 12;                    # Number of visible results

        # ─── PADDING AND SPACING ───
        horizontal-pad = 20;           # Horizontal padding
        vertical-pad = 12;             # Vertical padding
        inner-pad = 8;                 # Padding between border and content
        image-size-ratio = 0.8;        # Size ratio for application icons

        # ─── FUNCTIONALITY ───
        show-actions = true;           # Show application actions in context menu
        terminal = "kitty";            # Terminal for launching terminal apps (matches programs.kitty)
        launch-prefix = "";            # No prefix for launching applications
        filter-desktop = true;         # Only show .desktop files
        icon-theme = "Papirus-Dark";   # Must match gtk.iconTheme.name
        icons-enabled = true;          # Enable application icons
        fields = "name,generic,comment,categories,filename,keywords"; # Search these fields
        password-character = "*";      # Character for password fields
        tab-cycles = true;             # Tab cycles through results
        match-mode = "fzf";            # Fuzzy matching algorithm
        sort-result = true;            # Sort search results alphabetically
        list-executables-in-path = false; # Don't list PATH executables (cleaner results)
      };

      # ─── ROSE PINE COLOR SCHEME ───
      colors = {
        background = "191724f0";       # Rose Pine base with opacity (f0 = 94% opacity)
        text = "e0def4ff";             # Rose Pine text (fully opaque)
        match = "eb6f92ff";            # Rose Pine love for search matches
        selection = "403d52ff";        # Rose Pine highlight medium for selection
        selection-text = "e0def4ff";   # Rose Pine text for selected items
        selection-match = "f6c177ff";  # Rose Pine gold for selected matches
        border = "ebbcbaff";           # Rose Pine rose for border
        placeholder = "908caaff";      # Rose Pine subtle for placeholder text
      };

      # ─── BORDER AND STYLING ───
      border = {
        radius = 12;                   # Rounded corners for modern look
        width = 2;                     # Border width in pixels
      };

      # ─── KEY BINDINGS ───
      # Comprehensive key bindings for efficient navigation
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

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🐠 FISH SHELL CONFIGURATION - MODERN SHELL WITH CUSTOM WORKFLOW
  # ═══════════════════════════════════════════════════════════════════════════════
  # Fish shell provides a modern command-line experience with syntax highlighting,
  # autosuggestions, and excellent tab completion. Our configuration includes
  # custom abbreviations for NixOS workflow and integrates with Starship prompt.
  #
  # DEPENDENCY CHAIN: fish → starship → custom functions → abbreviations

  programs.fish = {
    enable = true;

    # ─── SHELL INITIALIZATION ───
    # This script runs when fish starts and sets up our environment
    shellInit = ''
      # NixOS-specific environment variables
      set -Ux NIXOS_CONFIG_DIR $HOME/nixos-config        # Path to our NixOS config
      set -Ux NIXOS_FLAKE_HOSTNAME popcat19-nixos0       # Flake hostname for builds
      set -g fish_greeting ""                             # Disable default greeting

      # Custom greeting function (currently empty but can be customized)
      function fish_greeting
          # Empty greeting - we rely on Starship for visual information
      end

      # Add user's personal bin directory to PATH
      fish_add_path $HOME/bin

      # Initialize Starship prompt for interactive sessions only
      if status is-interactive
          starship init fish | source
      end
    '';

    # ─── SHELL ABBREVIATIONS ───
    # These abbreviations expand to full commands when typed, providing shortcuts
    # for common operations. They're organized by category for maintainability.
    shellAbbrs = {
      # ─── NAVIGATION SHORTCUTS ───
      # Quick directory navigation - saves typing for common directory traversal
      ".." = "cd ..";                  # Go up one directory
      "..." = "cd ../..";              # Go up two directories
      ".3" = "cd ../../..";            # Go up three directories
      ".4" = "cd ../../../..";         # Go up four directories
      ".5" = "cd ../../../../..";      # Go up five directories

      # ─── FILE OPERATIONS ───
      # Modern file operations using eza (better than ls) with consistent formatting
      mkdir = "mkdir -p";              # Create directories with parents
      l = "eza -lh --icons=auto";      # List with human-readable sizes and icons
      ls = "eza -1 --icons=auto";      # Simple list with icons
      ll = "eza -lha --icons=auto --sort=name --group-directories-first"; # Detailed list
      ld = "eza -lhD --icons=auto";    # List directories only
      lt = "eza --tree --icons=auto";  # Tree view with icons
      o = "open_smart";                # Custom function to intelligently open files

      # ─── NIXOS CONFIGURATION MANAGEMENT ───
      # These abbreviations provide quick access to NixOS configuration editing
      # All refer to custom functions defined in fish_functions/
      nconf = "nixconf-edit";          # Edit NixOS system configuration
      nixos-ed = "nixconf-edit";       # Alias for nconf
      hconf = "homeconf-edit";         # Edit Home Manager configuration
      home-ed = "homeconf-edit";       # Alias for hconf
      flconf = "flake-edit";           # Edit flake.nix
      flake-ed = "flake-edit";         # Alias for flconf
      flup = "flake-update";           # Update flake inputs
      flake-up = "flake-update";       # Alias for flup
      ngit = "nixos-git";              # Git operations in nixos-config directory

      # ─── NIXOS BUILD AND SWITCH OPERATIONS ───
      # These abbreviations handle building and switching NixOS configurations
      nrb = "nixos-apply-config";      # Main rebuild and switch command
      nixos-sw = "nixos-apply-config"; # Alias for nrb
      nerb = "nixos-edit-rebuild";     # Edit configuration and rebuild
      nixoss = "nixos-edit-rebuild";   # Alias for nerb
      herb = "home-edit-rebuild";      # Edit Home Manager config and rebuild
      home-sw = "home-edit-rebuild";   # Alias for herb
      nup = "nixos-upgrade";           # Update and upgrade system
      nixos-up = "nixos-upgrade";      # Alias for nup

      # ─── PACKAGE MANAGEMENT ───
      # Custom nixpkg function provides a unified interface for package management
      pkgls = "nixpkg list";           # List installed packages
      pkgadd = "nixpkg add";           # Add package to configuration
      pkgrm = "nixpkg remove";         # Remove package from configuration
      pkgs = "nixpkg search";          # Search for packages
      pkghelp = "nixpkg help";         # Show nixpkg help
      pkgman = "nixpkg manual";        # Show nixpkg manual
      pkgaddr = "nixpkg add --rebuild"; # Add package and rebuild immediately
      pkgrmr = "nixpkg remove --rebuild"; # Remove package and rebuild immediately
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # ⭐ STARSHIP PROMPT - BEAUTIFUL AND INFORMATIVE COMMAND PROMPT
  # ═══════════════════════════════════════════════════════════════════════════════
  # Starship provides a fast, customizable prompt with git integration, language
  # detection, and system information. Our configuration uses Rose Pine colors
  # throughout and shows relevant information for development workflows.
  #
  # DEPENDENCY CHAIN: starship → fish shell → git → development tools

  programs.starship = {
    enable = true;
    settings = {
      # ─── PROMPT FORMAT AND PALETTE ───
      format = "$all$character";       # Use all modules with character at end
      palette = "rose_pine";           # Use our custom Rose Pine palette

      # ─── ROSE PINE COLOR PALETTE ───
      # All colors defined using Rose Pine theme specification
      palettes.rose_pine = {
        base = "#191724";              # Main background color
        surface = "#1f1d2e";           # Secondary background
        overlay = "#26233a";           # Overlay color for UI elements
        muted = "#6e6a86";             # Muted text color
        subtle = "#908caa";            # Subtle text color
        text = "#e0def4";              # Main text color
        love = "#eb6f92";              # Red/pink color for errors
        gold = "#f6c177";              # Yellow/gold color for warnings
        rose = "#ebbcba";              # Rose color for highlights
        pine = "#31748f";              # Blue/teal color for info
        foam = "#9ccfd8";              # Cyan color for success
        iris = "#c4a7e7";              # Purple color for special elements
        highlight_low = "#21202e";     # Low highlight
        highlight_med = "#403d52";     # Medium highlight
        highlight_high = "#524f67";    # High highlight
      };

      # ─── COMMAND CHARACTER ───
      # The prompt character changes based on command success/failure and vim mode
      character = {
        success_symbol = "[❯](bold foam)";  # Success: cyan arrow
        error_symbol = "[❯](bold love)";    # Error: red arrow
        vimcmd_symbol = "[❮](bold iris)";   # Vim command mode: purple arrow
      };

      # ─── DIRECTORY MODULE ───
      # Shows current directory with read-only indicator
      directory = {
        style = "bold iris";           # Purple color for directories
        truncation_length = 3;         # Show last 3 directory components
        truncate_to_repo = false;      # Don't truncate to git repo root
        format = "[$path]($style)[$read_only]($read_only_style) ";
        read_only = " 󰌾";             # Lock icon for read-only directories
        read_only_style = "love";      # Red color for read-only indicator
      };

      # ─── GIT BRANCH MODULE ───
      # Shows current git branch with remote tracking
      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
        symbol = " ";                # Git branch icon
        style = "bold pine";           # Blue/teal color for git branch
      };

      # ─── GIT STATUS MODULE ───
      # Comprehensive git status information with custom symbols
      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        style = "bold rose";           # Rose color for git status
        conflicted = "=";              # Symbol for merge conflicts
        ahead = "⇡\${count}";          # Ahead of remote
        behind = "⇣\${count}";         # Behind remote
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}"; # Diverged from remote
        up_to_date = "";               # No symbol when up to date
        untracked = "?\${count}";      # Untracked files
        stashed = "$\${count}";        # Stashed changes
        modified = "!\${count}";       # Modified files
        staged = "+\${count}";         # Staged changes
        renamed = "»\${count}";        # Renamed files
        deleted = "✘\${count}";        # Deleted files
      };

      # ─── COMMAND DURATION MODULE ───
      # Shows execution time for long-running commands
      cmd_duration = {
        format = "[$duration]($style) ";
        style = "bold gold";           # Gold color for timing info
        min_time = 2000;               # Only show for commands > 2 seconds
      };

      # ─── HOSTNAME MODULE ───
      # Shows hostname when connected via SSH
      hostname = {
        ssh_only = true;               # Only show when SSH'd
        format = "[$hostname]($style) in ";
        style = "bold foam";           # Cyan color for hostname
      };

      # ─── USERNAME MODULE ───
      # Shows username when not default user or when root
      username = {
        show_always = false;           # Only show when necessary
        format = "[$user]($style)@";
        style_user = "bold text";      # Normal user color
        style_root = "bold love";      # Root user in red
      };

      # ─── LANGUAGE-SPECIFIC MODULES ───
      # These modules detect and show versions of various programming languages

      # Package.json detection
      package = {
        format = "[$symbol$version]($style) ";
        symbol = "📦 ";
        style = "bold rose";
      };

      # Node.js detection
      nodejs = {
        format = "[$symbol($version)]($style) ";
        symbol = " ";                # Node.js icon
        style = "bold pine";
      };

      # Python detection
      python = {
        format = "[\${symbol}\${pyenv_prefix}(\${version})(\\($virtualenv\\))]($style) ";
        symbol = " ";                # Python icon
        style = "bold gold";
      };

      # Rust detection
      rust = {
        format = "[$symbol($version)]($style) ";
        symbol = " ";                # Rust icon
        style = "bold love";
      };

      # Nix shell detection
      nix_shell = {
        format = "[$symbol$state(\\($name\\))]($style) ";
        symbol = " ";                # Nix icon
        style = "bold iris";          # Purple for Nix
        impure_msg = "[impure](bold love)"; # Red for impure shells
        pure_msg = "[pure](bold foam)";     # Cyan for pure shells
      };

      # ─── SYSTEM INFORMATION MODULES ───

      # Memory usage (shows when above threshold)
      memory_usage = {
        disabled = false;              # Enable memory usage display
        threshold = 70;                # Show when usage > 70%
        format = "[$symbol\${ram}(\${swap})]($style) ";
        symbol = "🐏 ";               # RAM icon
        style = "bold subtle";         # Subtle color for system info
      };

      # Current time display
      time = {
        disabled = false;              # Enable time display
        format = "[$time]($style) ";
        style = "bold muted";          # Muted color for time
        time_format = "%T";            # 24-hour format (HH:MM:SS)
        utc_time_offset = "local";     # Use local timezone
      };

      # Exit status of last command
      status = {
        disabled = false;              # Enable status display
        format = "[$symbol$status]($style) ";
        symbol = "✖ ";                # Error symbol
        style = "bold love";           # Red color for errors
      };
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # 📝 GIT CONFIGURATION - VERSION CONTROL SETUP
  # ═══════════════════════════════════════════════════════════════════════════════
  # Basic git configuration with user information. This is essential for
  # git operations and integrates with our Starship prompt git modules.

  programs.git = {
    enable = true;
    userName = "PopCat19";             # Git commit author name
    userEmail = "atsuo11111@gmail.com"; # Git commit author email
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🌏 INPUT METHOD CONFIGURATION - JAPANESE INPUT SUPPORT
  # ═══════════════════════════════════════════════════════════════════════════════
  # Fcitx5 provides input method support for multiple languages, particularly
  # Japanese. Our configuration includes Mozc for Japanese input and Rose Pine
  # theming for visual consistency.
  #
  # DEPENDENCY CHAIN: fcitx5 → mozc → rose-pine theme → font configuration

  i18n.inputMethod = {
    type = "fcitx5";                   # Use Fcitx5 input method framework
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk                       # GTK module for application integration
      libsForQt5.fcitx5-qt            # Qt5 module for Qt application integration
      fcitx5-mozc                      # Mozc Japanese input method engine
      fcitx5-rose-pine                 # Rose Pine theme for Fcitx5
    ];
  };

  # ─── FCITX5 THEME CONFIGURATION ───
  # Configures Fcitx5 to use our custom font and Rose Pine theme
  home.file.".config/fcitx5/conf/classicui.conf".text = ''
    # Display Configuration
    Vertical Candidate List=False      # Horizontal candidate list
    PerScreenDPI=True                  # Use per-screen DPI scaling
    WheelForPaging=True                # Mouse wheel for page navigation

    # Font Configuration (must match our system font)
    Font="Rounded Mplus 1c Medium 11"
    MenuFont="Rounded Mplus 1c Medium 11"
    TrayFont="Rounded Mplus 1c Medium 11"

    # Tray Configuration
    TrayOutlineColor=#000000           # Black outline for tray
    TrayTextColor=#ffffff              # White text for tray
    PreferTextIcon=False               # Use graphical icons
    ShowLayoutNameInIcon=True          # Show layout name in tray icon
    UseInputMethodLangaugeToDisplayText=True
    EnableTray=True                    # Enable system tray integration

    # Theme Configuration
    Theme=rose-pine                    # Use Rose Pine theme
    DarkTheme=rose-pine                # Use Rose Pine for dark theme
    UseDarkTheme=True                  # Prefer dark theme
    UseAccentColor=True                # Use accent colors from theme

    # Input Method Behavior
    ShowPreeditInApplication=False     # Show preedit in input method window
  '';

  # ─── FCITX5 THEME FILES ───
  # Link Rose Pine theme files to user directory for Fcitx5 to find them
  home.file.".local/share/fcitx5/themes/rose-pine".source = "${pkgs.fcitx5-rose-pine}/share/fcitx5/themes/rose-pine";
  home.file.".local/share/fcitx5/themes/rose-pine-dawn".source = "${pkgs.fcitx5-rose-pine}/share/fcitx5/themes/rose-pine-dawn";
  home.file.".local/share/fcitx5/themes/rose-pine-moon".source = "${pkgs.fcitx5-rose-pine}/share/fcitx5/themes/rose-pine-moon";

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🔤 FONT CONFIGURATION - SYSTEM-WIDE FONT PREFERENCES
  # ═══════════════════════════════════════════════════════════════════════════════
  # Fontconfig ensures our custom fonts are properly recognized and used by
  # applications. This configuration creates aliases so applications can find
  # our preferred fonts.

  home.file.".config/fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <!-- Make Rounded Mplus 1c Medium the default sans-serif font -->
      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>Rounded Mplus 1c Medium</family>
        </prefer>
      </alias>

      <!-- Ensure our custom font is recognized as a sans-serif font -->
      <alias>
        <family>Rounded Mplus 1c Medium</family>
        <default>
          <family>sans-serif</family>
        </default>
      </alias>
    </fontconfig>
  '';

  # ═══════════════════════════════════════════════════════════════════════════════
  # 📁 CONFIGURATION FILE MANAGEMENT - SYMLINKS TO EXTERNAL CONFIGS
  # ═══════════════════════════════════════════════════════════════════════════════
  # These configurations link external configuration directories to the user's
  # config directory. This allows us to manage complex configurations (like
  # Hyprland) in separate files while still including them in our home config.

  # ─── HYPRLAND CONFIGURATION ───
  # Links the entire hypr_config directory to ~/.config/hypr
  # This includes hyprland.conf, monitors.conf, shaders, etc.
  home.file.".config/hypr" = {
    source = ./hypr_config;           # Source directory in our repo
    recursive = true;                 # Include all subdirectories and files
  };

  # ─── FISH SHELL FUNCTIONS ───
  # Custom fish functions for NixOS workflow automation
  # These functions are used by the shell abbreviations defined above
  home.file.".config/fish/functions" = {
    source = ./fish_functions;        # Directory containing our custom functions
    recursive = true;                 # Include all function files
  };

  # ─── FISH SHELL THEMES ───
  # Rose Pine themes for fish shell to match our overall theme
  home.file.".config/fish/themes" = {
    source = ./fish_themes;           # Directory containing theme files
    recursive = true;                 # Include all theme variants
  };

  # ─── MICRO EDITOR COLORSCHEME ───
  # Rose Pine colorscheme for Micro text editor
  home.file.".config/micro/colorschemes/rose-pine.micro" = {
    source = ./micro_config/rose-pine.micro; # Rose Pine theme for Micro
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🎮 MANGOHUD CONFIGURATION - GAMING PERFORMANCE OVERLAY
  # ═══════════════════════════════════════════════════════════════════════════════
  # MangoHud provides performance monitoring overlay for games and applications.
  # Our configuration uses Rose Pine colors and shows relevant gaming metrics.

  home.file.".config/MangoHud/MangoHud.conf" = {
    text = ''
      ################### Declarative MangoHud Configuration ###################
      # Modern layout with Rose Pine theming
      legacy_layout=false

      # Visual styling with Rose Pine colors
      background_alpha=0.0              # Transparent background
      round_corners=0                   # Square corners
      background_color=191724           # Rose Pine base color
      font_file=                        # Use system font
      font_size=14                      # Readable font size
      text_color=e0def4                 # Rose Pine text color
      position=middle-left              # Position on screen
      toggle_hud=Shift_R+F12           # Hotkey to toggle display
      hud_compact                       # Compact layout
      pci_dev=0:12:00.0                # GPU PCI device
      table_columns=2                   # Two-column layout

      # GPU monitoring with Rose Pine colors
      gpu_text=                         # No GPU text prefix
      gpu_stats                         # Show GPU statistics
      gpu_load_change                   # Show load changes
      gpu_load_value=50,90              # Thresholds for color changes
      gpu_load_color=e0def4,f6c177,eb6f92 # Rose Pine: text, gold, love
      gpu_voltage                       # Show GPU voltage
      gpu_core_clock                    # Show GPU core clock
      gpu_temp                          # Show GPU temperature
      gpu_mem_temp                      # Show GPU memory temperature
      gpu_junction_temp                 # Show GPU junction temperature
      gpu_fan                           # Show GPU fan speed
      gpu_power                         # Show GPU power consumption
      gpu_color=9ccfd8                  # Rose Pine foam for GPU

      # CPU monitoring with Rose Pine colors
      cpu_text=                         # No CPU text prefix
      cpu_stats                         # Show CPU statistics
      cpu_load_change                   # Show load changes
      cpu_load_value=50,90              # Thresholds for color changes
      cpu_load_color=e0def4,f6c177,eb6f92 # Rose Pine: text, gold, love
      cpu_mhz                           # Show CPU frequency
      cpu_temp                          # Show CPU temperature
      cpu_color=31748f                  # Rose Pine pine for CPU

      # Memory monitoring with Rose Pine colors
      vram                              # Show VRAM usage
      vram_color=c4a7e7                 # Rose Pine iris for VRAM
      ram                               # Show RAM usage
      ram_color=c4a7e7                  # Rose Pine iris for RAM
      battery                           # Show battery status (if applicable)
      battery_color=9ccfd8              # Rose Pine foam for battery

      # Frame rate monitoring with Rose Pine colors
      fps                               # Show frame rate
      fps_metrics=avg,0.01              # Show average and 1% low
      frame_timing                      # Show frame timing graph
      frametime_color=ebbcba            # Rose Pine rose for frame times
      throttling_status_graph           # Show throttling status
      fps_limit_method=early            # Early FPS limiting method
      toggle_fps_limit=none             # No FPS limit toggle
      fps_limit=0                       # No FPS limit
      fps_color_change                  # Change color based on FPS
      fps_color=eb6f92,f6c177,9ccfd8    # Rose Pine: love, gold, foam
      fps_value=60,90                   # FPS thresholds for color changes

      # Logging configuration
      af=8                              # Anisotropic filtering
      output_folder=/home/popcat19      # Log output directory
      log_duration=30                   # Log duration in seconds
      autostart_log=0                   # Don't auto-start logging
      log_interval=100                  # Log interval in milliseconds
      toggle_logging=Shift_L+F2         # Hotkey to toggle logging
    '';
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # 📸 SCREENSHOT UTILITIES - HYPRLAND-INTEGRATED SCREENSHOT TOOLS
  # ═══════════════════════════════════════════════════════════════════════════════
  # Custom screenshot scripts that integrate with Hyprland and Hyprshade.
  # These scripts handle monitor detection, shader management, and clipboard integration.

  # ─── FULL SCREEN SCREENSHOT SCRIPT ───
  # Takes a screenshot of the current monitor with automatic hyprshade handling
  home.file.".local/bin/screenshot-full" = {
    text = ''
      #!/usr/bin/env bash

      # Enhanced Full Screen Screenshot Script
      # Takes a screenshot of the current monitor with hyprshade support
      #
      # FEATURES:
      # - Automatic current monitor detection via hyprctl
      # - Hyprshade integration (temporarily disables shaders for clean capture)
      # - Clipboard integration via wl-copy
      # - Desktop notifications
      # - Error handling and cleanup

      set -euo pipefail

      # Configuration
      SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
      TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
      FILENAME="screenshot_''${TIMESTAMP}.png"
      FILEPATH="''${SCREENSHOT_DIR}/''${FILENAME}"

      # Ensure screenshot directory exists
      mkdir -p "$SCREENSHOT_DIR"

      # Function to get current monitor using hyprctl
      get_current_monitor() {
          if command -v hyprctl &> /dev/null; then
              hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'
          else
              echo ""
          fi
      }

      # Function to manage hyprshade (screen shaders)
      # This ensures clean screenshots without color filters
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
          # Get current monitor for focused screenshot
          CURRENT_MONITOR=$(get_current_monitor)

          # Save current shader and turn off hyprshade for clean capture
          SAVED_SHADER=$(manage_hyprshade "off")

          # Small delay to ensure shader is off
          sleep 0.1

          # Take screenshot (monitor-specific or full screen)
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

  # ─── REGION SCREENSHOT SCRIPT ───
  # Takes a screenshot of a user-selected region with hyprshade handling
  home.file.".local/bin/screenshot-region" = {
    text = ''
      #!/usr/bin/env bash

      # Enhanced Region Screenshot Script
      # Takes a screenshot of a selected region with hyprshade support
      #
      # FEATURES:
      # - Interactive region selection via slurp
      # - Monitor-constrained selection for multi-monitor setups
      # - Hyprshade integration with proper cleanup
      # - Clipboard integration
      # - Cancellation support (ESC key)

      set -euo pipefail

      # Configuration
      SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
      TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
      FILENAME="screenshot_region_''${TIMESTAMP}.png"
      FILEPATH="''${SCREENSHOT_DIR}/''${FILENAME}"

      # Ensure screenshot directory exists
      mkdir -p "$SCREENSHOT_DIR"

      # Function to get current monitor using hyprctl
      get_current_monitor() {
          if command -v hyprctl &> /dev/null; then
              hyprctl monitors -j | jq -r '.[] | select(.focused) | .name'
          else
              echo ""
          fi
      }

      # Function to manage hyprshade (same as full screenshot)
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
      # This ensures shaders are restored even if user cancels
      cleanup() {
          if [[ -n "''${SAVED_SHADER:-}" ]]; then
              manage_hyprshade "restore" "$SAVED_SHADER"
          fi
      }

      # Set trap to restore hyprshade on script exit (including ESC/SIGINT)
      trap cleanup EXIT INT TERM

      # Take region screenshot using grim + slurp
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

  # ─── THEME CHECKER UTILITY ───
  # Diagnostic script to verify Rose Pine theming is working correctly
  home.file.".local/bin/check-rose-pine-theme" = {
    text = ''
      #!/usr/bin/env bash

      # Rose Pine Theme Status Checker
      # Comprehensive diagnostic tool to verify Rose Pine theming across all applications
      #
      # FEATURES:
      # - Environment variable verification
      # - Theme file existence checks
      # - Configuration file validation
      # - Application availability checks
      # - Troubleshooting recommendations

      set -euo pipefail

      # Color codes for output formatting
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      YELLOW='\033[1;33m'
      BLUE='\033[0;34m'
      PURPLE='\033[0;35m'
      NC='\033[0m'

      print_header() {
          echo -e "''${PURPLE}🌹 Rose Pine Theme Status''${NC}"
          echo -e "''${PURPLE}══════════════════════════''${NC}"
          echo ""
      }

      check_environment() {
          echo -e "''${BLUE}🌍 Environment Variables''${NC}"

          if [[ "''${QT_QPA_PLATFORMTHEME:-}" == "qt6ct" ]]; then
              echo -e "''${GREEN}✓ QT_QPA_PLATFORMTHEME: qt6ct''${NC}"
          else
              echo -e "''${RED}✗ QT_QPA_PLATFORMTHEME: ''${QT_QPA_PLATFORMTHEME:-unset} (should be 'qt6ct')''${NC}"
          fi

          if [[ "''${QT_STYLE_OVERRIDE:-}" == "kvantum" ]]; then
              echo -e "''${GREEN}✓ QT_STYLE_OVERRIDE: kvantum''${NC}"
          else
              echo -e "''${RED}✗ QT_STYLE_OVERRIDE: ''${QT_STYLE_OVERRIDE:-unset} (should be 'kvantum')''${NC}"
          fi

          if [[ "''${GTK_THEME:-}" == "Rose-Pine-Main-BL" ]]; then
              echo -e "''${GREEN}✓ GTK_THEME: Rose-Pine-Main-BL''${NC}"
          else
              echo -e "''${RED}✗ GTK_THEME: ''${GTK_THEME:-unset} (should be 'Rose-Pine-Main-BL')''${NC}"
          fi
          echo ""
      }

      check_theme_files() {
          echo -e "''${BLUE}📁 Theme Files''${NC}"

          local rosepine_dir="$HOME/.config/Kvantum/RosePine"
          if [[ -d "$rosepine_dir" ]] || [[ -L "$rosepine_dir" ]]; then
              echo -e "''${GREEN}✓ Rose Pine theme directory found''${NC}"
              if [[ -f "$rosepine_dir/rose-pine-rose.kvconfig" ]]; then
                  echo -e "''${GREEN}✓ Rose Pine Kvantum config found''${NC}"
              else
                  echo -e "''${YELLOW}⚠ Rose Pine Kvantum config missing''${NC}"
              fi
          else
              echo -e "''${RED}✗ Rose Pine theme directory missing: $rosepine_dir''${NC}"
          fi
          echo ""
      }

      check_configuration() {
          echo -e "''${BLUE}⚙️ Configuration Files''${NC}"

          # Check kdeglobals (critical for KDE apps)
          if [[ -f "$HOME/.config/kdeglobals" ]]; then
              if grep -q "ColorScheme=Rose-Pine-Main-BL" "$HOME/.config/kdeglobals" 2>/dev/null; then
                  echo -e "''${GREEN}✓ kdeglobals: Rose Pine configured''${NC}"
              else
                  echo -e "''${YELLOW}⚠ kdeglobals: exists but may not be Rose Pine''${NC}"
              fi
          else
              echo -e "''${RED}✗ kdeglobals: missing''${NC}"
          fi

          # Check Kvantum config
          if [[ -f "$HOME/.config/Kvantum/kvantum.kvconfig" ]]; then
              if grep -q "theme=rose-pine-rose" "$HOME/.config/Kvantum/kvantum.kvconfig" 2>/dev/null; then
                  echo -e "''${GREEN}✓ Kvantum: Rose Pine configured''${NC}"
              else
                  echo -e "''${YELLOW}⚠ Kvantum: exists but theme may not be Rose Pine''${NC}"
              fi
          else
              echo -e "''${RED}✗ Kvantum config: missing''${NC}"
          fi

          # Check Qt6ct config
          if [[ -f "$HOME/.config/qt6ct/qt6ct.conf" ]]; then
              if grep -q "style=kvantum" "$HOME/.config/qt6ct/qt6ct.conf" 2>/dev/null; then
                  echo -e "''${GREEN}✓ Qt6ct: Kvantum style configured''${NC}"
              else
                  echo -e "''${YELLOW}⚠ Qt6ct: exists but style may not be Kvantum''${NC}"
              fi
          else
              echo -e "''${RED}✗ Qt6ct config: missing''${NC}"
          fi
          echo ""
      }

      test_applications() {
          echo -e "''${BLUE}🚀 Test Applications''${NC}"

          if command -v dolphin &> /dev/null; then
              echo -e "''${GREEN}✓ Dolphin available''${NC}"
              echo -e "''${YELLOW}  → Run 'dolphin' to test theming''${NC}"
          else
              echo -e "''${RED}✗ Dolphin not found''${NC}"
          fi

          if command -v kvantummanager &> /dev/null; then
              echo -e "''${GREEN}✓ Kvantum Manager available''${NC}"
              echo -e "''${YELLOW}  → Run 'kvantummanager' for theme management''${NC}"
          else
              echo -e "''${YELLOW}⚠ Kvantum Manager not found''${NC}"
          fi

          if command -v qt6ct &> /dev/null; then
              echo -e "''${GREEN}✓ Qt6ct available''${NC}"
              echo -e "''${YELLOW}  → Run 'qt6ct' for Qt configuration''${NC}"
          else
              echo -e "''${YELLOW}⚠ Qt6ct not found''${NC}"
          fi
          echo ""
      }

      show_troubleshooting() {
          echo -e "''${BLUE}🔧 Troubleshooting Tips''${NC}"
          echo ""
          echo -e "''${YELLOW}If theming is not working:''${NC}"
          echo "1. Restart applications: pkill dolphin && dolphin &"
          echo "2. Logout and login to reload environment variables"
          echo "3. Restart Hyprland session"
          echo "4. Rebuild Home Manager: home-manager switch"
          echo ""
          echo -e "''${YELLOW}Manual theme tools:''${NC}"
          echo "• kvantummanager - Kvantum theme manager"
          echo "• qt6ct - Qt6 configuration tool"
          echo "• nwg-look - GTK theme configuration"
          echo ""
      }

      print_summary() {
          echo -e "''${PURPLE}📋 Summary''${NC}"
          echo ""
          echo "Your system is configured for Rose Pine theming with:"
          echo "• Rose Pine GTK theme (Rose-Pine-Main-BL) for GTK applications"
          echo "• Rose Pine Kvantum theme for Qt applications"
          echo "• KDE kdeglobals for Dolphin and KDE apps"
          echo "• Qt6ct for Qt6 application theming"
          echo "• Fcitx5 Rose Pine theme for input method"
          echo ""
          echo -e "''${GREEN}🎨 Enjoy your Rose Pine themed desktop!''${NC}"
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

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🔧 SYSTEM SERVICES - BACKGROUND FUNCTIONALITY
  # ═══════════════════════════════════════════════════════════════════════════════
  # These services provide essential background functionality for the desktop environment.
  # They handle media control, storage management, audio effects, and AI services.

  services = {
    # ─── MEDIA CONTROL SERVICES ───
    # These services provide D-Bus interfaces for media player control
    playerctld.enable = true;          # D-Bus interface for media players (playerctl)
    mpris-proxy.enable = true;         # MPRIS proxy for media player integration

    # ─── STORAGE MANAGEMENT ───
    # Automatic mounting and management of removable storage devices
    udiskie.enable = true;             # Automount USB drives, SD cards, etc.

    # ─── AUDIO EFFECTS ───
    # PipeWire audio effects processing
    easyeffects.enable = true;         # Audio effects for PipeWire (equalizer, etc.)

    # ─── CLIPBOARD MANAGEMENT ───
    # Clipboard history and management
    cliphist.enable = true;            # Clipboard history manager for Wayland

    # ─── AI/ML SERVICES ───
    # Local AI model serving with hardware acceleration
    ollama = {
      enable = true;
      acceleration = "rocm";           # Enable ROCm acceleration for AMD GPUs
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # 📦 INSTALLED PACKAGES - COMPREHENSIVE SOFTWARE SUITE
  # ═══════════════════════════════════════════════════════════════════════════════
  # This is the complete list of packages installed for the user environment.
  # Packages are organized by category and include all dependencies for our
  # Rose Pine themed desktop environment.
  #
  # DEPENDENCY RELATIONSHIPS:
  # • Theme packages provide visual consistency across all applications
  # • Development tools support the NixOS workflow
  # • Media tools handle various file formats with proper theming
  # • System utilities integrate with Hyprland and Wayland

  home.packages = with pkgs; [
    # ─── CORE DESKTOP APPLICATIONS ───
    kitty                              # Terminal emulator (configured above)
    fuzzel                             # Application launcher (configured above)
    micro                              # Text editor (configured below)

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

    # ─── FONTS ───
    nerd-fonts.jetbrains-mono          # Programming font with icons (used in Kitty)
    nerd-fonts.caskaydia-cove          # Alternative programming font
    nerd-fonts.fantasque-sans-mono     # Another programming font option
    noto-fonts                         # Comprehensive Unicode support
    noto-fonts-cjk-sans               # CJK (Chinese/Japanese/Korean) support
    noto-fonts-emoji                   # Emoji support
    font-awesome                       # Icon font

    # ─── FILE MANAGERS ───
    kdePackages.dolphin                # Primary file manager (KDE, themed via kdeglobals)
    nautilus                           # GNOME file manager (backup)
    nemo                               # Cinnamon file manager (configured below)

    # ─── MEDIA APPLICATIONS ───
    mpv                                # Video player (used in MIME associations)
    audacious                          # Audio player
    audacious-plugins                  # Audio player plugins
    kdePackages.gwenview               # Image viewer (used in MIME associations)
    kdePackages.okular                 # PDF viewer (used in MIME associations)

    # ─── ARCHIVE MANAGEMENT ───
    kdePackages.ark                    # Archive manager (used in MIME associations)

    # ─── WEB BROWSER ───
    inputs.zen-browser.packages."${system}".default # Zen browser (flake input)

    # ─── DEVELOPMENT TOOLS ───
    git-lfs                            # Git Large File Storage
    jq                                 # JSON processor (used in screenshot scripts)
    tree                               # Directory tree display
    eza                                # Modern ls replacement (used in fish abbrs)
    starship                           # Shell prompt (configured above)

    # ─── SCREENSHOT AND GRAPHICS TOOLS ───
    grim                               # Wayland screenshot utility (used in scripts)
    slurp                              # Region selection for screenshots (used in scripts)
    wl-clipboard                       # Wayland clipboard utilities (used in scripts)
    swappy                             # Screenshot annotation tool
    satty                              # Another screenshot annotation tool
    hyprpicker                         # Color picker for Hyprland

    # ─── HYPRLAND ECOSYSTEM ───
    hyprpolkitagent                    # Polkit agent for Hyprland
    hyprutils                          # Hyprland utilities
    hyprshade                          # Screen shader manager (used in screenshot scripts)
    hyprpanel                          # Panel for Hyprland

    # ─── GAMING AND PERFORMANCE ───
    mangohud                           # Gaming performance overlay (configured above)
    goverlay                           # MangoHud configuration GUI
    obs-studio                         # Screen recording and streaming
    lutris                             # Gaming platform
    osu-lazer-bin                      # Rhythm game

    # ─── AUDIO CONTROL ───
    pavucontrol                        # PulseAudio volume control GUI
    playerctl                          # Media player control (used by services)

    # ─── SYSTEM MONITORING ───
    btop-rocm                          # System monitor with ROCm support
    glances                            # System monitor

    # ─── HARDWARE CONTROL ───
    ddcui                              # Display configuration utility
    openrgb-with-all-plugins           # RGB lighting control

    # ─── MOBILE AND ANDROID TOOLS ───
    universal-android-debloater        # Android debloating tool
    android-tools                      # ADB and other Android utilities
    scrcpy                             # Android screen mirroring

    # ─── EMBEDDED SYSTEMS TOOLS ───
    sunxi-tools                        # Tools for Allwinner SoCs
    binwalk                            # Firmware analysis tool
    vboot_reference                    # ChromeOS bootloader tools

    # ─── SYSTEM UTILITIES ───
    pv                                 # Progress viewer
    parted                             # Partition management
    squashfsTools                      # SquashFS utilities
    nixos-install-tools                # NixOS installation utilities
    nixos-generators                   # NixOS image generators

    # ─── NETWORKING AND SHARING ───
    localsend                          # Local file sharing
    zrok                               # Zero-trust networking
    vesktop                            # Discord client with better Wayland support

    # ─── PRODUCTIVITY APPLICATIONS ───
    keepassxc                          # Password manager
    zed-editor_git                     # Modern text editor

    # ─── ENTERTAINMENT ───
    mangayomi                          # Manga reader

    # ─── AI/ML TOOLS ───
    ollama-rocm                        # Local AI models with ROCm acceleration (used by service)

    # ─── THUMBNAIL GENERATION ───
    # These packages enable thumbnail generation for various file types in file managers
    ffmpegthumbnailer                  # Video thumbnails
    poppler_utils                      # PDF thumbnails
    libgsf                             # Office document thumbnails
    webp-pixbuf-loader                 # WebP image support
    kdePackages.kdegraphics-thumbnailers # KDE thumbnail generators
    kdePackages.kimageformats          # Additional image format support
    kdePackages.kio-extras             # KDE I/O plugins

    # ─── ADDITIONAL THEME PACKAGES ───
    # These provide alternative themes and ensure broad compatibility
    catppuccin-gtk                     # Alternative theme option
    catppuccin-cursors                 # Alternative cursor theme
    papirus-icon-theme                 # Icon theme (used throughout config)
    adwaita-icon-theme                 # Fallback icon theme

    # ─── SYSTEM INTEGRATION ───
    polkit_gnome                       # GNOME polkit agent (used by systemd service)
    gsettings-desktop-schemas          # GSettings schemas for desktop integration
    libnotify                          # Desktop notifications (used in screenshot scripts)
    zenity                             # Dialog boxes for scripts

    # ─── UTILITIES ───
    fastfetch                          # System information display
  ];

  # ═══════════════════════════════════════════════════════════════════════════════
  # 📁 FILE MANAGER INTEGRATION - BOOKMARKS AND CONTEXT MENUS
  # ═══════════════════════════════════════════════════════════════════════════════
  # These configurations provide seamless file manager integration with bookmarks,
  # context menus, and proper application associations.

  # ─── GTK FILE MANAGER BOOKMARKS ───
  # Standard bookmarks for GTK file managers (Nautilus, Nemo)
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

  # ─── DOLPHIN FILE MANAGER BOOKMARKS ───
  # KDE Dolphin uses XBEL format for bookmarks
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

  # ─── DOLPHIN CONFIGURATION ───
  # Comprehensive Dolphin configuration with enhanced thumbnails and Rose Pine integration
  home.file.".config/dolphinrc".text = ''
    [General]
    BrowseThroughArchives=true          # Browse inside archive files
    EditableUrl=false                   # Use breadcrumb navigation
    GlobalViewProps=false               # Use folder-specific view properties
    HomeUrl=file:///home/${config.home.username}  # Set home directory
    ModifiedStartupSettings=true        # Enable custom startup settings
    OpenExternallyCalledFolderInNewTab=false      # Open folders in current tab
    RememberOpenedTabs=true             # Remember tabs between sessions
    ShowFullPath=false                  # Show breadcrumb instead of full path
    ShowFullPathInTitlebar=false        # Don't show full path in title
    ShowSpaceInfo=false                 # Don't show disk space in status bar
    ShowZoomSlider=true                 # Show zoom controls
    SortingChoice=CaseSensitiveSorting  # Case-sensitive sorting
    SplitView=false                     # Single pane view
    UseTabForSwitchingSplitView=false   # Don't use tab for split view
    Version=202                         # Configuration version
    ViewPropsTimestamp=2024,1,1,0,0,0   # Timestamp for view properties

    [KFileDialog Settings]
    Places Icons Auto-resize=false      # Fixed icon size in places panel
    Places Icons Static Size=22         # Icon size in places panel

    [MainWindow]
    MenuBar=Disabled                    # Hide menu bar for cleaner look
    ToolBarsMovable=Disabled            # Prevent toolbar rearrangement

    [PlacesPanel]
    IconSize=22                         # Consistent icon size

    [PreviewSettings]
    # Enable comprehensive thumbnail support for all supported file types
    Plugins=appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,textthumbnail,ffmpegthumbs
    MaximumSize=10485760                # 10MB limit for thumbnail generation
    EnableRemoteFolderThumbnail=false   # Disable remote thumbnails for security
    MaximumRemoteSize=0                 # No remote thumbnail size limit

    # View-specific thumbnail sizes
    [DesktopIcons]
    Size=48

    [CompactMode]
    PreviewSize=32

    [DetailsMode]
    PreviewSize=32

    [IconsMode]
    PreviewSize=64
  '';

  # ─── KDE SERVICE MENU FOR TERMINAL INTEGRATION ───
  # Adds "Open Terminal Here" to Dolphin context menu
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

  # ─── SYNCTHING DIRECTORY CREATION ───
  # Automatically create syncthing-shared directory on activation
  home.activation.createSyncthingDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/syncthing-shared
  '';

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🖥️ DESKTOP APPLICATION INTEGRATION
  # ═══════════════════════════════════════════════════════════════════════════════
  # Custom .desktop files for better application integration and MIME type handling.

  # ─── KITTY DESKTOP FILE ───
  # Enhanced desktop file for Kitty terminal with proper MIME associations
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

  # ─── MICRO EDITOR DESKTOP FILE ───
  # Desktop file for Micro text editor with comprehensive MIME type support
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

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🗂️ NEMO FILE MANAGER CONFIGURATION
  # ═══════════════════════════════════════════════════════════════════════════════
  # Alternative file manager configuration with Rose Pine theming and Kitty integration.

  home.file.".config/nemo/nemo.conf".text = ''
    [preferences]
    default-folder-viewer=list-view      # Default to list view
    show-hidden-files=false              # Hide hidden files by default
    show-location-entry=false            # Use breadcrumb navigation
    start-with-dual-pane=false           # Single pane mode
    inherit-folder-viewer=true           # Inherit view settings
    ignore-view-metadata=false           # Use view metadata
    default-sort-order=name              # Sort by name
    default-sort-type=ascending          # Ascending sort
    size-prefixes=base-10                # Use decimal size prefixes (GB not GiB)
    quick-renames-with-pause-in-between=true  # Enable quick rename
    show-compact-view-icon-toolbar=false      # Hide icon toolbar in compact view
    show-compact-view-icon-toolbar-icons-small=false
    show-compact-view-text-beside-icons=false
    show-full-path-titles=true           # Show full path in title
    show-new-folder-icon-toolbar=true    # Show new folder button
    show-open-in-terminal-toolbar=true   # Show terminal button
    show-reload-icon-toolbar=true        # Show reload button
    show-search-icon-toolbar=true        # Show search button
    show-edit-icon-toolbar=false         # Hide edit button
    show-home-icon-toolbar=true          # Show home button
    show-computer-icon-toolbar=false     # Hide computer button
    show-up-icon-toolbar=true            # Show up button
    terminal-command=kitty               # Use Kitty as terminal (matches our config)
    close-device-view-on-device-eject=true    # Close tabs when device ejected
    thumbnail-limit=10485760             # 10MB thumbnail limit
    executable-text-activation=ask       # Ask before executing text files
    show-image-thumbnails=true           # Show image thumbnails
    show-thumbnails=true                 # Show all thumbnails

    [window-state]
    geometry=800x600+0+0                 # Default window size and position
    maximized=false                      # Don't start maximized
    sidebar-width=200                    # Sidebar width
    start-with-sidebar=true              # Show sidebar by default
    start-with-status-bar=true           # Show status bar
    start-with-toolbar=true              # Show toolbar
    sidebar-bookmark-breakpoint=5        # Bookmark breakpoint

    # View-specific settings
    [list-view]
    default-zoom-level=standard
    default-visible-columns=name,size,type,date_modified
    default-column-order=name,size,type,date_modified

    [icon-view]
    default-zoom-level=standard

    [compact-view]
    default-zoom-level=standard
  '';

  # ─── NEMO CONTEXT MENU ACTIONS ───
  # Custom actions for Nemo's right-click context menu

  # Action to open terminal in current directory
  home.file.".local/share/nemo/actions/open-in-kitty.nemo_action".text = ''
    [Nemo Action]
    Name=Open in Terminal
    Comment=Open a terminal in this location
    Exec=kitty --working-directory %f
    Icon-Name=utilities-terminal
    Selection=None
    Extensions=dir;
  '';

  # Action to edit files as root using our configured editor
  home.file.".local/share/nemo/actions/edit-as-root.nemo_action".text = ''
    [Nemo Action]
    Name=Edit as Root
    Comment=Edit this file with root privileges
    Exec=pkexec micro %F
    Icon-Name=accessories-text-editor
    Selection=S
    Extensions=any;
  '';

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🖼️ THUMBNAIL MANAGEMENT
  # ═══════════════════════════════════════════════════════════════════════════════
  # Utilities for managing thumbnail cache and ensuring proper thumbnail generation.

  # ─── THUMBNAIL CACHE UPDATE SCRIPT ───
  # Script to clear and regenerate thumbnail cache
  home.file.".local/bin/update-thumbnails".text = ''
    #!/usr/bin/env bash

    # Thumbnail Cache Management Script
    # Clears thumbnail cache and triggers regeneration for better file manager performance
    #
    # FEATURES:
    # - Clears existing thumbnail cache
    # - Updates desktop and MIME databases
    # - Triggers thumbnail regeneration for common directories

    # Clear existing thumbnail cache
    rm -rf ~/.cache/thumbnails/*

    # Update desktop database for .desktop files
    update-desktop-database ~/.local/share/applications 2>/dev/null || true

    # Update MIME database for file associations
    update-mime-database ~/.local/share/mime 2>/dev/null || true

    # Regenerate thumbnails for common directories by touching files
    # This forces thumbnail generators to recreate thumbnails
    find ~/Pictures ~/Downloads ~/Videos ~/Music -type f \( \
      -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o \
      -name "*.webp" -o -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" \
    \) -exec touch {} \; 2>/dev/null || true

    echo "Thumbnail cache cleared and databases updated"
  '';

  home.file.".local/bin/update-thumbnails".executable = true;

  # ─── KDE SERVICE MENU FOR TERMINAL ───
  # Additional service menu for KDE applications
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

  # ═══════════════════════════════════════════════════════════════════════════════
  # ✏️ MICRO TEXT EDITOR CONFIGURATION
  # ═══════════════════════════════════════════════════════════════════════════════
  # Micro is our primary text editor, configured with Rose Pine theme and
  # optimized settings for development and general text editing.

  programs.micro = {
    enable = true;
    settings = {
      # ─── THEME AND APPEARANCE ───
      colorscheme = "rose-pine";         # Use our custom Rose Pine colorscheme
      cursorline = true;                 # Highlight current line
      scrollbar = true;                  # Show scrollbar
      statusline = true;                 # Show status line
      syntax = true;                     # Enable syntax highlighting

      # ─── FILE MANAGEMENT ───
      mkparents = true;                  # Create parent directories when saving
      autosave = 5;                      # Auto-save every 5 seconds

      # ─── EDITING BEHAVIOR ───
      softwrap = true;                   # Soft word wrapping
      wordwrap = true;                   # Enable word wrapping
      tabsize = 4;                       # 4-space tabs
      tabstospaces = true;               # Convert tabs to spaces
      autoclose = true;                  # Auto-close brackets and quotes
      autoindent = true;                 # Automatic indentation
      smartpaste = true;                 # Smart paste behavior

      # ─── SEARCH AND NAVIGATION ───
      ignorecase = true;                 # Case-insensitive search by default
      diffgutter = true;                 # Show diff information in gutter

      # ─── SYSTEM INTEGRATION ───
      clipboard = "terminal";            # Use terminal clipboard integration
    };
  };

  # ─── THUMBNAIL UPDATE SERVICE ───
  # Systemd user service to update thumbnails on login
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

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🌐 ADDITIONAL ENVIRONMENT VARIABLES - FINAL INTEGRATION SETTINGS
  # ═══════════════════════════════════════════════════════════════════════════════
  # These additional environment variables ensure proper integration between
  # all components of our desktop environment.

  home.sessionVariables = {
    # ─── APPLICATION DEFAULTS ───
    TERMINAL = "kitty";                  # Default terminal (used by applications)
    FILE_MANAGER = "dolphin";            # Default file manager

    # ─── COMPATIBILITY SETTINGS ───
    WEBKIT_DISABLE_COMPOSITING_MODE = "1"; # Fix WebKit rendering issues
  };
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🎉 CONFIGURATION COMPLETE
# ═══════════════════════════════════════════════════════════════════════════════
# This comprehensive Home Manager configuration provides:
#
# 🎨 THEMING:
# • Consistent Rose Pine theme across GTK, Qt, terminal, and all applications
# • Custom cursor theme integrated with Hyprland
# • Font configuration with Japanese support
#
# 🚀 APPLICATIONS:
# • Kitty terminal with Fish shell and Starship prompt
# • Fuzzel application launcher with Rose Pine theming
# • Comprehensive file manager setup (Dolphin, Nemo, Nautilus)
# • Development tools (Git, text editors, system utilities)
#
# 🔧 SYSTEM INTEGRATION:
# • Wayland-native screenshot tools with Hyprshade integration
# • MIME type associations for seamless file handling
# • Input method support for Japanese with themed interface
# • Background services for media, clipboard, and AI functionality
#
# 📦 PACKAGE MANAGEMENT:
# • Over 100 carefully selected packages for a complete desktop experience
# • Gaming support with MangoHud and performance tools
# • Development tools and utilities
# • Multimedia applications with proper theming
#
# 🛠️ WORKFLOW OPTIMIZATION:
# • Custom Fish shell functions and abbreviations for NixOS management
# • Automated thumbnail generation and cache management
# • Context menu integration for file managers
# • Comprehensive diagnostic tools for troubleshooting
#
# To rebuild this configuration:
# 1. git add . (in nixos-config directory)
# 2. nix build --dry-run .#nixosConfigurations.popcat19-nixos0
# 3. nixos-apply-config -m "updated home.nix with comprehensive comments"
#
# For troubleshooting: run 'check-rose-pine-theme' script
