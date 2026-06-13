# configuration.nix
#
# Purpose: Main NixOS configuration for the aarch640 stub host
{ userConfig, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}.nix
  ];

  networking.hostName = userConfig.hostname;
}
