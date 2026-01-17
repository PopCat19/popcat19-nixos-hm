{
  pkgs,
  userConfig,
  ...
}:
{
  # Fonts configuration using centralized userConfig
  fonts.packages = with pkgs; [
    # Core fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts

    # Fonts used by applications
    google-fonts # Contains M+ Outline Fonts (Rounded Mplus 1c)
    nerd-fonts.${userConfig.fonts.monospace.packageName}
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
        "${userConfig.fonts.monospace.name}"
        "Noto Sans Mono"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
