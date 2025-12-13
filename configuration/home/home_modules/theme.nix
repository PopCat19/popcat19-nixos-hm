# Theme Module
#
# Purpose: Configure Rose Pine theme across GTK, Qt, and desktop environments
# Dependencies: rose-pine packages, inputs
# Related: environment.nix
#
# This module:
# - Sets up Rose Pine color scheme for GTK and Qt applications
# - Configures cursor, icon, and window themes
# - Manages Kvantum theme engine settings
{
  lib,
  pkgs,
  config,
  inputs,
  userConfig,
  ...
}: let
  # Core Rose Pine Palette (hex without 0x prefix for easy use)
  rosePineColors = {
    base = "191724";
    surface = "1f1d2e";
    overlay = "26233a";
    muted = "6e6a86";
    subtle = "908caa";
    text = "e0def4";
    love = "eb6f92";
    gold = "f6c177";
    rose = "ebbcba";
    pine = "31748f";
    foam = "9ccfd8";
    iris = "c4a7e7";
    highlightLow = "21202e";
    highlightMed = "403d52";
    highlightHigh = "524f67";
  };

  # Theme Variants: main (default), moon (darker)
  variants = {
    main = {
      gtkThemeName = "Rose-Pine-Main-BL";
      iconTheme = "Rose-Pine";
      cursorTheme = "rose-pine-hyprcursor";
      kvantumTheme = "rose-pine-rose";
      # Use base colors for main
      colors = rosePineColors;
    };
    moon = {
      gtkThemeName = "Rose-Pine-Moon-BL";
      iconTheme = "Rose-Pine-Moon";
      cursorTheme = "rose-pine-hyprcursor";
      kvantumTheme = "rose-pine-moon";
      # Override for moon (darker variants if needed; extend as required)
      colors =
        rosePineColors
        // {
          base = "232136"; # Example darker base; adjust from source
          surface = "2a273f";
        };
    };
  };

  # Default variant
  defaultVariant = variants.main;

  # Fonts
  fonts = {
    main = "Rounded Mplus 1c Medium";
    mono = "JetBrainsMono Nerd Font";
    sizes = {
      fuzzel = 14;
      kitty = 11;
      gtk = 11;
    };
  };

  # Packages (common)
  commonPackages = with pkgs; [
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    rose-pine-gtk-theme-full
    pkgs.kdePackages.qtstyleplugin-kvantum
    papirus-icon-theme
    nwg-look
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    polkit_gnome
    gsettings-desktop-schemas
    # Fonts
    google-fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.fantasque-sans-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
  ];

  # Generate GTK CSS from fonts
  mkGtkCss = fontMain: ''
    * {
      font-family: "${fontMain}";
    }
  '';

  # Session Variables from variant
  mkSessionVariables = variant: sizes: {
    QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORM = "wayland;xcb";
    GTK_THEME = variant.gtkThemeName;
    GDK_BACKEND = "wayland,x11,*";
    XCURSOR_THEME = variant.cursorTheme;
    # XCURSOR_SIZE set separately in theme.nix
    QT_QUICK_CONTROLS_STYLE = "Kvantum";
    QT_QUICK_CONTROLS_MATERIAL_THEME = "Dark";
  };

  # Selected variant (easy to switch here)
  selectedVariant = defaultVariant; # Change to variants.moon for darker theme

  iconTheme = "Papirus-Dark"; # Centralized if needed
  cursorSize = 24;

  cursorPackage = inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default;
  kvantumPkg = pkgs.kdePackages.qtstyleplugin-kvantum;
  rosePineKvantum = pkgs.rose-pine-kvantum;
  rosePineGtk =
    if builtins.hasAttr "rose-pine-gtk-theme-full" pkgs
    then pkgs.rose-pine-gtk-theme-full
    else if builtins.hasAttr "rose-pine-gtk-theme" pkgs
    then pkgs.rose-pine-gtk-theme
    else null;
in {
  home.sessionVariables =
    mkSessionVariables selectedVariant fonts.sizes
    // {
      XCURSOR_SIZE = builtins.toString cursorSize;
    };

  # GTK theme configuration - simplified to avoid module option conflicts
  home.file.".config/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=${selectedVariant.gtkThemeName}
    gtk-icon-theme-name=${iconTheme}
    gtk-font-name=${fonts.main} ${builtins.toString fonts.sizes.gtk}
    gtk-cursor-theme-name=${selectedVariant.cursorTheme}
    gtk-cursor-theme-size=${builtins.toString cursorSize}
  '';

  home.file.".config/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=${selectedVariant.gtkThemeName}
    gtk-icon-theme-name=${iconTheme}
    gtk-font-name=${fonts.main} ${builtins.toString fonts.sizes.gtk}
    gtk-cursor-theme-name=${selectedVariant.cursorTheme}
    gtk-cursor-theme-size=${builtins.toString cursorSize}
  '';

  qt = {
    enable = true;
    style = {
      name = "kvantum";
      package = kvantumPkg;
    };
  };

  # Ensure Kvantum can find Rosé Pine themes from our package
  # Kvantum searches ~/.config/Kvantum and XDG data dirs (share/Kvantum)
  # These symlinks guarantee availability regardless of XDG_DATA_DIRS.
  xdg.configFile."Kvantum/rose-pine-rose".source = "${rosePineKvantum}/share/Kvantum/rose-pine-rose";
  xdg.configFile."Kvantum/rose-pine-moon".source = "${rosePineKvantum}/share/Kvantum/rose-pine-moon";

  home.file.".config/Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=${selectedVariant.kvantumTheme}
  '';

  # Ensure Qt5 apps also use Kvantum style and Papirus icons
  home.file.".config/qt5ct/qt5ct.conf" = {
    text = ''
      [Appearance]
      color_scheme_path=
      custom_palette=false
      icon_theme=${iconTheme}
      style=kvantum

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

  # Ensure KDE Frameworks apps (Dolphin, Gwenview, Okular, etc.) use Papirus icons
  # KDE reads ~/.config/kdeglobals for the icon theme.
  home.file.".config/kdeglobals".text = ''
    [Icons]
    Theme=${iconTheme}
  '';

  # Use centralized package list from lib/theme.nix and add module-specific extras
  # Avoid duplicating cursorPackage (already included in commonPackages)
  home.packages = with pkgs;
    commonPackages
    ++ [
      rose-pine-kvantum
    ];
}
