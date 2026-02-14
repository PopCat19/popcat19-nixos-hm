# fonts.nix
#
# Purpose: Configure system fonts using centralized userConfig
#
# This module:
# - Installs core fonts and emoji support
# - Configures default fonts for each font category
# - Provides nerd fonts for terminal use
{
  pkgs,
  userConfig,
  ...
}:
{
  fonts = {
    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [
          "${userConfig.fonts.monospace.name}"
          "Noto Sans Mono"
        ];
        sansSerif = [
          "Rounded Mplus 1c Medium"
          "Noto Sans"
        ];
        serif = [
          "Rounded Mplus 1c Medium"
          "Noto Serif"
        ];
      };
      enable = true;
    };
    packages = with pkgs; [
      google-fonts
      nerd-fonts.${userConfig.fonts.monospace.packageName}
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];
  };
}
