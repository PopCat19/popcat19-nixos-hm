# home.nix
#
# Purpose: Configure home activation scripts for directory creation
#
# This module:
# - Creates Syncthing directories on home activation
# - Cleans up broken symlinks from stale NixOS generations
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
  systemdUserDir = "${userConfig.directories.home}/.config/systemd/user";
in
{
  home.activation.createSyncthingDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${syncthingPaths.shared}
    mkdir -p ${syncthingPaths.dataDir}
    mkdir -p ${syncthingPaths.passwords}
  '';

  home.activation.cleanupBrokenSymlinks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Remove broken symlinks in systemd user directory from stale generations
    if [[ -d "${systemdUserDir}" ]]; then
      find "${systemdUserDir}" -xtype l -delete 2>/dev/null || true
    fi
  '';
}
