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
  ] ++ [
    ../../system_modules/core_modules/boot.nix
    ../../system_modules/core_modules/hardware.nix
    ../../system_modules/core_modules/networking.nix
    ../../system_modules/core_modules/users.nix
    ../../system_modules/localization.nix
    ../../system_modules/services.nix
    ../../system_modules/display.nix
    ../../system_modules/audio.nix
    ../../system_modules/virtualisation.nix
    ../../system_modules/programs.nix
    ../../system_modules/environment.nix
    ../../system_modules/core-packages.nix
    ../../system_modules/packages.nix
    ../../system_modules/fonts.nix
    ../../system_modules/tablet.nix
    # ../../system_modules/openrgb.nix  # Discarded for thinkpad0
    ../../system_modules/privacy.nix
    ../../system_modules/gnome-keyring.nix
    ../../system_modules/vpn.nix
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

  system.stateVersion = "25.05";
}
