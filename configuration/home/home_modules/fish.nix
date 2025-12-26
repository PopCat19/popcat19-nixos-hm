{
  pkgs,
  userConfig,
  ...
}: {
  # Fish shell configuration
  programs.fish.enable = true;

  # Import fish functions and abbreviations
  imports = [./fish-functions.nix];

  # Fish configuration
  # Theming is handled by stylix
}
