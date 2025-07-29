{ pkgs, config, lib, ... }:

{
  # XDG MIME Applications Configuration
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Web browsers
      "x-scheme-handler/http" = [ "zen-beta.desktop" ];
      "x-scheme-handler/https" = [ "zen-beta.desktop" ];
      "text/html" = [ "zen-beta.desktop" ];
      "application/xhtml+xml" = [ "zen-beta.desktop" ];

      # Terminal
      "application/x-terminal-emulator" = [ "kitty.desktop" ];
      "x-scheme-handler/terminal" = [ "kitty.desktop" ];

      # Text files
      "text/plain" = [ "micro.desktop" ];
      "text/x-readme" = [ "micro.desktop" ];
      "text/x-log" = [ "micro.desktop" ];
      "application/json" = [ "micro.desktop" ];
      "text/x-python" = [ "micro.desktop" ];
      "text/x-shellscript" = [ "micro.desktop" ];
      "text/x-script" = [ "micro.desktop" ];

      # Images
      "image/jpeg" = [ "org.kde.gwenview.desktop" ];
      "image/png" = [ "org.kde.gwenview.desktop" ];
      "image/gif" = [ "org.kde.gwenview.desktop" ];
      "image/webp" = [ "org.kde.gwenview.desktop" ];
      "image/svg+xml" = [ "org.kde.gwenview.desktop" ];

      # Videos
      "video/mp4" = [ "mpv.desktop" ];
      "video/mkv" = [ "mpv.desktop" ];
      "video/avi" = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];

      # Audio
      "audio/mpeg" = [ "mpv.desktop" ];
      "audio/ogg" = [ "mpv.desktop" ];
      "audio/wav" = [ "mpv.desktop" ];
      "audio/flac" = [ "mpv.desktop" ];

      # Archives
      "application/zip" = [ "org.kde.ark.desktop" ];
      "application/x-tar" = [ "org.kde.ark.desktop" ];
      "application/x-compressed-tar" = [ "org.kde.ark.desktop" ];
      "application/x-7z-compressed" = [ "org.kde.ark.desktop" ];

      # File manager
      "inode/directory" = [ "org.kde.dolphin.desktop" ];

      # PDF
      "application/pdf" = [ "org.kde.okular.desktop" ];
    };
    associations.added = {
      "application/x-terminal-emulator" = [ "kitty.desktop" ];
      "x-scheme-handler/terminal" = [ "kitty.desktop" ];
    };
  };

  # Additional GTK theme files for better consistency
  home.file.".config/gtk-3.0/bookmarks".text = ''
    file:///home/${config.home.username}/Documents Documents
    file:///home/${config.home.username}/Downloads Downloads
    file:///home/${config.home.username}/Pictures Pictures
    file:///home/${config.home.username}/Videos Videos
    file:///home/${config.home.username}/Music Music
    file:///home/${config.home.username}/syncthing-shared Syncthing Shared
    file:///home/${config.home.username}/Desktop Desktop
    trash:/// Trash
  '';

  # Additional desktop files for better integration
  home.file.".local/share/applications/kitty.desktop".text = ''
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Kitty
    GenericName=Terminal
    Comment=A modern, hackable, featureful, OpenGL-based terminal emulator
    TryExec=kitty
    Exec=kitty
    Icon=kitty
    Categories=System;TerminalEmulator;
    StartupNotify=true
    MimeType=application/x-terminal-emulator;x-scheme-handler/terminal;
  '';

  home.file.".local/share/applications/micro.desktop".text = ''
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Micro
    GenericName=Text Editor
    Comment=A modern and intuitive terminal-based text editor
    TryExec=micro
    Exec=micro %F
    Icon=text-editor
    Categories=Utility;TextEditor;Development;
    StartupNotify=false
    MimeType=text/plain;text/x-readme;text/x-log;application/json;text/x-python;text/x-shellscript;text/x-script;
    Terminal=true
  '';
}