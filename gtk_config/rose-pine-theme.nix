{ config, lib, pkgs, inputs, system, ... }:

{
  # Comprehensive Rose Pine GTK Theme Configuration
  # This module provides complete Rose Pine theming for GTK applications
  # inspired by hydenix's theming approach

  # GTK Theme Configuration - Rose Pine themed
  gtk = {
    enable = true;

    # Cursor theme with Rose Pine hyprcursor
    cursorTheme = {
      name = "rose-pine-hyprcursor";
      size = 24;
      package = inputs.rose-pine-hyprcursor.packages.${system}.default;
    };

    # Main GTK theme
    theme = {
      name = "rose-pine-gtk-theme";
      package = pkgs.rose-pine-gtk-theme;
    };

    # Icon theme - Papirus with dark variant
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    # Font configuration
    font = {
      name = "CaskaydiaCove Nerd Font";
      size = 11;
    };

    # GTK2 configuration
    gtk2.extraConfig = ''
      gtk-theme-name="rose-pine-gtk-theme"
      gtk-icon-theme-name="Papirus-Dark"
      gtk-font-name="CaskaydiaCove Nerd Font 11"
      gtk-cursor-theme-name="rose-pine-hyprcursor"
      gtk-cursor-theme-size=24
      gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
      gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
      gtk-button-images=0
      gtk-menu-images=0
      gtk-enable-event-sounds=1
      gtk-enable-input-feedback-sounds=0
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintslight"
      gtk-xft-rgba="rgb"
    '';

    # GTK3 specific settings
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-decoration-layout = "appmenu:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-primary-button-warps-slider = false;
      gtk-toolbar-style = "GTK_TOOLBAR_BOTH_HORIZ";
      gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
      gtk-button-images = false;
      gtk-menu-images = false;
      gtk-enable-event-sounds = true;
      gtk-enable-input-feedback-sounds = false;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };

    # GTK4 specific settings
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-decoration-layout = "appmenu:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-primary-button-warps-slider = false;
    };

    # GTK3 CSS customizations for Rose Pine
    gtk3.extraCss = ''
      /* Rose Pine GTK3 Customizations */
      @define-color rose_pine_base #191724;
      @define-color rose_pine_surface #1f1d2e;
      @define-color rose_pine_overlay #26233a;
      @define-color rose_pine_muted #6e6a86;
      @define-color rose_pine_subtle #908caa;
      @define-color rose_pine_text #e0def4;
      @define-color rose_pine_love #eb6f92;
      @define-color rose_pine_gold #f6c177;
      @define-color rose_pine_rose #ebbcba;
      @define-color rose_pine_pine #31748f;
      @define-color rose_pine_foam #9ccfd8;
      @define-color rose_pine_iris #c4a7e7;

      /* Window decorations */
      .titlebar {
        background: @rose_pine_surface;
        color: @rose_pine_text;
      }

      /* Buttons */
      button {
        background: @rose_pine_overlay;
        color: @rose_pine_text;
        border: 1px solid @rose_pine_muted;
      }

      button:hover {
        background: @rose_pine_muted;
        color: @rose_pine_text;
      }

      button:active {
        background: @rose_pine_love;
        color: @rose_pine_base;
      }

      /* Entry fields */
      entry {
        background: @rose_pine_surface;
        color: @rose_pine_text;
        border: 1px solid @rose_pine_muted;
      }

      entry:focus {
        border-color: @rose_pine_foam;
      }

      /* Scrollbars */
      scrollbar {
        background: @rose_pine_overlay;
      }

      scrollbar slider {
        background: @rose_pine_muted;
        border-radius: 8px;
      }

      scrollbar slider:hover {
        background: @rose_pine_subtle;
      }
    '';

    # GTK4 CSS customizations for Rose Pine
    gtk4.extraCss = ''
      /* Rose Pine GTK4 Customizations */
      @define-color rose_pine_base #191724;
      @define-color rose_pine_surface #1f1d2e;
      @define-color rose_pine_overlay #26233a;
      @define-color rose_pine_muted #6e6a86;
      @define-color rose_pine_subtle #908caa;
      @define-color rose_pine_text #e0def4;
      @define-color rose_pine_love #eb6f92;
      @define-color rose_pine_gold #f6c177;
      @define-color rose_pine_rose #ebbcba;
      @define-color rose_pine_pine #31748f;
      @define-color rose_pine_foam #9ccfd8;
      @define-color rose_pine_iris #c4a7e7;

      /* Window styling */
      window {
        background: @rose_pine_base;
        color: @rose_pine_text;
      }

      /* Header bars */
      headerbar {
        background: @rose_pine_surface;
        color: @rose_pine_text;
      }

      /* Buttons */
      button {
        background: @rose_pine_overlay;
        color: @rose_pine_text;
        border: 1px solid @rose_pine_muted;
        border-radius: 6px;
      }

      button:hover {
        background: @rose_pine_muted;
      }

      button:active {
        background: @rose_pine_love;
        color: @rose_pine_base;
      }

      /* Entry fields */
      entry {
        background: @rose_pine_surface;
        color: @rose_pine_text;
        border: 1px solid @rose_pine_muted;
        border-radius: 6px;
      }

      entry:focus {
        border-color: @rose_pine_foam;
        box-shadow: 0 0 0 2px alpha(@rose_pine_foam, 0.3);
      }
    '';
  };

  # QT Theme Configuration - Rose Pine themed
  qt = {
    enable = true;
    style = {
      name = "kvantum";
      package = pkgs.libsForQt5.qtstyleplugin-kvantum;
    };
  };

  # Additional theming packages
  home.packages = with pkgs; [
    # GTK theme tools
    gtk3
    gtk4
    glib
    gsettings-desktop-schemas
    gnome-settings-daemon
    nwg-look

    # Icon and cursor themes
    adwaita-icon-theme
    papirus-icon-theme
    rose-pine-gtk-theme

    # Qt theming
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
    rose-pine-kvantum

    # Additional utilities
    dconf-editor
    gnome-tweaks
  ];

  # Kvantum theme configuration
  home.file.".config/Kvantum/RosePine".source = "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/rose-pine-rose";

  # Kvantum configuration with application-specific overrides
  home.file.".config/Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=rose-pine-rose

    [Applications]
    dolphin=rose-pine-rose
    ark=rose-pine-rose
    gwenview=rose-pine-rose
    systemsettings=rose-pine-rose
    kate=rose-pine-rose
    kwrite=rose-pine-rose
    konsole=rose-pine-rose
    yakuake=rose-pine-rose
    okular=rose-pine-rose
    spectacle=rose-pine-rose
    kdeconnect-app=rose-pine-rose
    plasma-systemmonitor=rose-pine-rose
  '';

  # Critical: kdeglobals configuration for KDE applications
  home.file.".config/kdeglobals" = {
    text = ''
      [ColorScheme]
      Name=RosePine

      [Colors:Button]
      BackgroundAlternate=49,46,77
      BackgroundNormal=49,46,77
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=224,222,244
      ForegroundInactive=144,140,170
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [Colors:Selection]
      BackgroundAlternate=156,207,216
      BackgroundNormal=156,207,216
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=25,23,36
      ForegroundInactive=25,23,36
      ForegroundLink=25,23,36
      ForegroundNegative=25,23,36
      ForegroundNeutral=25,23,36
      ForegroundNormal=25,23,36
      ForegroundPositive=25,23,36
      ForegroundVisited=25,23,36

      [Colors:Tooltip]
      BackgroundAlternate=31,29,46
      BackgroundNormal=31,29,46
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=224,222,244
      ForegroundInactive=144,140,170
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [Colors:View]
      BackgroundAlternate=31,29,46
      BackgroundNormal=25,23,36
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=224,222,244
      ForegroundInactive=110,106,134
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [Colors:Window]
      BackgroundAlternate=31,29,46
      BackgroundNormal=25,23,36
      DecorationFocus=156,207,216
      DecorationHover=156,207,216
      ForegroundActive=224,222,244
      ForegroundInactive=144,140,170
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [General]
      ColorScheme=RosePine
      Name=Rose Pine
      shadeSortColumn=true

      [KDE]
      contrast=4

      [WM]
      activeBackground=49,46,77
      activeForeground=224,222,244
      inactiveBackground=38,35,58
      inactiveForeground=144,140,170
    '';
    force = true;
    mutable = true;
  };

  # GTK bookmarks for file manager (with Rose Pine friendly paths)
  home.file.".config/gtk-3.0/bookmarks".text = ''
    file:///home/${config.home.username}/Documents Documents
    file:///home/${config.home.username}/Downloads Downloads
    file:///home/${config.home.username}/Pictures Pictures
    file:///home/${config.home.username}/Videos Videos
    file:///home/${config.home.username}/Music Music
    file:///home/${config.home.username}/nixos-config NixOS Config
  '';

  # nwg-look configuration for GTK theme management
  home.file.".config/nwg-look/config" = {
    text = ''
      {
        "gtk-theme": "rose-pine-gtk-theme",
        "icon-theme": "Papirus-Dark",
        "cursor-theme": "rose-pine-hyprcursor",
        "cursor-size": 24,
        "font-name": "CaskaydiaCove Nerd Font 11",
        "prefer-dark": true,
        "toolbar-style": "both-horiz",
        "toolbar-icon-size": "large",
        "button-images": false,
        "menu-images": false,
        "event-sounds": true,
        "input-feedback-sounds": false,
        "enable-animations": true,
        "primary-button-warps-slider": false
      }
    '';
    force = true;
    mutable = true;
  };

  # X11 settings daemon configuration for legacy applications
  home.file.".config/xsettingsd/xsettingsd.conf" = {
    text = ''
      Net/ThemeName "rose-pine-gtk-theme"
      Net/IconThemeName "Papirus-Dark"
      Gtk/CursorThemeName "rose-pine-hyprcursor"
      Gtk/CursorThemeSize 24
      Net/SoundThemeName "default"
      Net/EnableEventSounds 1
      Net/EnableInputFeedbackSounds 0
      Xft/Antialias 1
      Xft/Hinting 1
      Xft/HintStyle "hintslight"
      Xft/RGBA "rgb"
      Net/DndDragThreshold 8
      Gtk/CanChangeAccels 0
      Gtk/ColorPalette "black:dark gray:gray:light gray:white:red:green:blue:yellow:magenta:cyan:orange:brown:pink:purple:khaki"
      Gtk/FontName "CaskaydiaCove Nerd Font 11"
      Gtk/KeyThemeName "Default"
      Gtk/ToolbarStyle "both-horiz"
      Gtk/ToolbarIconSize "large-toolbar"
      Gtk/IMPreeditStyle "callback"
      Gtk/IMStatusStyle "callback"
      Gtk/MenuImages 0
      Gtk/ButtonImages 0
      Gtk/MenuBarAccel "F10"
      Gtk/EnableAnimations 1
      Gtk/DialogsUseHeader 1
      Gtk/PrimaryButtonWarpsSlider 0
      Gtk/RecentFilesMaxAge 30
      Gtk/RecentFilesEnabled 1
    '';
    force = true;
    mutable = true;
  };

  # GSettings (dconf) configuration for GTK applications
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "rose-pine-gtk-theme";
      icon-theme = "Papirus-Dark";
      cursor-theme = "rose-pine-hyprcursor";
      cursor-size = 24;
      font-name = "CaskaydiaCove Nerd Font 11";
      color-scheme = "prefer-dark";
      enable-animations = true;
      gtk-enable-primary-paste = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      theme = "rose-pine-gtk-theme";
    };

    "org/gtk/settings/file-chooser" = {
      sort-directories-first = true;
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 170;
      window-position = mkTuple [ 300 300 ];
      window-size = mkTuple [ 1000 600 ];
    };
  };

  # Session variables for consistent theming
  home.sessionVariables = {
    # GTK theming
    GTK_THEME = "rose-pine-gtk-theme";
    GTK2_RC_FILES = "${config.home.homeDirectory}/.gtkrc-2.0";

    # Qt theming
    QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORMTHEME = "qt6ct";

    # Cursor theming
    XCURSOR_THEME = "rose-pine-hyprcursor";
    XCURSOR_SIZE = "24";

    # General theming
    GDK_BACKEND = "wayland,x11,*";
  };
}
