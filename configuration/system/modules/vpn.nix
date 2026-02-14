# vpn.nix
#
# Purpose: Configure Mullvad VPN service for system-wide VPN
#
# This module:
# - Enables Mullvad VPN daemon service
# - Installs Mullvad VPN GUI for connection control
# - Configures auto-connect on boot
{
  lib,
  pkgs,
  ...
}:
let
  mullvadPackage = pkgs.mullvad-vpn;
in
{
  environment.systemPackages = [
    mullvadPackage
  ];

  services.mullvad-vpn = {
    enable = true;
    enableExcludeWrapper = lib.mkDefault false;
    package = mullvadPackage;
  };

  systemd.services.mullvad-autoconnect = {
    after = [
      "network-online.target"
      "mullvad-daemon.service"
    ];
    description = "Ensure Mullvad auto-connect is enabled";
    requires = [ "mullvad-daemon.service" ];
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.writeShellScript "mullvad-autoconnect.sh" ''
        set -euo pipefail
        for i in $(seq 1 30); do
          if ${mullvadPackage}/bin/mullvad status >/dev/null 2>&1; then
            break
          fi
          sleep 0.5
        done
        ${mullvadPackage}/bin/mullvad auto-connect set on
      ''}";
      TimeoutStartSec = 15;
      Type = "oneshot";
    };
  };
}
