{ userConfig, ... }:

{
  # **NETWORKING & FIREWALL CONFIGURATION**
  # Defines network settings, hostname, and firewall rules.
  networking = {
    hostName = userConfig.host.hostname;
    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
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