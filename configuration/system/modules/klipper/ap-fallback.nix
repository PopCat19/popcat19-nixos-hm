# ap-fallback.nix
#
# Purpose: Fallback access point for headless Klipper Pi setup
#
# This module:
# - Declares a NetworkManager AP profile for initial setup / recovery
# - Provides an agenix-backed WPA2 PSK (not stored in the Nix store)
# - Runs a systemd timer that brings up the AP if the client WiFi never connects
# - Installs fish functions klipper_ap_on / klipper_ap_off for manual toggling
{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:
let
  cfg = userConfig.klipper or { };
  ap = cfg.ap or { };
  apEnabled = ap.enable or true;

  apSsid = ap.ssid or "Klipper-Setup";
  apSubnet = ap.subnet or "192.168.50.1/24";

  clientProfile = "Beave_Net_IoT";
  apProfile = "Klipper-Setup";
  apUuid = "9c7a3e6b-8f2d-4e1a-9d5c-2b4f6a8c0e12";

  mkFishFunction = path: text: {
    "fish/functions/${path}".text = text;
  };

  apOnBody = ''
    function klipper_ap_on
        echo -n "Bringing up Klipper setup AP... "
        ${config.systemd.package}/bin/systemctl stop klipper-ap-fallback.timer 2>/dev/null || true
        if sudo ${pkgs.networkmanager}/bin/nmcli connection down ${clientProfile} 2>/dev/null; end
        if sudo ${pkgs.networkmanager}/bin/nmcli connection up ${apProfile}
            set_color green; echo "[OK]"; set_color normal
            echo "Connect to '${apSsid}' and SSH to ${apSubnet}"
        else
            set_color red; echo "[FAIL]"; set_color normal
            return 1
        end
    end
  '';

  apOffBody = ''
    function klipper_ap_off
        echo -n "Switching back to client WiFi... "
        ${config.systemd.package}/bin/systemctl start klipper-ap-fallback.timer 2>/dev/null || true
        if sudo ${pkgs.networkmanager}/bin/nmcli connection down ${apProfile} 2>/dev/null; end
        if sudo ${pkgs.networkmanager}/bin/nmcli connection up ${clientProfile}
            set_color green; echo "[OK]"; set_color normal
        else
            set_color yellow; echo "[RETRY] will fall back to AP if no connection"; set_color normal
            return 1
        end
    end
  '';
in
{
  config = lib.mkIf (cfg.enable or false && apEnabled && config.age.secrets ? klipper-ap-psk) (
    lib.mkMerge [
      {
        networking.networkmanager.ensureProfiles = {
          profiles.${apProfile} = {
            connection = {
              id = apProfile;
              uuid = apUuid;
              type = "wifi";
              interface-name = "wlan0";
              autoconnect = false;
            };
            wifi = {
              mode = "ap";
              band = "bg";
              channel = 6;
              ssid = apSsid;
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
              psk-flags = 1;
            };
            ipv4 = {
              method = "manual";
              addresses = apSubnet;
            };
            ipv6.method = "disabled";
          };

          secrets.entries = [
            {
              matchId = apProfile;
              matchType = "wifi";
              matchSetting = "802-11-wireless-security";
              key = "psk";
              file = config.age.secrets.klipper-ap-psk.path;
            }
          ];
        };

        systemd.services.klipper-ap-fallback = {
          description = "Klipper setup AP fallback";
          after = [ "NetworkManager.service" ];
          wants = [ "NetworkManager.service" ];
          startLimitBurst = 5;
          startLimitIntervalSec = 10;
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = false;
          };
          script = ''
            # Wait for NetworkManager to finish initial scans
            sleep 30

            # Already connected as a client: nothing to do
            if ${pkgs.networkmanager}/bin/nmcli connection show --active | ${pkgs.gnugrep}/bin/grep -q "${clientProfile}"; then
              exit 0
            fi

            # Already in AP mode: leave it up so the user can SSH in
            if ${pkgs.networkmanager}/bin/nmcli connection show --active | ${pkgs.gnugrep}/bin/grep -q "${apProfile}"; then
              exit 0
            fi

            # Try the client profile one more time
            ${pkgs.networkmanager}/bin/nmcli connection up "${clientProfile}" 2>/dev/null || true
            sleep 30

            if ${pkgs.networkmanager}/bin/nmcli connection show --active | ${pkgs.gnugrep}/bin/grep -q "${clientProfile}"; then
              exit 0
            fi

            # Fall back to setup AP
            ${pkgs.networkmanager}/bin/nmcli connection up "${apProfile}" || true
          '';
        };

        systemd.timers.klipper-ap-fallback = {
          description = "Periodically check Klipper client WiFi and fall back to AP";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "60";
            OnUnitActiveSec = "5m";
          };
        };

        environment.etc =
          mkFishFunction "klipper_ap_on.fish" apOnBody // mkFishFunction "klipper_ap_off.fish" apOffBody;

        security.sudo.extraRules = lib.optionals (userConfig ? username) [
          {
            users = [ userConfig.username ];
            commands = [
              {
                command = "/run/current-system/sw/bin/systemctl start klipper-ap-fallback.timer";
                options = [ "NOPASSWD" ];
              }
              {
                command = "/run/current-system/sw/bin/systemctl stop klipper-ap-fallback.timer";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];
      }
    ]
  );
}
