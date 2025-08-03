# nixos0-specific Virtualisation Configuration
# This file provides full virtualization support for the build server
# including QEMU/KVM, Docker, and Waydroid

{ pkgs, userConfig, ... }:

{
  # **VIRTUALISATION CONFIGURATION**
  # nixos0-specific: Full virtualization support for build server
  virtualisation = {
    # Waydroid (Android emulation)
    waydroid.enable = true;
    
    # Docker - essential for containerized builds
    docker.enable = true;
    
    # Enable libvirt/QEMU for full VM support
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMF.fd ];
        };
      };
    };
    
    # Enable SPICE USB redirection for VM management
    spiceUSBRedirection.enable = true;
  };

  # Add user to libvirtd group for VM management
  users.users.${userConfig.user.username}.extraGroups = [ "libvirtd" ];
}