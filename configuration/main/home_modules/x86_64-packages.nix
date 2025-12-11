# x86_64-specific Home Manager packages
{pkgs, ...}:
with pkgs; [
  # System monitoring with ROCm support
  btop-rocm

  # Hardware control tools
  ddcui
  openrgb-with-all-plugins

  # x86_64-specific packages can be added here
]
