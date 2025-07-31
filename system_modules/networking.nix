{ userConfig, ... }:

{
  # **NETWORKING & FIREWALL CONFIGURATION**
  # Defines network settings, hostname, and firewall rules.
  networking = {
    hostName = userConfig.host.hostname;
    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
      # Configure wpa_supplicant through NetworkManager to fix authentication timeouts
      settings = {
        device = {
          "wifi.scan-rand-mac-address" = "no";
        };
        connection = {
          "wifi.powersave" = 2;
        };
        wifi = {
          # Increase timeout for authentication to prevent disconnections
          "ap_scan" = 1;
          "fast_reauth" = 1;
          # Timeout values in seconds
          "eap_workaround" = 1;
          # Retry configuration
          "dot11RSNAConfigSATimeout" = 60;
          "dot11RSNAConfigPairwiseUpdateTimeout" = 60;
          # Configuration for better roaming and reconnection
          "bgscan" = "simple:30:-65:300";
          # Disable power saving which can cause connection issues
          "p2p_go_ht40" = 1;
          # Enable more verbose logging for debugging
          "logger_syslog" = -1;
          "logger_syslog_level" = "debug";
        };
      };
    };
    firewall = {
      enable = true;
      trustedInterfaces = userConfig.network.trustedInterfaces;
      allowedTCPPorts = userConfig.network.allowedTCPPorts;
      allowedUDPPorts = userConfig.network.allowedUDPPorts;
      checkReversePath = false;
    };
  };
}