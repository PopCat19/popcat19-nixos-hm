# tailscale.nix
#
# Purpose: Enable Tailscale mesh VPN for secure VNC/SSH access across devices
#
# This module:
# - Enables Tailscale service with MagicDNS and SSH
# - Runs alongside Mullvad without conflict (separate WireGuard interfaces)
{ lib, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkDefault "client";
  };
}
