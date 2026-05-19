# networking.nix
#
# Purpose: Manage firewall, IP forwarding, and NetworkManager configuration
#
# This module:
# - Enables IP forwarding for IPv4/IPv6
# - Configures NetworkManager with wpa_supplicant backend
# - Sets up firewall rules with nftables
{ userConfig, ... }:
let
  ports = {
    custom = 30071;
    dhcp = 67;
    dns = 53;
    ssh = 22;
    syncthing = 53317;
  };

  rsnaTimeout = 60;
in
{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking = {
    firewall = {
      allowedTCPPortRanges = [
        {
          from = 3000;
          to = 4000;
        }
      ];
      allowedTCPPorts = [
        ports.custom
        ports.ssh
        ports.syncthing
      ];
      allowedUDPPorts = [
        ports.dhcp
        ports.dns
        ports.syncthing
      ];
      checkReversePath = "loose";
      enable = true;
      trustedInterfaces = [ "lo" ];
    };
    hostName = userConfig.hostname;
    nftables.enable = true;
    networkmanager = {
      enable = true;
      settings = {
        connection."wifi.powersave" = 2;
        device."wifi.scan-rand-mac-address" = "no";
        wifi = {
          "ap_scan" = 1;
          "bgscan" = "simple:30:-65:300";
          "dot11RSNAConfigPairwiseUpdateTimeout" = rsnaTimeout;
          "dot11RSNAConfigSATimeout" = rsnaTimeout;
          "eap_workaround" = 1;
          "fast_reauth" = 1;
          "logger_syslog" = -1;
          "logger_syslog_level" = "debug";
          "p2p_go_ht40" = 1;
        };
      };
      wifi.backend = "wpa_supplicant";
    };
  };
}
