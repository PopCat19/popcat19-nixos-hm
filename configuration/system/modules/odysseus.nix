# odysseus.nix
#
# Purpose: Declare the Odysseus AI workspace service on NixOS hosts
#
# Used by: popcat19-nixos0 (main desktop)
#
# This module:
# - Conditionally imports the nix-odysseus NixOS module
# - Enables services.odysseus when userConfig.odysseus.enable is true
{
  inputs,
  userConfig,
  lib,
  config,
  ...
}:
let
  odysseusCfg = userConfig.odysseus or { };
in
{
  imports = lib.optionals (odysseusCfg.enable or false) [
    inputs.odysseus.nixosModules.default
  ];

  config = lib.mkIf (odysseusCfg.enable or false) {
    services.odysseus = {
      enable = true;
      environmentFile = odysseusCfg.environmentFile or null;
      openFirewall = odysseusCfg.openFirewall or false;
    };
  };
}
