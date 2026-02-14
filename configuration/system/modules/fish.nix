# fish.nix
#
# Purpose: Configure Fish shell as the default system shell
#
# This module:
# - Installs Fish shell as system package
# - Configures Fish as default shell for users
# - Imports global Fish functions and configuration
{ pkgs, ... }:
{
  imports = [
    ./fish-functions.nix
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
}
