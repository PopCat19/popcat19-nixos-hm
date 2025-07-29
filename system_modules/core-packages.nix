# System Core Packages Configuration
# This file contains essential system packages and dependencies
# Imported by configuration.nix

{ pkgs, ... }:

{
  # **CORE SYSTEM PACKAGES**
  # Essential packages required for basic system functionality
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