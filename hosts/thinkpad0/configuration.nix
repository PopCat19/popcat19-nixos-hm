# NixOS Configuration for thinkpad0
{lib, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../configuration/system/main.nix
    ./system_modules/hardware.nix
    ./system_modules/zram.nix
  ];

  networking.hostName = "popcat19-thinkpad0";

  # NixOS release version
  system.stateVersion = "25.11";

  # Disable autologin for thinkpad0 (override from display module)
  services.displayManager.autoLogin.enable = lib.mkForce false;
}
