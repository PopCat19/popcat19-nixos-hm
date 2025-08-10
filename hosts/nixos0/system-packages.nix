# System Packages Configuration for nixos0
# This file contains additional system packages beyond core dependencies
# Imported by hosts/nixos0/configuration.nix

{ pkgs, userConfig, ... }:

let
  # Architecture detection
  system = userConfig.host.system;
  isX86_64 = system == "x86_64-linux";
  isAarch64 = system == "aarch64-linux";
  
  # Architecture-specific packages
  x86_64Packages = with pkgs; [
    # ROCm packages (AMD GPU acceleration - x86_64 only)
    rocmPackages.rpp
    # Additional x86_64 specific packages for nixos0
    intel-gpu-tools
  ];
  
  aarch64Packages = with pkgs; [
    # ARM64-specific packages could go here
  ];
  
  # Virtualization packages (Full QEMU/KVM support for nixos0)
  virtualizationPackages = with pkgs; [
    docker
    qemu
    virt-manager
    libvirt
    OVMF
  ];

in
{
  # **ADDITIONAL SYSTEM PACKAGES**
  # Non-essential packages for enhanced system functionality
  environment.systemPackages = with pkgs; [
    # Package management (universal)
    flatpak-builder
    
    # Network tools (universal)
    protonvpn-gui
    wireguard-tools
    
    # Hardware tools (universal)
    i2c-tools
    ddcutil
    usbutils
    
    # Development tools (universal)
    python313Packages.pip
    gh
    
    # Quick tools (universal)
    quickgui
    quickemu
    
    # Build server specific tools
    htop
    iotop
    nethogs

    # Music
    zrythm
  ]
  # Add virtualization packages
  ++ virtualizationPackages
  # Add architecture-specific packages
  ++ (if isX86_64 then x86_64Packages else [])
  ++ (if isAarch64 then aarch64Packages else []);
}