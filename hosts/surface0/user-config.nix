# user-config.nix
#
# Purpose: User configuration specific to the surface0 host
#
# This module:
# - Defines system and hostname for this host
# - Specifies which profile preset to use
# - Contains all user-configurable variables
rec {
  system = "x86_64-linux";
  hostname = "popcat19-surface0";
  username = "popcat19";
  profile = "surface";

  user = {
    fullName = "PopCat19";
    email = "atsuo11111@gmail.com";
    shell = "fish";

    extraGroups = [
      "audio"
      "docker"
      "i2c"
      "input"
      "libvirtd"
      "networkmanager"
      "surface-control"
      "video"
      "wheel"
    ];
  };

  defaultApps = {
    browser = {
      desktop = "zen-twilight.desktop";
      package = "zen-browser";
      command = "zen-twilight";
    };

    terminal = {
      desktop = "kitty.desktop";
      package = "kitty";
      command = "kitty";
    };

    editor = {
      desktop = "micro.desktop";
      package = "micro";
      command = "micro";
    };

    fileManager = {
      desktop = "org.kde.dolphin.desktop";
      package = "kdePackages.dolphin";
      command = "dolphin";
    };

    imageViewer = {
      desktop = "org.kde.gwenview.desktop";
      package = "kdePackages.gwenview";
    };

    videoPlayer = {
      desktop = "mpv.desktop";
      package = "mpv";
    };

    archiveManager = {
      desktop = "org.kde.ark.desktop";
      package = "kdePackages.ark";
    };

    pdfViewer = {
      desktop = "org.kde.okular.desktop";
      package = "kdePackages.okular";
    };

    launcher = {
      desktop = "vicinae.desktop";
      package = "vicinae";
      command = "vicinae";
    };
  };

  directories =
    let
      home = "/home/${username}";
    in
    {
      inherit home;
      desktop = "${home}/Desktop";
      documents = "${home}/Documents";
      downloads = "${home}/Downloads";
      music = "${home}/Music";
      pictures = "${home}/Pictures";
      syncthing = "${home}/syncthing-shared";
      videos = "${home}/Videos";
    };

  git = {
    userName = user.fullName;
    userEmail = user.email;
    extraConfig = { };
  };

  theme = {
    hue = 345;
    variant = "dark";
  };

  fonts = {
    monospace = {
      packageName = "fira-code";
      name = "FiraCode Nerd Font";
      size = 10;
    };

    sansSerif = {
      packageName = "google-fonts";
      name = "Rounded Mplus 1c Medium";
    };

    serif = {
      packageName = "noto-fonts";
      name = "Noto Serif";
    };

    emoji = {
      packageName = "noto-fonts-color-emoji";
      name = "Noto Color Emoji";
    };
  };
}
