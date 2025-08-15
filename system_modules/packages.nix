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
  
  # Virtualization packages moved to system_modules/virtualisation.nix
  # See system_modules/virtualisation.nix for virtualization-related packages

in
{
  # Additional system packages
  environment.systemPackages = with pkgs; [
    # Network tools
    wireguard-tools
    
    # Hardware tools
    i2c-tools
    ddcutil
    usbutils
    util-linux
    e2fsprogs
    eza

    # Development tools
    python313Packages.pip
    gh
    unzip
    
    # Applications
    vicinae  # High-performance native launcher for Linux
  ]
  ++ (if isX86_64 then x86_64Packages else [])
  ++ (if isAarch64 then aarch64Packages else []);
}
