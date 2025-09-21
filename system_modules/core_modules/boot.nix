{pkgs, ...}: {
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    supportedFilesystems = ["ntfs"];
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = ["i2c-dev"];
  };
}
