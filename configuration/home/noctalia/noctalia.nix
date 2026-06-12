# noctalia.nix
#
# Purpose: Main module for Noctalia v5 configuration
#
# This module:
# - Uses programs.noctalia (v5 renamed from programs.noctalia-shell)
# - Applies user's personalized settings from settings.nix
# - Bridges Stylix base16 colors into customPalettes via stylix-palette.nix
# - Uses built-in systemd service (no custom delay needed)
#
# TODO(v5-stylix): When Stylix adds native Noctalia v5 support:
#   1. Delete stylix-palette.nix (manual bridge becomes redundant)
#   2. Enable stylix.targets.noctalia.enable (or whatever the option is)
#   3. Remove lib.recursiveUpdate override below that injects customPalettes
#      into settings.theme — Stylix will set it directly
#   4. Remove the customPalettes attr from programs.noctalia.settings
{
  config,
  lib,
  inputs,
  ...
}:
let
  settings = import ./settings.nix { inherit config; };
  stylixPalette = import ./stylix-palette.nix { inherit config; };
in
{
  imports = [ inputs.noctalia-shell.homeModules.default ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = lib.recursiveUpdate settings.settings {
      theme = stylixPalette.noctaliaStylix.themeSettings;
    };

    customPalettes = stylixPalette.noctaliaStylix.customPalettes;
  };
}
