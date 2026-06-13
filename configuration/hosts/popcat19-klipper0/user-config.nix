# user-config.nix
#
# Purpose: Host-specific configuration for the Klipper Pi 4B
# v2 — rebuild marker
let
  base = import ../../user-config.nix;
  home = "/home/popcat19";
in
base
// {
  system = "aarch64-linux";
  hostname = "klipper";
  username = "popcat19";
  profile = "klipper";

  host = {
    hostname = "klipper";
    system = "aarch64-linux";
  };

  timezone = "America/New_York";
  locale = "en_US.UTF-8";

  user = {
    fullName = "PopCat19";
    email = "atsuo11111@gmail.com";
    shell = "fish";
    shellPackage = "fish";
    initialPassword = "popcat19";
    extraGroups = [
      "klipper"
      "networkmanager"
      "wheel"
    ];
  };

  directories =
    let
      h = home;
    in
    {
      home = h;
      documents = "${h}/Documents";
      downloads = "${h}/Downloads";
      syncthing = "${h}/syncthing-shared";
    };

  # No desktop apps on the Pi
  defaultApps = { };

  # No gaming on the Pi
  gaming.enable = false;
  gaming.enableROCm = false;

  # No LLM agents on the Pi
  agents = { };

  env = {
    repoName = "popcat19-nixos-hm";
    NIXOS_CONFIG_DIR = "${home}/popcat19-nixos-hm";
  };

  # WiFi credentials: home network, PSK ends up in /nix/store via
  # NetworkManager connection file regardless of delivery method.
  # Not a real secret — SSH keys gate actual access.
  wifi = {
    ssid = "Beave_Net_IoT";
    psk = "REDACTED";
  };
}
