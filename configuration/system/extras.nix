# Extras System Configuration
#
# Purpose: Optional modules for self-hosting, development, gaming, privacy
# Dependencies: main.nix
# Related: minimal.nix, main.nix
#
# This module:
# - Imports optional system modules
# - Provides extended functionality
{...}: {
  imports = [
    ./main.nix
    ./extras/vpn.nix
  ];
}
