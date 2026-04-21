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

  # Shimboot uses systemd 257.9 (pinned for ChromeOS compatibility)
  # NixOS logind module expects systemd.package.withLogind (258+)
  # Explicitly enable to bypass broken default
  services.logind.enable = true;
}
