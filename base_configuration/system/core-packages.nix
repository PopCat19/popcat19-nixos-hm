# core-packages.nix
#
# Purpose: Install essential system utilities and tools
#
# This module:
# - Provides core command-line utilities
# - Installs system utilities for desktop integration
# - Enables PolicyKit authentication agent
# - Provides modern shell prompt
{ lib, pkgs, ... }:
{
  environment.systemPackages = lib.mkDefault (with pkgs; [
    curl
    fuse
    git
    micro
    shared-mime-info
    starship
    vim
    wget
    xdg-utils
  ]);
}
