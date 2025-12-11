# Development tools and language support
{pkgs, ...}:
with pkgs; [
  # Nix Development
  nil
  nixd
  nixfmt-rfc-style

  # Code Formatters
  black
  prettierd

  # Development Tools
  ripgrep
  fd
  lazygit
  git-lfs
  hyprls
  shellcheck

  # Android Tools
  android-tools

  # Programming Languages and Runtimes
  jdk
  nodejs_latest
  yarn-berry
  rustup
  python3

]
