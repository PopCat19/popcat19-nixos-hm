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
      mSurface = withHashtag.base00;
      mOnSurface = withHashtag.base05;
      mSurfaceVariant = withHashtag.base01;
      mOnSurfaceVariant = withHashtag.base04;
      mOutline = withHashtag.base03;
      mShadow = withHashtag.base00;
      mHover = withHashtag.base0C;
      mOnHover = withHashtag.base00;
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
