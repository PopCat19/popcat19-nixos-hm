# System Packages Configuration
# This file contains additional system packages beyond core dependencies
# Imported by configuration.nix

{ pkgs, ... }:

{
  # **ADDITIONAL SYSTEM PACKAGES**
  # Non-essential packages for enhanced system functionality
  environment.systemPackages = with pkgs; [
    # Package management
    flatpak-builder
    
    # Network tools
    protonvpn-gui
    wireguard-tools
    
    # Virtualization
    docker
    spice-gtk
    win-virtio
    win-spice
    virt-manager
    libvirt
    qemu
    
    # Hardware tools
    i2c-tools
    ddcutil
    usbutils
    
    # Development tools
    python313Packages.pip
    gh
    
    # Gaming/Graphics
    rocmPackages.rpp
    
    # Quick tools
    quickgui
    quickemu
  ];
}