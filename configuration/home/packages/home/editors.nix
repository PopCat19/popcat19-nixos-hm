# editors.nix
#
# Purpose: Text editors and IDEs
#
# This module:
# - Provides VSCodium editor
# - Provides Zed editor
{ pkgs, ... }:
with pkgs;
[
  vscodium
  zed-editor
]
