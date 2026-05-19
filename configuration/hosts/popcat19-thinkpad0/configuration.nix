# configuration.nix
#
# Purpose: Main NixOS configuration for the thinkpad0 host
#
# This module:
# - Imports hardware configuration and profile preset
# - Applies host-specific modules and settings
{
  pkgs,
  lib,
  userConfig,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}.nix
    ./modules/hardware.nix
    ./modules/zram.nix
    ../../system/modules/agenix.nix
    ../../system/modules/builders.nix
    ../../system/modules/searxng.nix
    ../../system/modules/sunshine.nix
  ];

  networking.hostName = userConfig.hostname;

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  environment.etc."systemd/system-sleep/hyprlock.sh" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      export PATH=${pkgs.coreutils}/bin:${pkgs.gawk}/bin:${pkgs.systemd}/bin:${pkgs.hyprlock}/bin
      if [ "$1" = "pre" ]; then
        for uid in $(loginctl list-sessions --no-legend | awk '{print $2}'); do
          XDG_RUNTIME_DIR=/run/user/$uid hyprlock --immediate &
        done
        wait
      fi
    '';
  };

  services.displayManager.autoLogin.enable = lib.mkForce false;

  services.searxng-local.enable = true;
  services.open-webui.enable = true;

  environment.systemPackages = with pkgs; [
    bleachbit
    cachix
    moonlight-qt
    opentabletdriver
    protonplus
  ];
}
