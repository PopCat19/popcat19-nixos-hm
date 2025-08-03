{ pkgs, config, system, lib, inputs, ... }:

{
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORM = "wayland;xcb";
    GTK_THEME = "Rose-Pine-Main-BL";
    GDK_BACKEND = "wayland,x11,*";
    XCURSOR_THEME = "rose-pine-hyprcursor";
    XCURSOR_SIZE = "24";
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "rose-pine-hyprcursor";
      size = 24;
      package = inputs.rose-pine-hyprcursor.packages.${system}.default;
    };
    theme = {
      name = "Rose-Pine-Main-BL";
      package = pkgs.rose-pine-gtk-theme-full;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Rounded Mplus 1c Medium";
      size = 11;
    };
    gtk3.extraConfig = {
      gtk-decoration-layout = "appmenu:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-primary-button-warps-slider = false;
    };
    gtk4.extraConfig = {
      gtk-decoration-layout = "appmenu:minimize,maximize,close";
      gtk-enable-animations = true;
      gtk-primary-button-warps-slider = false;
    };
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

  qt = {
    enable = true;
    style = {
      name = "kvantum";
      package = pkgs.kdePackages.qtstyleplugin-kvantum;
    };
  };

  home.file.".config/Kvantum/RosePine".source = "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/rose-pine-rose";

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
  '';

  home.file.".config/kdeglobals" = {
    text = ''
      [ColorScheme]
      Name=Rose-Pine-Main-BL

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
      BackgroundAlternate=82,79,103
      BackgroundNormal=64,61,82
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

      [Colors:Tooltip]
      BackgroundAlternate=25,23,36
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

      [Colors:View]
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

      [Colors:Complementary]
      BackgroundAlternate=49,46,77
      BackgroundNormal=38,35,58
      DecorationFocus=235,188,186
      DecorationHover=235,188,186
      ForegroundActive=224,222,244
      ForegroundInactive=110,106,134
      ForegroundLink=156,207,216
      ForegroundNegative=235,111,146
      ForegroundNeutral=246,193,119
      ForegroundNormal=224,222,244
      ForegroundPositive=156,207,216
      ForegroundVisited=196,167,231

      [General]
      ColorScheme=Rose-Pine-Main-BL
      Name=Rose-Pine-Main-BL
      shadeSortColumn=true

      [Icons]
      Theme=Papirus-Dark

      [KDE]
      contrast=4
      widgetStyle=kvantum
    '';
    force = true;
  };

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

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "rose-pine-hyprcursor";
      cursor-size = 24;
      gtk-theme = "Rose-Pine-Main-BL";
      icon-theme = "Papirus-Dark";
      font-name = "Rounded Mplus 1c Medium 11";
      document-font-name = "Rounded Mplus 1c Medium 11";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
      color-scheme = "prefer-dark";
    };

    "org/gnome/desktop/wm/preferences" = {
      theme = "Rose-Pine-Main-BL";
    };

    "org/gnome/desktop/thumbnailers" = {
      disable-all = false;
    };

    "org/gnome/nautilus/preferences" = {
      show-image-thumbnails = "always";
      thumbnail-limit = 10;
      show-directory-item-counts = "always";
    };

    "org/nemo/preferences" = {
      show-image-thumbnails = true;
      thumbnail-limit = 10;
      show-thumbnails = true;
    };

    "org/gnome/desktop/privacy" = {
      remember-recent-files = true;
      recent-files-max-age = 30;
    };
  };

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



  programs.kitty.font = {
    name = "JetBrainsMono Nerd Font";
    size = 11;
  };

  programs.fuzzel.settings.main.font = "Rounded Mplus 1c Medium:size=14";

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
    google-fonts
    vim
    firefox
    htop
    neofetch
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.fantasque-sans-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    nwg-look
    dconf-editor
    libsForQt5.qt5ct
    qt6ct
    themechanger
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum
    rose-pine-kvantum
    rose-pine-gtk-theme-full
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    catppuccin-gtk
    catppuccin-cursors
    papirus-icon-theme
    adwaita-icon-theme
    polkit_gnome
    gsettings-desktop-schemas
    # TODO: Fix the check-rose-pine-theme script syntax issues
    # For now, we'll comment it out to get the basic configuration working
  ];
}
