# Fish Shell Configuration Module
#
# Purpose: Configure Fish shell as the default system shell with global functions
# Dependencies: fish, fish-plugins, fish-functions.nix
# Related: users.nix, core-packages.nix
#
# This module:
# - Installs Fish shell as system package
# - Configures Fish as default shell for users
# - Provides Fish plugin management
# - Imports global Fish functions and configuration
# - Sets up Fish environment system-wide
{pkgs, ...}: {
  imports = [
    ./fish-functions.nix
  ];

  # Install Fish shell
  environment.systemPackages = with pkgs; [
    fish
  ];

  # Configure Fish shell
  programs.fish = {
    enable = true;
    # Enable Fish's unified cursor behavior
    interactiveShellInit = ''
      # Set up basic Fish configuration
      set -g fish_greeting ""
    '';
  };

  # Set Fish as default shell (will be overridden by users.nix for user accounts)
  # This ensures Fish is available system-wide
}
