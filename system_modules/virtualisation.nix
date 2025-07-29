{ pkgs, ... }:

{
  # **VIRTUALISATION CONFIGURATION**
  # Defines Docker, libvirt, and other virtualisation settings.
  virtualisation = {
    waydroid.enable = true;
    docker.enable = true;
    libvirtd.enable = true;
    libvirtd.qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
}