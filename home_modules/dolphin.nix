{ pkgs, config, ... }:

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

  # Dolphin file manager bookmarks
  home.file.".local/share/user-places.xbel".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE xbel PUBLIC "+//IDN python.org//DTD XML Bookmark Exchange Language 1.0//EN//XML" "http://www.python.org/topics/xml/dtds/xbel-1.0.dtd">
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
     <bookmark href="trash:/">
      <title>Trash</title>
     </bookmark>
    </xbel>
  '';

  # Dolphin configuration with enhanced thumbnails and better opacity
  home.file.".config/dolphinrc".text = ''
    [General]
    BrowseThroughArchives=true
    EditableUrl=false
    GlobalViewProps=false
    HomeUrl=file:///home/${config.home.username}
    ModifiedStartupSettings=true
    OpenExternallyCalledFolderInNewTab=false
    RememberOpenedTabs=true
    ShowFullPath=false
    ShowFullPathInTitlebar=false
    ShowSpaceInfo=false
    ShowZoomSlider=true
    SortingChoice=CaseSensitiveSorting
    SplitView=false
    UseTabForSwitchingSplitView=false
    Version=202
    ViewPropsTimestamp=2024,1,1,0,0,0
     [Qt]
     style=Kvantum

     [KFileDialog Settings]

    [KFileDialog Settings]
    Places Icons Auto-resize=false
    Places Icons Static Size=22

    [MainWindow]
    MenuBar=Disabled
    ToolBarsMovable=Disabled

    [PlacesPanel]
    IconSize=22

    [PreviewSettings]
    Plugins=appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,textthumbnail,ffmpegthumbs
    MaximumSize=10485760
    EnableRemoteFolderThumbnail=false
    MaximumRemoteSize=0

    [DesktopIcons]
    Size=48

    [CompactMode]
    PreviewSize=32

    [DetailsMode]
    PreviewSize=32

    [IconsMode]
    PreviewSize=64
  '';

  # KDE thumbnail configuration for better thumbnail support
  home.file.".config/kservices5/ServiceMenus/konsole.desktop".text = ''
    [Desktop Entry]
    Type=Service
    ServiceTypes=KonqPopupMenu/Plugin
    MimeType=inode/directory;
    Actions=konsole_here;

    [Desktop Action konsole_here]
    Name=Open Terminal Here
    Icon=utilities-terminal
    Exec=kitty --working-directory %f
  '';

  # Thumbnail cache update script
  home.file.".local/bin/update-thumbnails".text = ''
    #!/usr/bin/env bash

    # Clear thumbnail cache
    rm -rf ~/.cache/thumbnails/*

    # Update desktop database
    update-desktop-database ~/.local/share/applications 2>/dev/null || true

    # Update MIME database
    update-mime-database ~/.local/share/mime 2>/dev/null || true

    # Regenerate thumbnails for common directories by touching files
    find ~/Pictures ~/Downloads ~/Videos ~/Music -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" -o -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" \) -exec touch {} \; 2>/dev/null || true

    echo "Thumbnail cache cleared and databases updated"
  '';

  home.file.".local/bin/update-thumbnails".executable = true;

  # KDE Service Menu for terminal integration
  home.file.".local/share/kio/servicemenus/open-terminal-here.desktop".text = ''
    [Desktop Entry]
    Type=Service
    ServiceTypes=KonqPopupMenu/Plugin
    MimeType=inode/directory;
    Actions=openTerminalHere;

    [Desktop Action openTerminalHere]
    Name=Open Terminal Here
    Name[en_US]=Open Terminal Here
    Icon=utilities-terminal
    Exec=kitty --working-directory "%f"
  '';
}