# System core packages configuration

{ pkgs, ... }:

{
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