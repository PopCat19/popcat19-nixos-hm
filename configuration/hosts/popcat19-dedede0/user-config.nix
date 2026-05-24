# user-config.nix
#
# Purpose: Host-specific overrides for dedede0 (shimboot)
let
  base = import ../../user-config.nix;
  home = "/home/nixos-user";
in
base // {
  system = "x86_64-linux";
  hostname = "popcat19-dedede0";
  username = "nixos-user";
  profile = "shimboot";
  board = "dedede";

  host = {
    inherit (base) hostname system;
    board = "dedede";
  };

  timezone = "America/New_York";
  locale = "en_US.UTF-8";

  user = {
    fullName = "PopCat19";
    email = "atsuo11111@gmail.com";
    shell = "fish";
    shellPackage = "fish";
    initialPassword = "popcat19";
    extraGroups = [
      "audio"
      "docker"
      "i2c"
      "input"
      "libvirtd"
      "networkmanager"
      "video"
      "wheel"
    ];
  };

  directories =
    let h = home;
    in {
      home = h;
      desktop = "${h}/Desktop";
      documents = "${h}/Documents";
      downloads = "${h}/Downloads";
      music = "${h}/Music";
      pictures = "${h}/Pictures";
      syncthing = "${h}/syncthing-shared";
      videos = "${h}/Videos";
    };

  env = {
    repoName = "popcat19-nixos-hm";
    NIXOS_CONFIG_DIR = "${home}/popcat19-nixos-hm";
  };
}
