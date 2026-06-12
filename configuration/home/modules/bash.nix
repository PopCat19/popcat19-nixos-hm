# bash.nix
#
# Purpose: Bash shell wrappers that remind about ripgrep
#
# This module:
# - Wraps grep and find to suggest rg when it's installed
# - grep: always reminds (rg replaces all grep usage)
# - find: only reminds for -name/-iname (rg --files -g equivalent)
# - find -type/-mtime/-exec/-delete pass through silently (no rg equivalent)
{ ... }:
{
  programs.bash = {
    initExtra = ''
      grep() {
          if command -v rg &>/dev/null; then
              echo "💡 rg is faster — try: rg $*" >&2
          fi
          command grep "$@"
      }

      find() {
          if command -v rg &>/dev/null; then
              for arg in "$@"; do
                  if [[ "$arg" == -name || "$arg" == -iname ]]; then
                      echo "💡 rg --files -g '<glob>' is faster than find -name" >&2
                      break
                  fi
              done
          fi
          command find "$@"
      }
    '';
  };
}
