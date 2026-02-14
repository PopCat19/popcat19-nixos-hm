# fcitx5.nix
#
# Purpose: Configure fcitx5 input method framework with Japanese support
#
# This module:
# - Enables fcitx5 with Mozc for Japanese input
# - Configures Rose Pine theme for UI consistency
# - Links theme files to user directory
{ pkgs, ... }:
let
  font = "Rounded Mplus 1c Medium 11";
  themeSource = "${pkgs.fcitx5-rose-pine}/share/fcitx5/themes";
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-mozc
      fcitx5-rose-pine
      libsForQt5.fcitx5-qt
    ];
  };

  home.file = {
    ".config/fcitx5/conf/classicui.conf".text = ''
      Vertical Candidate List=False
      PerScreenDPI=True
      WheelForPaging=True
      Font="${font}"
      MenuFont="${font}"
      TrayFont="${font}"
      TrayOutlineColor=#000000
      TrayTextColor=#ffffff
      PreferTextIcon=False
      ShowLayoutNameInIcon=True
      UseInputMethodLangaugeToDisplayText=True
      Theme=rose-pine
      DarkTheme=rose-pine
      UseDarkTheme=True
      UseAccentColor=True
      EnableTray=True
      ShowPreeditInApplication=False
    '';

    ".local/share/fcitx5/themes/rose-pine".source = "${themeSource}/rose-pine";
    ".local/share/fcitx5/themes/rose-pine-dawn".source = "${themeSource}/rose-pine-dawn";
    ".local/share/fcitx5/themes/rose-pine-moon".source = "${themeSource}/rose-pine-moon";
  };
}
