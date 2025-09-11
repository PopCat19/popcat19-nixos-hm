{userConfig, ...}: {
  # Networking and firewall configuration
  networking = {
    hostName = userConfig.host.hostname;
    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
      # Configure wpa_supplicant to fix authentication timeouts
      settings = {
        device = {
          "wifi.scan-rand-mac-address" = "no";
        };
        connection = {
          "wifi.powersave" = 2;
        };
        wifi = {
          "ap_scan" = 1;
          "fast_reauth" = 1;
          "eap_workaround" = 1;
          "dot11RSNAConfigSATimeout" = 60;
          "dot11RSNAConfigPairwiseUpdateTimeout" = 60;
          "bgscan" = "simple:30:-65:300";
          "p2p_go_ht40" = 1;
          "logger_syslog" = -1;
          "logger_syslog_level" = "debug";
        };
      };
    };
    firewall = {
      enable = true;
      # network overrides deprecated — use canonical defaults here
      trustedInterfaces = ["lo"];
      allowedTCPPorts = [
        22 # SSH
        53317 # Syncthing
        30071 # Custom port
      ];
      allowedUDPPorts = [
        53317 # Syncthing
      ];
      allowedTCPPortRanges = [
        {
          from = 3000;
          to = 4000;
        } # Range for local development servers
      ];
      checkReversePath = false;
    };
  };
}
