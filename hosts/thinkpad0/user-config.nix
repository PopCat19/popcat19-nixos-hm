# thinkpad0 Host User Configuration
#
# Purpose: User configuration specific to the thinkpad0 host
# Dependencies: None (standalone configuration)
# Related: hosts/thinkpad0/configuration.nix
#
# This module:
# - Defines system and hostname for this host
# - Specifies which profile preset to use (laptop)
# - Contains all user-configurable variables
rec {
  system = "x86_64-linux";
  hostname = "popcat19-thinkpad0";
  username = "popcat19";
  profile = "laptop";

  # User credentials
  user = {
    fullName = "PopCat19";
    email = "atsuo11111@gmail.com";
    shell = "fish";

    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
      "i2c"
      "input"
      "libvirtd"
      "docker"
    ];
  };

  # Default applications
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

  # System directories
  directories =
    let
      home = "/home/${username}";
    in
    {
      inherit home;
      documents = "${home}/Documents";
      downloads = "${home}/Downloads";
      pictures = "${home}/Pictures";
      videos = "${home}/Videos";
      music = "${home}/Music";
      desktop = "${home}/Desktop";
      syncthing = "${home}/syncthing-shared";
    };

  # Git configuration
  git = {
    userName = user.fullName;
    userEmail = user.email;
    extraConfig = { };
  };

  # Theme configuration for PMD
  theme = {
    hue = 345;
    variant = "dark";
  };

  # Font configuration
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
