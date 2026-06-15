# fish.nix
#
# Purpose: Deploy user fish shell functions from the central fish_functions directory
#
# This module:
# - Sets fish-specific environment variables (NIXOS_CONFIG_DIR, hostname)
# - Deploys all .fish function files to ~/.config/fish/functions/
# - Adds fish_greeting hook and starship init as user-level shellInit
# - Includes fastfetch for fish-greeting.fish
#
# Note: This is the HOME-MANAGER fish module, distinct from the system-level
# fish-functions.nix that deploys to /etc/fish/functions/. Both are safe to
# load simultaneously: user paths take precedence in fish_function_path.
{ pkgs, userConfig, ... }:
{
  programs.fish = {
    shellInit = ''
      set -gx NIXOS_CONFIG_DIR ${userConfig.env.NIXOS_CONFIG_DIR}
      set -gx NIXOS_FLAKE_HOSTNAME ${userConfig.hostname}
    '';
  };

  home.file.".config/fish/functions" = {
    source = ../../fish_functions;
    recursive = true;
  };

  home.packages = [ pkgs.fastfetch ];
}
