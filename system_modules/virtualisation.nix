{ pkgs, userConfig, ... }:

let
  # Architecture detection
  system = userConfig.host.system;
  isX86_64 = system == "x86_64-linux";
  isAarch64 = system == "aarch64-linux";
  
  # Architecture-specific QEMU package selection
  qemuPackage = if isX86_64 then pkgs.qemu_kvm else pkgs.qemu;
  
  # Architecture-specific OVMF packages
  ovmfPackages = if isX86_64 then
    [ pkgs.OVMFFull.fd ]
  else if isAarch64 then
    [ pkgs.OVMF.fd ] # ARM64 OVMF
  else
    [ ];

in
{
  # **VIRTUALISATION CONFIGURATION**
  # Defines Docker, libvirt, and other virtualisation settings.
  virtualisation = {
    # Waydroid (Android emulation) - works on both architectures
    waydroid.enable = true;
    
    # Docker - universal support
    docker.enable = true;
    
    # libvirt/QEMU - architecture-specific configuration
    libvirtd.enable = true;
    libvirtd.qemu = {
      package = qemuPackage; # KVM on x86_64, regular QEMU on ARM64
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = (ovmfPackages != []);
        packages = ovmfPackages;
      };
    };
    
    # SPICE USB redirection - universal support
    spiceUSBRedirection.enable = true;
  };
}