{ ... }:

{
  # **NETWORKING & FIREWALL CONFIGURATION**
  # Defines network settings, hostname, and firewall rules.
  networking = {
    hostName = "popcat19-nixos0";
    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
    };
    firewall = {
      enable = true;
      trustedInterfaces = [ "lo" ];
      allowedTCPPorts = [
        53317  # Syncthing
        30071  # Custom port
      ];
      allowedUDPPorts = [
        53317  # Syncthing
      ];
      checkReversePath = false;
    };
  };
}