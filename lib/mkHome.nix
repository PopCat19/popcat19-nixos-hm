# mkHome.nix
#
# Purpose: Creates Home Manager configurations with shared defaults
#
# This module:
# - Wraps home-manager configuration with standard settings
# - Handles user and platform configuration
# - Provides consistent specialArgs
_: {
  mkHomeConfiguration =
    {
      username,
      homeDirectory,
      stateVersion,
      extraImports ? [ ],
    }:
    {
      home.username = username;
      home.homeDirectory = homeDirectory;
      home.stateVersion = stateVersion;

      imports = [
        ../configuration/home/modules
      ]
      ++ extraImports;
    };
}
