{
  pkgs,
  config,
  system,
  lib,
  inputs,
  ...
}: let
  # Font configuration
  fontMain = "Rounded Mplus 1c Medium";
  fontMono = "JetBrainsMono Nerd Font";
  fuzzelFontSize = 14;
  kittyFontSize = 11;
  gtkFontSize = 11;

  gtkCss = ''
    * {
      font-family: "${fontMain}";
    }
  '';
in {
  # Application-specific font configurations (let stylix handle system theming)

  # Font configurations removed - let stylix handle all fonts
  
  # Note: Font configuration is now handled by stylix.nix
  # Font packages are centralized in stylix configuration
}
