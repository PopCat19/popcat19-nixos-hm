# nix-on-droid.nix
#
# Purpose: nix-on-droid configuration module for flake-parts
#
# This module:
# - Builds nixOnDroidConfigurations for the nix-on-droid host
# - Passes userConfig and inputs via specialArgs
{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  userConfig = import ../configuration/hosts/nix-on-droid/user-config.nix { inherit lib; };
  pkgs = import inputs.nixpkgs {
    inherit (userConfig) system;
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
