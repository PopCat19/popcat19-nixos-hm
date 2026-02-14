# kde-apps.nix
#
# Purpose: Configure KDE applications without desktop environment
#
# This module:
# - Installs Dolphin file manager and related utilities
# - Configures thumbnailers for various file types
# - Sets up Dolphin bookmarks
{
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    kdePackages.dolphin
    kdePackages.ark
    unrar
    kdePackages.gwenview
    kdePackages.okular

    kdePackages.kdegraphics-thumbnailers
    kdePackages.kimageformats
    kdePackages.kio-extras

    ffmpegthumbnailer
    poppler-utils
    libgsf
    webp-pixbuf-loader

    kdePackages.kdialog
    kdePackages.keditbookmarks
    kdePackages.kleopatra
  ];

  home.file.".local/share/user-places.xbel".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE xbel PUBLIC "+//IDN pyxml.sourceforge.net//DTD XML Bookmark Exchange Language 1.0//EN//XML" "http://pyxml.sourceforge.net/topics/dtds/xbel-1.0.dtd">
    <xbel version="1.0">
     <bookmark href="file:///home/${config.home.username}">
      <title>Home</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/Desktop">
      <title>Desktop</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/Documents">
      <title>Documents</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/Downloads">
      <title>Downloads</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/Pictures">
      <title>Pictures</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/Music">
      <title>Music</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/Videos">
      <title>Videos</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/syncthing-shared">
      <title>Syncthing Shared</title>
     </bookmark>
     <bookmark href="file:///home/${config.home.username}/nixos-config">
      <title>nixos-config</title>
     </bookmark>
     <bookmark href="trash://">
      <title>Trash</title>
     </bookmark>
    </xbel>
  '';
}
