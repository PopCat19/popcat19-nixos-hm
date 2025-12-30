# Tailscale VPN Module
#
# Purpose: Configure Tailscale VPN service with Mullvad exit node integration
# Dependencies: None (standalone)
# Related: vpn.nix (Mullvad VPN), networking.nix
#
# This module:
# - Enables Tailscale service for mesh VPN networking
# - Configures MagicDNS for hostname resolution
# - Integrates with Mullvad for exit node access
# - Provides secure peer-to-peer connectivity
{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  # Enable Tailscale service and CLI
  services.tailscale.enable = true;

  environment.systemPackages = [
    pkgs.tailscale
  ];

  # Configure DNS for MagicDNS functionality
  # Uses Tailscale's MagicDNS (100.100.100.100) with fallback DNS
  networking.nameservers = [
    "100.100.100.100"  # Tailscale MagicDNS
    "8.8.8.8"         # Google DNS fallback
    "1.1.1.1"         # Cloudflare DNS fallback
  ];

  # Set search domain for MagicDNS
  # Replace 'ts.net' with your actual tailnet name
  networking.search = [
    "ts.net"
  ];

  # Mullvad Exit Node Integration
  # This configuration allows Tailscale to use Mullvad exit nodes
  # when the mullvad attribute is applied to devices in Tailscale ACLs
  #
  # Important: If migrating from standalone Mullvad VPN to Tailscale Mullvad integration:
  # 1. Disable Mullvad VPN in the GUI
  # 2. Turn off "Block connections without VPN" in Mullvad settings
  # 3. Ensure proper node attributes are set in Tailscale policy file
  #
  # Example Tailscale ACL configuration:
  # {
  #   "nodeAttrs": [
  #     {
  #       "target": ["group:mullvad"],
  #       "attr": ["mullvad"]
  #     }
  #   ]
  # }

  # Ensure Tailscale service starts after network is available
  systemd.services.tailscaled = {
    wants = ["network-online.target"];
    after = ["network-online.target"];
  };

  # Optional: Configure Tailscale to handle DNS for the entire system
  # This ensures all system DNS queries go through Tailscale when connected
  # Uncomment if you want Tailscale to manage system DNS
  # networking.networkmanager.dns = "systemd-resolved";
}