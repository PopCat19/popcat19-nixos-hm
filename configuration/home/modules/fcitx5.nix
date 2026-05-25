# fcitx5.nix
#
# Purpose: Configure fcitx5 input method framework with Japanese support
#
# This module:
# - Enables fcitx5 with Mozc for Japanese input
# - Configures Rose Pine theme for UI consistency
# - Links theme files to user directory
{ lib, pkgs, ... }:
let
  font = "Rounded Mplus 1c Medium 11";
  themeSource = "${pkgs.fcitx5-rose-pine}/share/fcitx5/themes";
in
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-gtk
        fcitx5-mozc
        fcitx5-rose-pine
        libsForQt5.fcitx5-qt
      ];
      # Persist mozc in the default input method group across logins.
      # Without this, fcitx5 starts fresh each session and mozc must be
      # re-added via the GUI.
      settings = {
        inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "mozc";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
            Layout = null;
          };
          "Groups/0/Items/1" = {
            Name = "mozc";
            Layout = null;
          };
        };
        addons = {
          classicui.globalSection = {
            "Vertical Candidate List" = "False";
            PerScreenDPI = "True";
            WheelForPaging = "True";
            Font = lib.mkForce "${font}";
            MenuFont = "${font}";
            TrayFont = "${font}";
            TrayOutlineColor = "#000000";
            TrayTextColor = "#ffffff";
            PreferTextIcon = "False";
            ShowLayoutNameInIcon = "True";
            UseInputMethodLangaugeToDisplayText = "True";
            Theme = "rose-pine";
            DarkTheme = "rose-pine";
            UseDarkTheme = "True";
            UseAccentColor = "True";
            EnableTray = "True";
            ShowPreeditInApplication = "False";
          };
        };
      };
    };
  };

  home.file = {
    ".local/share/fcitx5/themes/rose-pine".source = "${themeSource}/rose-pine";
    ".local/share/fcitx5/themes/rose-pine-dawn".source = "${themeSource}/rose-pine-dawn";
    ".local/share/fcitx5/themes/rose-pine-moon".source = "${themeSource}/rose-pine-moon";
  };
}
