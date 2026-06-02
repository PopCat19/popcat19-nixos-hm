# user-config.nix
#
# Purpose: Global user configuration variables shared across NixOS hosts
#
# This module:
# - Defines shared defaults for all hosts (apps, directories, git, theme, fonts, env)
# - Host-specific user-config.nix files import this with `//` to override
rec {
  username = "popcat19";

  user = {
    inherit username;
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
      desktop = "fuzzel.desktop";
      package = "fuzzel";
      command = "fuzzel";
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

  agents = {
    enable = false;
    kilocode-cli = false;
    opencode = false;
    pi = false;
  };

  env = {
    repoName = "popcat19-nixos-hm";
    NIXOS_CONFIG_DIR = "/home/${username}/popcat19-nixos-hm";
  };
}
