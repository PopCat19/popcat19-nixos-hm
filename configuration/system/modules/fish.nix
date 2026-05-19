# fish.nix
#
# Purpose: Configure Fish shell as the default system shell
#
# This module:
# - Installs Fish shell as system package
# - Configures Fish as default shell for users
# - Imports global Fish functions and configuration
{
  lib,
  pkgs,
  userConfig,
  ...
}:
{
  imports = [
    ./fish-functions.nix
    ./sing-box.nix
  ];

  environment.systemPackages = with pkgs; [
    fish
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting ""
    '';
  };

  # Set Fish as default shell for the user (force to override NixOS default)
  users.users.${userConfig.username}.shell = lib.mkForce pkgs.fish;
}
