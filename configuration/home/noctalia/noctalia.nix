# noctalia.nix
#
# Purpose: Main module for Noctalia v5 configuration
#
# This module:
# - Uses programs.noctalia (v5 renamed from programs.noctalia-shell)
# - Applies user's personalized settings from settings.nix
# - Uses built-in systemd service (no custom delay needed)
# - Stylix color integration pending upstream v5 target update
{
  config,
  inputs,
  ...
}:
let
  settings = import ./settings.nix { inherit config; };
in
{
  imports = [ inputs.noctalia-shell.homeModules.default ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    inherit (settings) settings;
  };
}
