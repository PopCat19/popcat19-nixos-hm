# Networking Configuration Module
#
# Purpose: Manage firewall, IP forwarding, and NetworkManager configuration.
# Dependencies: networkmanager, wpa_supplicant
# Related: None
#
# This module:
# - Enables IP forwarding for IPv4/IPv6
# - Configures NetworkManager with wpa_supplicant backend
# - Sets up firewall rules with nftables

{userConfig, ...}: let
  # Port definitions (DRY)
  ports = {
    ssh = 22;
    syncthing = 53317;
    custom = 30071;
    dns = 53;
    dhcp = 67;
  };

  # Timeout value for RSNA configuration
  rsnaTimeout = 60;
in {
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking = {
    hostName = userConfig.host.hostname;
    nftables.enable = true;

    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
      settings = {
        device."wifi.scan-rand-mac-address" = "no";
        connection."wifi.powersave" = 2;
        wifi = {
          "ap_scan" = 1;
          "fast_reauth" = 1;
          "eap_workaround" = 1;
          "dot11RSNAConfigSATimeout" = rsnaTimeout;
          "dot11RSNAConfigPairwiseUpdateTimeout" = rsnaTimeout;
          "bgscan" = "simple:30:-65:300";
          "p2p_go_ht40" = 1;
          "logger_syslog" = -1;
          "logger_syslog_level" = "debug";
        };
      };
    };

    firewall = {
      enable = true;
      trustedInterfaces = ["lo"];
      allowedTCPPorts = [ports.ssh ports.syncthing ports.custom];
      allowedUDPPorts = [ports.syncthing ports.dns ports.dhcp];
      allowedTCPPortRanges = [{from = 3000; to = 4000;}];
      checkReversePath = false;
    };
  };
}
