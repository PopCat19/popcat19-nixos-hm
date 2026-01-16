# Core Packages Module
#
# Purpose: Install essential system utilities and tools
# Dependencies: polkit_gnome, vim, micro, wget, curl, git, xdg-utils, shared-mime-info, fuse, starship
# Related: packages.nix, services.nix
#
# This module:
# - Provides core command-line utilities (vim, micro, wget, curl, git)
# - Installs system utilities for desktop integration (xdg-utils, shared-mime-info)
# - Enables PolicyKit authentication agent for GUI applications (polkit_gnome)
# - Provides modern shell prompt (starship)
{pkgs, ...}: {
  # Core system packages
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    micro
    wget
    curl
    git

    # System utilities
    xdg-utils
    shared-mime-info
    fuse

    # Shell
    starship
  ];
}
