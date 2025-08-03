{ pkgs, userConfig, ... }:

{
  # Fish shell configuration
  programs.fish.enable = true;
  
  # Import fish functions and abbreviations
  imports = [ ./fish-functions.nix ];

  # Fish configuration files
  home.file.".config/fish/themes" = {
    source = ../fish_themes;
    recursive = true;
  };
}