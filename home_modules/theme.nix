{ pkgs, config, system, lib, inputs, ... }:

{
    home.sessionVariables = {
    QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORM = "wayland;xcb";
    GTK_THEME = "Rose-Pine-Main-BL";
    GDK_BACKEND = "wayland,x11,*";
    XCURSOR_THEME = "rose-pine-hyprcursor";
    XCURSOR_SIZE = "24";
    # Additional variables for KDE/Qt applications
    QT_QUICK_CONTROLS_STYLE = "Kvantum";
    QT_QUICK_CONTROLS_MATERIAL_THEME = "Dark";
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

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=rose-pine-rose

    [Applications]
    # KDE Applications
    dolphin=rose-pine-rose
    dolphin.exe=rose-pine-rose
    org.kde.dolphin=rose-pine-rose
    ark=rose-pine-rose
    gwenview=rose-pine-rose
    systemsettings=rose-pine-rose
    kate=rose-pine-rose
    kwrite=rose-pine-rose
    okular=rose-pine-rose
    konsole=rose-pine-rose
    kcalc=rose-pine-rose
    kcharselect=rose-pine-rose
    kcolorchooser=rose-pine-rose
    kdf=rose-pine-rose
    keditbookmarks=rose-pine-rose
    kfind=rose-pine-rose
    kgpg=rose-pine-rose
    kleopatra=rose-pine-rose
    klipper=rose-pine-rose
    kmag=rose-pine-rose
    kmousetool=rose-pine-rose
    kmouth=rose-pine-rose
    knotes=rose-pine-rose
    kruler=rose-pine-rose
    ksysguard=rose-pine-rose
    ktimer=rose-pine-rose
    kwalletmanager=rose-pine-rose
    plasma-discover=rose-pine-rose
    spectacle=rose-pine-rose

    # Qt Applications
    qtcreator=rose-pine-rose
    qterminal=rose-pine-rose
    featherpad=rose-pine-rose
    lxqt-config=rose-pine-rose

    # Generic fallbacks
    *=rose-pine-rose
  '';

  # Kvantum theme configuration for better KDE integration
  xdg.configFile."Kvantum/themes/rose-pine-rose.kvconfig".text = ''
    [General]
    author=rose-pine
    comment=Rose Pine theme for Kvantum
    name=rose-pine-rose

    [Hacks]
    align_menuitem_arrows=0
    blur_translucent=0
    centered_forms=0
    combo_menu=0
    compositing=0
    force_size_grip=0
    gtk_menubar_hack=0
    iconless_menu=0
    iconless_pushbutton=0
    kde_globals_following=1
    left_tabs_on_bottom=0
    lock_kde_globals=0
    menu_blur=0
    menu_separator_height=0
    merge_menubar_with_toolbar=0
    no_selection_inactive=0
    opaque_resize_grip=0
    respect_darkness=1
    scroll_jump_workaround=0
    scroll_minimal=0
    scrollbar_in_view=0
    submenu_overlap=0
    tint_on_mouseover=0
    transparent_dolphin_view=1
    transparent_ktitle_label=0
    transparent_menutitle=0
    unify_spin_buttons=0
  '';

  # Ensure Kvantum Manager starts with KDE applications
  xdg.configFile."autostart/kvantummanager.desktop".text = ''
    [Desktop Entry]
    Name=Kvantum Manager
    Comment=Qt Style Manager
    Exec=kvantummanager
    Icon=kvantum
    Terminal=false
    Type=Application
    Categories=Qt;Settings;
    StartupNotify=false
    X-KDE-autostart-after=panel
  '';

  xdg.configFile."kdeglobals".text = ''
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

  # KDE Color Scheme file
  xdg.dataFile."color-schemes/Rose-Pine-Main-BL.colors".text = ''
    [ColorScheme]
    Name=Rose-Pine-Main-BL
    Description=Rose Pine color scheme integrated with Kvantum

    [General]
    shadeSortColumn=true

    [KDE]
    contrast=4

    [Colors:View]
    BackgroundNormal=25,23,36
    BackgroundAlternate=31,29,46
    DecorationFocus=156,207,216
    DecorationHover=156,207,216
    ForegroundNormal=224,222,244
    ForegroundActive=224,222,244
    ForegroundInactive=144,140,170
    ForegroundLink=156,207,216
    ForegroundVisited=196,167,231
    ForegroundNegative=235,111,146
    ForegroundNeutral=246,193,119
    ForegroundPositive=156,207,216

    [Colors:Window]
    BackgroundNormal=25,23,36
    BackgroundAlternate=31,29,46
    DecorationFocus=156,207,216
    DecorationHover=156,207,216
    ForegroundNormal=224,222,244
    ForegroundActive=224,222,244
    ForegroundInactive=144,140,170
    ForegroundLink=156,207,216
    ForegroundVisited=196,167,231
    ForegroundNegative=235,111,146
    ForegroundNeutral=246,193,119
    ForegroundPositive=156,207,216

    [Colors:Button]
    BackgroundNormal=49,46,77
    BackgroundAlternate=49,46,77
    DecorationFocus=156,207,216
    DecorationHover=156,207,216
    ForegroundNormal=224,222,244
    ForegroundActive=224,222,244
    ForegroundInactive=144,140,170
    ForegroundLink=156,207,216
    ForegroundVisited=196,167,231
    ForegroundNegative=235,111,146
    ForegroundNeutral=246,193,119
    ForegroundPositive=156,207,216

    [Colors:Selection]
    BackgroundNormal=64,61,82
    BackgroundAlternate=82,79,103
    DecorationFocus=156,207,216
    DecorationHover=156,207,216
    ForegroundNormal=224,222,244
    ForegroundActive=224,222,244
    ForegroundInactive=144,140,170
    ForegroundLink=156,207,216
    ForegroundVisited=196,167,231
    ForegroundNegative=235,111,146
    ForegroundNeutral=246,193,119
    ForegroundPositive=156,207,216

    [Colors:Tooltip]
    BackgroundNormal=25,23,36
    BackgroundAlternate=25,23,36
    DecorationFocus=156,207,216
    DecorationHover=156,207,216
    ForegroundNormal=224,222,244
    ForegroundActive=224,222,244
    ForegroundInactive=144,140,170
    ForegroundLink=156,207,216
    ForegroundVisited=196,167,231
    ForegroundNegative=235,111,146
    ForegroundNeutral=246,193,119
    ForegroundPositive=156,207,216

    [Colors:Complementary]
    BackgroundNormal=38,35,58
    BackgroundAlternate=49,46,77
    DecorationFocus=235,188,186
    DecorationHover=235,188,186
    ForegroundNormal=224,222,244
    ForegroundActive=224,222,244
    ForegroundInactive=110,106,134
    ForegroundLink=156,207,216
    ForegroundVisited=196,167,231
    ForegroundNegative=235,111,146
    ForegroundNeutral=246,193,119
    ForegroundPositive=156,207,216
  '';

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
