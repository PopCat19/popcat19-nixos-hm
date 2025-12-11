# NixOS Configuration for nixos0
{
  pkgs,
  inputs,
  lib,
  userConfig,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    # ./github-runner/github-runner.nix - temporarily disabled
    ../../base-configuration/configuration.nix
    ../../main-configuration/configuration.nix
    inputs.jovian.nixosModules.default
  ];

  networking.hostName = "popcat19-nixos0";

  # Boot configuration for HDMI audio support
  boot = {
    kernelModules = ["snd_hda_intel" "snd_hda_codec_hdmi"];
    kernelParams = [
      "snd_hda_intel.enable=1"
      "snd_hda_intel.model=auto"
    ];
  };

  # Enable sched-ext (SCX) for CachyOS kernel
  services.scx.enable = true;

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    zluda
    alsa-utils
    pavucontrol
  ];
}
