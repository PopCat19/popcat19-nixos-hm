{ pkgs, userConfig, ... }:

let
  # Architecture detection
  system = userConfig.host.system;
  isX86_64 = system == "x86_64-linux";
  isAarch64 = system == "aarch64-linux";
  
  # Architecture-specific QEMU package
  qemuPackage = if isX86_64 then pkgs.qemu_kvm else pkgs.qemu;
  
  # Architecture-specific OVMF packages
  ovmfPackages = if isX86_64 then
    [ pkgs.OVMFFull.fd ]
  else if isAarch64 then
    [ pkgs.OVMF.fd ]
  else
    [ ];
 
  # Virtualization-related packages (moved here)
  virtualizationPackages = with pkgs; [
    docker
    spice-gtk
    win-virtio
    win-spice
    virt-manager
    libvirt
    qemu
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

  # Add virtualization packages and quick tools to systemPackages
  environment.systemPackages = with pkgs; virtualizationPackages ++ [ quickgui quickemu ];
}