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
  # GTK configuration moved to Stylix - Stylix handles GTK theming automatically

  # Qt6 configuration moved to Stylix - Stylix handles Qt theming automatically

  # dconf font settings moved to Stylix - Stylix handles GNOME interface settings automatically

  # Kitty font configuration moved to Stylix - Stylix handles all font theming
  programs.kitty.font = {
    name = fontMono;
    # Note: size is now controlled by Stylix for consistency
  };

  # Fuzzel font configuration moved to Stylix - Stylix handles all fuzzel theming
  # programs.fuzzel.settings.main.font = "${fontMain}:size=${builtins.toString fuzzelFontSize}";

  home.file.".config/fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>${fontMain}</family>
        </prefer>
      </alias>
      <alias>
        <family>${fontMain}</family>
        <default>
          <family>sans-serif</family>
        </default>
      </alias>
    </fontconfig>
  '';

  home.packages = with pkgs; [
    google-fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.fantasque-sans-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
  ];
}
