# Virtualisation Module
#
# Purpose: Configure virtualization technologies including Docker and KVM
# Dependencies: docker, docker-compose
# Related: users.nix
#
# This module:
# - Enables Docker and Docker Compose v2 for containerization
# - Configures KVM virtualization support
# - Sets up Docker daemon to start on boot
{
  pkgs,
  userConfig,
  ...
}: let
  # Architecture detection
  system = userConfig.host.system;
  isX86_64 = system == "x86_64-linux";
in {
  # Docker and Docker Compose v2
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Waydroid (Android emulation) - disabled by default
  # To enable Waydroid on specific hosts, add:
  # virtualisation.waydroid.enable = true;
  virtualisation.waydroid.enable = false;

  # KVM virtualization support
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };
}
