{
  pkgs,
  inputs,
  lib,
  ...
}: let
  nixos0UserConfig = import ../../user-config.nix {hostname = "popcat19-nixos0";};
in {
  imports = [
    ./hardware-configuration.nix
    ../../syncthing_config/system.nix
  ] ++ (import ../../system_modules/default.nix { });

  networking.hostName = "popcat19-nixos0";

  # Boot configuration for HDMI audio support
  boot = {
    kernelModules = ["snd_hda_intel" "snd_hda_codec_hdmi"];
    kernelParams = [
      "snd_hda_intel.enable=1"
      "snd_hda_intel.model=auto"
    ];
  };

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    zluda
    alsa-utils
    pavucontrol
  ];

  system.stateVersion = "25.05";
}
