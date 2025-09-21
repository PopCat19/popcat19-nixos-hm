{ lib
, pkgs
, system
, inputs
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
      iconTheme = "Papirus-Dark";
      cursorTheme = "rose-pine-hyprcursor";
      kvantumTheme = "rose-pine-rose";
      kdeColorSchemeName = "Rose-Pine-Main-BL";
      # Use base colors for main
      colors = rosePineColors;
    };
    moon = {
      gtkThemeName = "Rose-Pine-Moon-BL";
      iconTheme = "Papirus-Dark";
      cursorTheme = "rose-pine-hyprcursor";
      kvantumTheme = "rose-pine-moon";
      kdeColorSchemeName = "Rose-Pine-Moon-BL";
      # Override for moon (darker variants if needed; extend as required)
      colors = rosePineColors // {
        base = "232136";  # Example darker base; adjust from source
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
    inputs.rose-pine-hyprcursor.packages.${system}.default
    rose-pine-gtk-theme-full
    pkgs.kdePackages.qtstyleplugin-kvantum
    papirus-icon-theme
    adwaita-icon-theme
    nwg-look
    libsForQt5.qt5ct
    qt6ct
    polkit_gnome
    gsettings-desktop-schemas
    # Fonts
    google-fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.fantasque-sans-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
  ];

  # Generate GTK CSS from fonts
  mkGtkCss = fontMain: ''
    * {
      font-family: "${fontMain}";
    }
  '';


  # Generate KDE Color Scheme from colors/variant
  mkKdeColorScheme = { name, colors, ... }: let
    # Helper to format RGB
    rgb = c: "${c.r},${c.g},${c.b}";

    # Hex to RGB conversion
    hexToRgb = hex: let
      r = "0x${lib.strings.substring 0 2 hex}";
      g = "0x${lib.strings.substring 2 4 hex}";
      b = "0x${lib.strings.substring 4 6 hex}";
    in { inherit r g b; };

    # Base color mappings (RGB tuples)
    baseColors = {
      BackgroundNormal = hexToRgb colors.base;
      BackgroundAlternate = hexToRgb colors.surface;
      BackgroundInactive = hexToRgb colors.overlay;
      DecorationFocus = hexToRgb colors.foam;
      DecorationHover = hexToRgb colors.iris;
      ForegroundNormal = hexToRgb colors.text;
      ForegroundActive = hexToRgb colors.text;
      ForegroundInactive = hexToRgb colors.muted;
      ForegroundLink = hexToRgb colors.pine;
      ForegroundVisited = hexToRgb colors.rose;
      ForegroundNegative = hexToRgb colors.love;
      ForegroundNeutral = hexToRgb colors.gold;
      ForegroundPositive = hexToRgb colors.foam;
      SelectionBackgroundNormal = hexToRgb colors.highlightLow;
      SelectionForegroundNormal = hexToRgb colors.text;
      TooltipBackgroundNormal = hexToRgb colors.overlay;
      TooltipForegroundNormal = hexToRgb colors.text;
      ButtonBackgroundNormal = hexToRgb colors.surface;
      ButtonForegroundNormal = hexToRgb colors.text;
    };

    # Generate lines for a section
    genSectionLines = sectionName: colorMap: ''
      [Colors:${sectionName}]
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}=${rgb v}") colorMap)}
    '';

    # Sections with variations
    sections = {
      Window = baseColors // { BackgroundActive = hexToRgb colors.surface; };
      Button = baseColors // { ButtonBackgroundHover = hexToRgb colors.overlay; };
      View = baseColors // { TextForeground = hexToRgb colors.text; };
      Selection = {
        BackgroundNormal = hexToRgb colors.highlightMed;
        ForegroundNormal = hexToRgb colors.text;
        BackgroundInactive = hexToRgb colors.highlightLow;
        ForegroundInactive = hexToRgb colors.muted;
      };
      Tooltip = {
        BackgroundNormal = hexToRgb colors.overlay;
        ForegroundNormal = hexToRgb colors.text;
      };
      Complementary = baseColors // { ComplementaryBackground = hexToRgb colors.surface; };
    };

    # All section strings
    allSections = lib.concatStringsSep "\n\n" (lib.mapAttrsToList genSectionLines sections);

  in ''
    [ColorScheme]
    Name=${name}
    Description=Rose Pine color scheme for KDE

    [General]
    shadeSortColumn=true

    [KDE]
    contrast=4

    ${allSections}
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

in {
  inherit rosePineColors variants defaultVariant fonts commonPackages;
  inherit mkGtkCss mkKdeColorScheme mkSessionVariables;
}