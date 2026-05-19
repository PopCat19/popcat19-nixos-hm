# user-config.nix
#
# Purpose: User configuration for nix-on-droid (Android)
rec {
  system = "aarch64-linux";
  hostname = "nix-on-droid";
  username = "nix-on-droid";
  profile = "nix-on-droid";

  user = {
    fullName = "PopCat19";
    email = "atsuo11111@gmail.com";
    shell = "fish";
    shellPackage = "fish";

    extraGroups = [ ];
  };

  directories =
    let
      home = "/data/data/com.termux.nix/files/home";
    in
    {
      inherit home;
      documents = "${home}/Documents";
      downloads = "${home}/Downloads";
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

  env = {
    repoName = "popcat19-nixos-hm";
    NIXOS_CONFIG_DIR = "${directories.home}/popcat19-nixos-hm";
  };
}
