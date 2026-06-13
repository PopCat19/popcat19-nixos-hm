# mainsail.nix
#
# Purpose: Mainsail web UI for Klipper/Moonraker on port 80 via nginx
_: {
  services.mainsail = {
    enable = true;
    hostName = "0.0.0.0";
  };

  services.nginx = {
    enable = true;
    clientMaxBodySize = "0";
  };
}
