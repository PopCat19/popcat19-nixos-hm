# Surface-specific Virtualisation Configuration
# This file overrides the system-wide virtualisation.nix to disable QEMU/KVM
# while keeping Waydroid for Android emulation

{ pkgs, userConfig, ... }:

{
  # **VIRTUALISATION CONFIGURATION**
  # Surface-specific: Only Waydroid and Docker, no QEMU/KVM
  virtualisation = {
    # Waydroid (Android emulation) - keep this enabled
    waydroid.enable = true;
    
    # Docker - keep this enabled
    docker.enable = true;
  };
}