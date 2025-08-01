{ pkgs, ... }:

{
  home.packages = with pkgs; [
    appstream
    git-lfs
    jq
    tree
    pureref
    grim
    slurp
    wtype
    hyprpicker
    hyprls
    mangayomi
    ollama-rocm
    appimage-run
  ];
}