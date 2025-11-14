{pkgs, ...}: {
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    supportedFilesystems = ["ntfs"];
    kernelPackages = pkgs.linuxPackages_cachyos;
    kernelModules = ["i2c-dev"];
    blacklistedKernelModules = ["snd_seq_dummy"];
  };
}
