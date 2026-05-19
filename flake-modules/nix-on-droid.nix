# nix-on-droid.nix
#
# Purpose: nix-on-droid configuration module for flake-parts
#
# This module:
# - Builds nixOnDroidConfigurations for the nix-on-droid host
# - Passes userConfig and inputs via specialArgs
{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  userConfig = import ../configuration/hosts/nix-on-droid/user-config.nix;
  pkgs = import inputs.nixpkgs {
    system = userConfig.system;
    config.allowUnfree = true;
  };
in
{
  flake.nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    inherit pkgs;
    modules = [
      ../configuration/hosts/nix-on-droid
      {
        _module.args = {
          inherit userConfig inputs;
          hostPlatform = userConfig.system;
        };
      }
    ];
  };
}
