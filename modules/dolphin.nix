{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # File Manager
    kdePackages.dolphin
    
    # KDE Graphics and File Support
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kimageformats
    kdePackages.kio-extras
    kdePackages.gwenview
    kdePackages.okular
    kdePackages.ark
    
    # Thumbnail Support
    ffmpegthumbnailer
    poppler_utils
    libgsf
    webp-pixbuf-loader
  ];
}