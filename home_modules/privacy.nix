# Privacy and security tools configuration

{ pkgs, ... }:

{
  # KeePassXC - Offline password manager
  home.packages = with pkgs; [
    keepassxc
  ];
}