{ pkgs, ... }:

{
  # Fonts configuration
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    noto-fonts-extra
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [
        "Rounded Mplus 1c Medium"
        "Noto Serif"
      ];
      sansSerif = [
        "Rounded Mplus 1c Medium"
        "Noto Sans"
      ];
      monospace = [
        "JetBrainsMono Nerd Font"
        "Noto Sans Mono"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}