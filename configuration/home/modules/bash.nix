# bash.nix
#
# Purpose: Bash shell configuration with fish function equivalents
#
# This module:
# - Sources bashrc with ~30 portable fish function translations
# - Provides rg reminder wrappers for grep and find
# - Includes starship prompt init
{ ... }:
{
  programs.bash = {
    initExtra = builtins.readFile ../../bash/bashrc;
  };
}
