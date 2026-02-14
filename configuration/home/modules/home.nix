# home.nix
#
# Purpose: Configure home activation scripts for directory creation
#
# This module:
# - Creates Syncthing directories on home activation
{
  lib,
  userConfig,
  ...
}:
let
  syncthingPaths = {
    shared = userConfig.directories.syncthing;
    passwords = "${userConfig.directories.home}/Passwords";
    dataDir = "${userConfig.directories.home}/.local/share/syncthing";
    configDir = "${userConfig.directories.home}/.config/syncthing";
  };
in
{
  home.activation.createSyncthingDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${syncthingPaths.shared}
    mkdir -p ${syncthingPaths.dataDir}
    mkdir -p ${syncthingPaths.passwords}
  '';
}
