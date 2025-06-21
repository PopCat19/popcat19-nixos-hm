# Rose Pine Color Definitions
# This file contains the official Rose Pine color palette for easy reference
# across different configuration files and modules.

{
  # Rose Pine Color Palette
  # Source: https://rosepinetheme.com/palette/

  colors = {
    # Main palette
    base = "#191724";      # Background color
    surface = "#1f1d2e";   # Secondary background
    overlay = "#26233a";   # Tertiary background
    muted = "#6e6a86";     # Muted text
    subtle = "#908caa";    # Subtle text
    text = "#e0def4";      # Primary text
    love = "#eb6f92";      # Red accent
    gold = "#f6c177";      # Yellow accent
    rose = "#ebbcba";      # Pink accent
    pine = "#31748f";      # Teal accent
    foam = "#9ccfd8";      # Cyan accent
    iris = "#c4a7e7";      # Purple accent

    # Highlight variants
    highlightLow = "#21202e";    # Low emphasis highlight
    highlightMed = "#403d52";    # Medium emphasis highlight
    highlightHigh = "#524f67";   # High emphasis highlight
  };

  # RGB values for use in configurations that require RGB format
  colorsRgb = {
    base = "25,23,36";
    surface = "31,29,46";
    overlay = "38,35,58";
    muted = "110,106,134";
    subtle = "144,140,170";
    text = "224,222,244";
    love = "235,111,146";
    gold = "246,193,119";
    rose = "235,188,186";
    pine = "49,116,143";
    foam = "156,207,216";
    iris = "196,167,231";
  };

  # ANSI escape codes for terminal usage
  colorsAnsi = {
    base = "\\u001b[38;2;25;23;36m";
    surface = "\\u001b[38;2;31;29;46m";
    overlay = "\\u001b[38;2;38;35;58m";
    muted = "\\u001b[38;2;110;106;134m";
    subtle = "\\u001b[38;2;144;140;170m";
    text = "\\u001b[38;2;224;222;244m";
    love = "\\u001b[38;2;235;111;146m";
    gold = "\\u001b[38;2;246;193;119m";
    rose = "\\u001b[38;2;235;188;186m";
    pine = "\\u001b[38;2;49;116;143m";
    foam = "\\u001b[38;2;156;207;216m";
    iris = "\\u001b[38;2;196;167;231m";
    reset = "\\u001b[0m";
  };

  # Semantic color mapping for different UI elements
  semantic = {
    # Backgrounds
    background = "#191724";
    backgroundSecondary = "#1f1d2e";
    backgroundTertiary = "#26233a";

    # Text
    textPrimary = "#e0def4";
    textSecondary = "#908caa";
    textMuted = "#6e6a86";

    # Accents
    accent = "#eb6f92";        # Love (red)
    accentSecondary = "#9ccfd8"; # Foam (cyan)
    warning = "#f6c177";       # Gold (yellow)
    success = "#31748f";       # Pine (teal)
    info = "#c4a7e7";          # Iris (purple)
    error = "#eb6f92";         # Love (red)

    # Interactive elements
    border = "#6e6a86";
    borderFocus = "#9ccfd8";
    borderHover = "#908caa";

    # Selection
    selection = "#9ccfd8";
    selectionText = "#191724";
  };

  # GTK specific color definitions
  gtkColors = {
    # Window colors
    bg_color = "#191724";
    fg_color = "#e0def4";
    base_color = "#1f1d2e";
    text_color = "#e0def4";
    selected_bg_color = "#9ccfd8";
    selected_fg_color = "#191724";
    tooltip_bg_color = "#26233a";
    tooltip_fg_color = "#e0def4";

    # Theme colors
    theme_bg_color = "#191724";
    theme_fg_color = "#e0def4";
    theme_base_color = "#1f1d2e";
    theme_text_color = "#e0def4";
    theme_selected_bg_color = "#9ccfd8";
    theme_selected_fg_color = "#191724";

    # Insensitive colors
    insensitive_bg_color = "#26233a";
    insensitive_fg_color = "#6e6a86";
    insensitive_base_color = "#26233a";
    insensitive_text_color = "#6e6a86";

    # Button colors
    button_bg_color = "#26233a";
    button_fg_color = "#e0def4";
    button_hover_color = "#908caa";
    button_active_color = "#eb6f92";

    # Border colors
    borders = "#6e6a86";
    unfocused_borders = "#26233a";

    # Warning colors
    warning_color = "#f6c177";
    error_color = "#eb6f92";
    success_color = "#31748f";
  };

  # Qt/KDE specific color definitions
  qtColors = {
    # Window colors
    Window = "25,23,36";
    WindowText = "224,222,244";
    Base = "31,29,46";
    AlternateBase = "38,35,58";
    Text = "224,222,244";
    Button = "38,35,58";
    ButtonText = "224,222,244";
    BrightText = "255,255,255";

    # Highlight colors
    Highlight = "156,207,216";
    HighlightedText = "25,23,36";

    # Disabled colors
    WindowDisabled = "38,35,58";
    WindowTextDisabled = "110,106,134";
    BaseDisabled = "38,35,58";
    TextDisabled = "110,106,134";
    ButtonDisabled = "38,35,58";
    ButtonTextDisabled = "110,106,134";

    # Link colors
    Link = "156,207,216";
    LinkVisited = "196,167,231";

    # Tool tip colors
    ToolTipBase = "38,35,58";
    ToolTipText = "224,222,244";
  };

  # Utility functions for color conversion
  utils = {
    # Convert hex to RGB values
    hexToRgb = hex:
      let
        r = builtins.fromTOML "r = 0x${builtins.substring 1 2 hex}";
        g = builtins.fromTOML "g = 0x${builtins.substring 3 2 hex}";
        b = builtins.fromTOML "b = 0x${builtins.substring 5 2 hex}";
      in "${toString r.r},${toString g.g},${toString b.b}";

    # Create ANSI escape code from RGB
    rgbToAnsi = r: g: b: "\\u001b[38;2;${toString r};${toString g};${toString b}m";
  };
}
