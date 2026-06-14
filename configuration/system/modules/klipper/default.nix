# default.nix
#
# Purpose: Entry point for the Klipper printer stack
#
# This module:
# - Imports Klipper, Moonraker, and Mainsail service modules only when enabled
# - Seeds the client WiFi NetworkManager profile on first boot from userConfig
# - Seeds the fallback AP profile and enables auto/manual AP switching
{
  config,
  lib,
  userConfig,
  ...
}:
let
  cfg = userConfig.klipper or { };
  wifiCfg = cfg.wifi or { };
in
{
  imports = lib.optionals (cfg.enable or false) [
    ./users.nix
    ./printer.nix
    ./moonraker.nix
    ./mainsail.nix
    ./ap-fallback.nix
  ];

  config = lib.mkIf (cfg.enable or false) {
    system.activationScripts.klipper-wifi-profile = {
      text = ''
                profile=/etc/NetworkManager/system-connections/Beave_Net_IoT.nmconnection
                if [ -e "$profile" ]; then
                  exit 0
                fi

                mkdir -p /etc/NetworkManager/system-connections
                chmod 0755 /etc/NetworkManager/system-connections
                cat > "$profile" <<EOF
        [connection]
        id=Beave_Net_IoT
        uuid=0278899c-f325-4669-ad07-06abc09f893d
        type=wifi
        interface-name=wlan0
        autoconnect=true
        autoconnect-priority=100

        [wifi]
        mode=infrastructure
        ssid=${wifiCfg.ssid or ""}

        [wifi-security]
        auth-alg=open
        key-mgmt=wpa-psk
        psk=${wifiCfg.psk or ""}

        [ipv4]
        method=auto

        [ipv6]
        addr-gen-mode=default
        method=auto
        EOF
                chmod 0600 "$profile"
                ${config.systemd.package}/bin/systemctl try-restart NetworkManager || true
      '';
    };
  };
}
