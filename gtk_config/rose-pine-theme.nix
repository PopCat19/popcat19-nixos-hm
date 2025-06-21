{ config, lib, pkgs, ... }:

{
  # GTK Theme Configuration - Using existing Rosepine-Dark theme
  gtk = {
    enable = true;

    # Use the existing Rosepine-Dark theme that's already available
    theme = {
      name = "Rosepine-Dark";
    };

    # Icon theme - Papirus with dark variant
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    # Cursor theme
    cursorTheme = {
      name = "Adwaita";
      size = 24;
      package = pkgs.adwaita-icon-theme;
    };

    # Font configuration
    font = {
      name = "CaskaydiaCove Nerd Font";
      size = 11;
    };

    # GTK2 configuration
    gtk2.extraConfig = ''
      gtk-theme-name="Rosepine-Dark"
      gtk-icon-theme-name="Papirus-Dark"
      gtk-font-name="CaskaydiaCove Nerd Font 11"
      gtk-cursor-theme-name="Adwaita"
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
  };

  # QT Theme Configuration
  qt = {
    enable = true;
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
    platformTheme = "gnome";
  };

  # Additional theming packages
  home.packages = with pkgs; [
    # GTK theme tools
    gtk3
    gtk4
    glib
    gsettings-desktop-schemas
    nwg-look

    # Icon themes
    adwaita-icon-theme
    papirus-icon-theme

    # Qt theming
    adwaita-qt
    qt5.qttools
    qt6Packages.qt6ct

    # Additional utilities
    dconf-editor
  ];

  # GTK bookmarks for file manager
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
        "gtk-theme": "Rosepine-Dark",
        "icon-theme": "Papirus-Dark",
        "cursor-theme": "Adwaita",
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
      Net/ThemeName "Rosepine-Dark"
      Net/IconThemeName "Papirus-Dark"
      Gtk/CursorThemeName "Adwaita"
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
      gtk-theme = "Rosepine-Dark";
      icon-theme = "Papirus-Dark";
      cursor-theme = "Adwaita";
      cursor-size = 24;
      font-name = "CaskaydiaCove Nerd Font 11";
      color-scheme = "prefer-dark";
      enable-animations = true;
      gtk-enable-primary-paste = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      theme = "Rosepine-Dark";
    };

    "org/gtk/settings/file-chooser" = {
      sort-directories-first = true;
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 170;
      window-position = lib.hm.gvariant.mkTuple [ 300 300 ];
      window-size = lib.hm.gvariant.mkTuple [ 1000 600 ];
    };
  };

  # Session variables for consistent theming
  home.sessionVariables = {
    # GTK theming
    GTK_THEME = "Rosepine-Dark";
    GTK2_RC_FILES = "${config.home.homeDirectory}/.gtkrc-2.0";

    # Qt theming
    QT_STYLE_OVERRIDE = "adwaita-dark";
    QT_QPA_PLATFORMTHEME = "gnome";

    # Cursor theming
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";

    # General theming
    GDK_BACKEND = "wayland,x11,*";
  };
}
