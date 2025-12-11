# x86_64-specific system packages
{pkgs, ...}:
with pkgs; [
  # AMD GPU acceleration
  rocmPackages.rpp

  # x86_64-specific system packages can be added here
]
