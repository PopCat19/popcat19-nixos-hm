# System Packages Configuration
# This file contains additional system packages beyond core dependencies
# Imported by configuration.nix

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
  ];
  
  aarch64Packages = with pkgs; [
    # ARM64-specific packages could go here
  ];
  
  # Virtualization packages (architecture-specific)
  virtualizationPackages = with pkgs; [
    docker
    spice-gtk
    win-virtio
    win-spice
    virt-manager
    libvirt
  ] ++ (if isX86_64 then [
    qemu  # Full QEMU support on x86_64
  ] else [
    qemu  # QEMU also works on ARM64, but with different capabilities
  ]);

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
  ]
  # Add virtualization packages
  ++ virtualizationPackages
  # Add architecture-specific packages
  ++ (if isX86_64 then x86_64Packages else [])
  ++ (if isAarch64 then aarch64Packages else []);
}