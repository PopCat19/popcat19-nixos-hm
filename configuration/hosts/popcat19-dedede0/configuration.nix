# configuration.nix
#
# Purpose: Main NixOS configuration for the dedede0 host (shimboot ChromeOS device)
{ userConfig, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}.nix
  ];

  networking.hostName = userConfig.hostname;
}
