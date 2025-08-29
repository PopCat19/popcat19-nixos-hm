{ pkgs, userConfig, ... }:

let
  # Architecture detection
  system = userConfig.host.system;
  isX86_64 = system == "x86_64-linux";

  # Architecture-specific QEMU package
  qemuPackage = pkgs.qemu_kvm;

  # Architecture-specific OVMF packages
  ovmfPackages = [ pkgs.OVMFFull.fd ];
 
  # Virtualization-related packages (moved here)
  virtualizationPackages = with pkgs; [
    docker
    spice-gtk
    win-virtio
    win-spice
    virt-manager
    libvirt
    qemu
    quickgui
    quickemu
  ];
 
in
{
  # Virtualisation configuration
  virtualisation = {
    # Waydroid (Android emulation)
    waydroid.enable = true;
    
    # Docker
    docker.enable = true;
    
    # libvirt/QEMU
    libvirtd.enable = true;
    libvirtd.qemu = {
      package = qemuPackage;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = (ovmfPackages != []);
        packages = ovmfPackages;
      };
    };
    
    # SPICE USB redirection
    spiceUSBRedirection.enable = true;
  };

  # Add virtualization-related packages to systemPackages (quick tools included above)
  environment.systemPackages = virtualizationPackages;
}