{ lib
, pkgs
, config
, system
, inputs
, userConfig
, ...
}: let
  inherit (import ./lib/theme.nix { inherit lib pkgs system inputs; }) defaultVariant fonts commonPackages mkGtkCss mkKdeColorScheme mkSessionVariables;

  # Selected variant (easy to switch here)
  selectedVariant = defaultVariant;  # Change to variants.moon for darker theme

  iconTheme = "Papirus-Dark";  # Centralized if needed
  cursorSize = 24;

  cursorPackage = inputs.rose-pine-hyprcursor.packages.${system}.default;
  kvantumPkg = pkgs.kdePackages.qtstyleplugin-kvantum;
  rosePineKvantum = pkgs.rose-pine-kvantum;
  rosePineGtk = pkgs.rose-pine-gtk-theme-full;

  gtkCss = mkGtkCss fonts.main;
in {
  home.sessionVariables = mkSessionVariables selectedVariant fonts.sizes // {
    XCURSOR_SIZE = builtins.toString cursorSize;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = selectedVariant.cursorTheme or "rose-pine-hyprcursor";
      size = cursorSize;
      package = cursorPackage;
    };
    theme = {
      name = selectedVariant.gtkThemeName;
      package = rosePineGtk;
    };
    iconTheme = {
      name = iconTheme;
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = fonts.main;
      size = fonts.sizes.gtk;
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
    gtk3.extraCss = gtkCss;
    gtk4.extraCss = gtkCss;
  };

  qt = {
    enable = true;
    style = {
      name = "kvantum";
      package = kvantumPkg;
    };
  };

  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorScheme=${selectedVariant.kdeColorSchemeName}
    Name=${selectedVariant.kdeColorSchemeName}
    shadeSortColumn=true

    TerminalApplication=${userConfig.defaultApps.terminal.command}
    TerminalService=${userConfig.defaultApps.terminal.desktop}

    [Icons]
    Theme=${iconTheme}

    [KDE]
    contrast=4
    widgetStyle=kvantum
  '';

  xdg.dataFile."color-schemes/${selectedVariant.kdeColorSchemeName}.colors".text = mkKdeColorScheme { name = selectedVariant.kdeColorSchemeName; colors = selectedVariant.colors; };

  home.file.".config/qt6ct/qt6ct.conf" = {
    text = ''
      [Appearance]
      color_scheme_path=
      custom_palette=false
      icon_theme=${selectedVariant.iconTheme}
      standard_dialogs=default
      style=kvantum

      [Fonts]
      fixed="${fonts.mono},11,-1,5,50,0,0,0,0,0"
      general="${fonts.main},${builtins.toString fonts.sizes.gtk},-1,5,50,0,0,0,0,0"

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
    '';
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = selectedVariant.cursorTheme;
      cursor-size = cursorSize;
      gtk-theme = selectedVariant.gtkThemeName;
      icon-theme = selectedVariant.iconTheme;
      font-name = "${fonts.main} ${builtins.toString fonts.sizes.gtk}";
      document-font-name = "${fonts.main} ${builtins.toString fonts.sizes.gtk}";
      monospace-font-name = "${fonts.mono} ${builtins.toString fonts.sizes.kitty}";
      color-scheme = "prefer-dark";
    };

    "org/gnome/desktop/wm/preferences" = {
      theme = selectedVariant.gtkThemeName;
    };
  };


  programs.kitty.font = {
    name = fonts.mono;
    size = fonts.sizes.kitty;
  };

  programs.fuzzel.settings.main.font = "${fonts.main}:size=${builtins.toString fonts.sizes.fuzzel}";

  home.file.".config/fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>${fonts.main}</family>
        </prefer>
      </alias>
      <alias>
        <family>${fonts.main}</family>
        <default>
          <family>sans-serif</family>
        </default>
      </alias>
    </fontconfig>
  '';

  home.packages = with pkgs; [
    # Fonts
    google-fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.fantasque-sans-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome

    # Theme tools
    nwg-look
    libsForQt5.qt5ct
    qt6ct
    kdePackages.qtstyleplugin-kvantum
    rose-pine-kvantum
    rose-pine-gtk-theme-full
    cursorPackage
    papirus-icon-theme
    adwaita-icon-theme
    polkit_gnome
    gsettings-desktop-schemas
  ];
}
