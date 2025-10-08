{
  pkgs,
  inputs,
  lib,
  ...
}: let
  thinkpadUserConfig = import ../../user-config.nix {hostname = "popcat19-thinkpad0";};
in {
  imports = [
    ./hardware-configuration.nix
    ./system_modules/power-management.nix
    ../../syncthing_config/system.nix
  ] ++ (import ../../system_modules/default.nix { });

  networking.hostName = "popcat19-thinkpad0";

  # Boot configuration for HDMI audio support
  boot = {
    kernelModules = ["snd_hda_intel" "snd_hda_codec_hdmi"];
    kernelParams = [
      "snd_hda_intel.enable=1"
      "snd_hda_intel.model=auto"
    ];
  };

  # Host-specific packages for audio management
  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
  ];

  # Disable Waydroid for thinkpad0 (override from virtualisation module)
  virtualisation.waydroid.enable = lib.mkForce false;

  system.stateVersion = "25.05";
}
