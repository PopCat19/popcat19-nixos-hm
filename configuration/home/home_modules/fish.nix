{
  pkgs,
  userConfig,
  ...
}: {
  # Fish shell configuration
  programs.fish.enable = true;

  # Import fish functions and abbreviations
  imports = [./fish-functions.nix];

  # Fish configuration files
  # Manual theme files removed - let stylix handle fish shell theming
  # home.file.".config/fish/themes" = {
  #   source = ../fish_themes;
  #   recursive = true;
  # };
}
