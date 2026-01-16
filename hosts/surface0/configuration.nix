# NixOS Configuration for surface0
{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../configuration/system/main.nix
    ./system_modules/clear-bdprochot.nix
    ./system_modules/thermal-config.nix
    ./system_modules/boot.nix
    ./system_modules/hardware.nix
  ];

  networking.hostName = "popcat19-surface0";
}
