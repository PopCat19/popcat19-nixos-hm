# default.nix
#
# Purpose: Entry point for the Klipper printer stack
#
# This module:
# - Imports Klipper, Moonraker, and Mainsail service modules only when enabled
# - Generates the WiFi NetworkManager profile from an agenix secret
# - Points the primary user's password at an agenix hashed-password secret
{
  config,
  lib,
  userConfig,
  ...
}:
let
  cfg = userConfig.klipper or { };
in
{
  imports = lib.optionals (cfg.enable or false) [
    ./users.nix
    ./printer.nix
    ./moonraker.nix
    ./mainsail.nix
  ];

  config = lib.mkIf (cfg.enable or false) (
    lib.mkMerge [
      (lib.mkIf (config.age.secrets ? klipper-hashed-password) {
        users.users.${userConfig.username}.hashedPasswordFile =
          config.age.secrets.klipper-hashed-password.path;
      })

      (lib.mkIf (config.age.secrets ? klipper-wifi-psk) {
        system.activationScripts.klipper-wifi-profile = {
          text = ''
            mkdir -p /etc/NetworkManager/system-connections
            chmod 0755 /etc/NetworkManager/system-connections
            psk=$(cat ${config.age.secrets.klipper-wifi-psk.path})
            cat > /etc/NetworkManager/system-connections/Beave_Net_IoT.nmconnection <<EOF
            [connection]
            id=Beave_Net_IoT
            uuid=0278899c-f325-4669-ad07-06abc09f893d
            type=wifi

            [wifi]
            mode=infrastructure
            ssid=${cfg.wifi.ssid or ""}

            [wifi-security]
            key-mgmt=wpa-psk
            psk=$psk

            [ipv4]
            method=auto

            [ipv6]
            addr-gen-mode=default
            method=auto

            [proxy]
            EOF
            chmod 0600 /etc/NetworkManager/system-connections/Beave_Net_IoT.nmconnection
          '';
        };
      })
    ]
  );
}
