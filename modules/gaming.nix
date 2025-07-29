{ pkgs, ... }:

{
  home.packages = with pkgs; [
    obs-studio
    lutris
    osu-lazer-bin
    moonlight-qt
    pavucontrol
    playerctl
    glances
    ddcui
    openrgb-with-all-plugins
  ];
}