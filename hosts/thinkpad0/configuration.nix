# NixOS Configuration for thinkpad0
{
  pkgs,
  inputs,
  lib,
  userConfig,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../base-configuration/configuration.nix
    ../../main-configuration/configuration.nix
    ./system_modules/hardware.nix
    ./system_modules/zram.nix
  ];

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

  # Disable autologin for thinkpad0 (override from display module)
  services.displayManager.autoLogin.enable = lib.mkForce false;
}
