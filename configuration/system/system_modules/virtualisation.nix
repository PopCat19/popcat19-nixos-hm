# virtualisation.nix
#
# Purpose: Configure virtualization technologies including Docker and KVM
#
# This module:
# - Enables Docker and Docker Compose v2 for containerization
# - Configures KVM virtualization support
# - Sets up Docker daemon to start on boot
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    qemu_kvm
    spice
    spice-gtk
    spice-protocol
    virt-manager
    virt-viewer
    virtio-win
    win-spice
  ];

  programs.dconf.enable = true;
  programs.virt-manager.enable = true;

  virtualisation.docker = {
    autoPrune = {
      dates = "weekly";
      enable = true;
    };
    enable = true;
    enableOnBoot = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.waydroid.enable = false;
}
