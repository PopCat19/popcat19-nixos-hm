{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpegthumbnailer
    poppler_utils
    libgsf
    webp-pixbuf-loader
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kimageformats
    kdePackages.kio-extras
    kdePackages.gwenview
    kdePackages.okular
    kdePackages.ark
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