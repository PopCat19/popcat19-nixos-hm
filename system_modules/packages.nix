# System packages configuration

{ pkgs, userConfig, ... }:

let
  # Architecture detection
  system = userConfig.host.system;
  isX86_64 = system == "x86_64-linux";
  isAarch64 = system == "aarch64-linux";
  
  # Architecture-specific packages
  x86_64Packages = with pkgs; [
    rocmPackages.rpp  # AMD GPU acceleration
  ];
  
  aarch64Packages = with pkgs; [
    # ARM64-specific packages
  ];
  
  # Virtualization packages
  virtualizationPackages = with pkgs; [
    docker
    spice-gtk
    win-virtio
    win-spice
    virt-manager
    libvirt
  ] ++ (if isX86_64 then [
    qemu
  ] else [
    qemu
  ]);

in
{
  # Additional system packages
  environment.systemPackages = with pkgs; [
    # Package management
    flatpak-builder
    
    # Network tools
    protonvpn-gui
    wireguard-tools
    
    # Hardware tools
    i2c-tools
    ddcutil
    usbutils
    util-linux
    e2fsprogs

    # Development tools
    python313Packages.pip
    gh
    
    # Quick tools
    quickgui
    quickemu
  ]
  ++ virtualizationPackages
  ++ (if isX86_64 then x86_64Packages else [])
  ++ (if isAarch64 then aarch64Packages else []);
}