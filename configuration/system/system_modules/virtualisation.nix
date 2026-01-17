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
{ pkgs, ... }:
{
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
