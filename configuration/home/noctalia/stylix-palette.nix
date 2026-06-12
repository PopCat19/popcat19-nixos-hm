# stylix-palette.nix
#
# Purpose: Bridge Stylix base16 colors into Noctalia v5 customPalettes
#
# This module:
# - Reads config.lib.stylix.colors.withHashtag (base00–base0F)
# - Maps base16 roles to noctalia v5 palette keys
# - Returns customPalettes attrset and theme fragment for deep merge
#
# Mapping mirrors the Stylix v4 noctalia-shell target (modules/noctalia-shell/hm.nix).
{
  config,
  ...
}:
let
  inherit (config.lib.stylix.colors) withHashtag;

  # Mapping follows PMD base16 slot semantics (doc/base16-implementation.txt):
  #   base00 (4x)     = Background (darkest, behind everything)
  #   base01 (8x)     = Surface (solid card/panel backgrounds)
  #   base02 (80×8%)  = Surface hint (interactive backgrounds, hover)
  #   base03 (80×48%) = Muted (borders, separators)
  #   base04 (64x)    = Subtext (secondary metadata)
  #   base05 (80x)    = Body Text (primary foreground)
  #   base08 (88x)    = Danger (error/destructive)
  #   base0C (80x+140)= Support (tertiary accent)
  #   base0D (80x+30) = Functions (primary accent)
  #   base0E (64x−30) = Keywords (secondary accent)
  palette = {
    dark = {
      mPrimary = withHashtag.base0D;
      mOnPrimary = withHashtag.base00;
      mSecondary = withHashtag.base0E;
      mOnSecondary = withHashtag.base00;
      mTertiary = withHashtag.base0C;
      mOnTertiary = withHashtag.base00;
      mError = withHashtag.base08;
      mOnError = withHashtag.base00;
      mSurface = withHashtag.base01;
      mOnSurface = withHashtag.base05;
      mSurfaceVariant = withHashtag.base00;
      mOnSurfaceVariant = withHashtag.base04;
      mOutline = withHashtag.base03;
      mShadow = withHashtag.base00;
      mHover = withHashtag.base02;
      mOnHover = withHashtag.base05;

      terminal = {
        background = withHashtag.base00;
        foreground = withHashtag.base05;
        cursor = withHashtag.base05;
        cursorText = withHashtag.base00;
        selectionBg = withHashtag.base05;
        selectionFg = withHashtag.base00;

        normal = {
          black = withHashtag.base00;
          red = withHashtag.base08;
          green = withHashtag.base0B;
          yellow = withHashtag.base0A;
          blue = withHashtag.base0D;
          magenta = withHashtag.base0E;
          cyan = withHashtag.base0C;
          white = withHashtag.base05;
        };

        bright = {
          black = withHashtag.base03;
          red = withHashtag.base08;
          green = withHashtag.base0B;
          yellow = withHashtag.base0A;
          blue = withHashtag.base0D;
          magenta = withHashtag.base0E;
          cyan = withHashtag.base0C;
          white = withHashtag.base07;
        };
      };
    };
  };
in
{
  noctaliaStylix = {
    customPalettes = {
      Stylix = palette;
    };

    themeSettings = {
      source = "custom";
      custom_palette = "Stylix";
    };
  };
}
