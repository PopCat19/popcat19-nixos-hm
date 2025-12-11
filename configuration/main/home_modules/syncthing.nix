{
  pkgs,
  config,
  lib,
  userConfig,
  ...
}: let
  # Syncthing configuration constants
  syncthingUser = userConfig.user.username;
  syncthingPaths = {
    shared = userConfig.directories.syncthing;
    passwords = "${userConfig.directories.home}/Passwords";
    dataDir = "${userConfig.directories.home}/.local/share/syncthing";
    configDir = "${userConfig.directories.home}/.config/syncthing";
  };
in {
  # User-level directory creation and configuration
  home.activation.createSyncthingDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${syncthingPaths.shared}
    mkdir -p ${syncthingPaths.dataDir}
    mkdir -p ${syncthingPaths.passwords}
  '';
}
