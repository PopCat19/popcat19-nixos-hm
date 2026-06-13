# default.nix
#
# Purpose: Shared user configuration kernel merged with per-host overrides
#
# This module:
# - Combines per-concern defaults from sibling files
# - Applies host-specific overrides passed in `host`
# - Computes derived values (directories, git, env) from the merged result
# - Replaces the monolithic root user-config.nix and shallow `//` merging
{
  lib,
  host ? { },
}:
let
  base = lib.foldl' lib.recursiveUpdate { } [
    (import ./identity.nix)
    (import ./theme.nix)
    (import ./fonts.nix)
    (import ./default-apps.nix)
    (import ./agents.nix)
    (import ./gaming.nix)
    (import ./env.nix)
    (import ./features.nix)
  ];

  merged = lib.recursiveUpdate base host;

  inherit (merged) username;
  home = (merged.directories or { }).home or "/home/${username}";

  directories = {
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
    userName = merged.user.fullName;
    userEmail = merged.user.email;
    extraConfig = { };
  };

  env = lib.recursiveUpdate merged.env {
    NIXOS_CONFIG_DIR = "${home}/popcat19-nixos-hm";
  };
in
lib.recursiveUpdate merged {
  inherit directories git env;
}
