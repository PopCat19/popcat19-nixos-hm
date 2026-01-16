# Development tools and language support
{pkgs, ...}:
with pkgs; [
  # Nix Development
  nil
  nixd

  # Code Formatters
  black
  prettierd
  nixfmt-rfc-style
  alejandra
  statix
  deadnix
  yamllint
  shfmt
  glslang
  clang-tools
  hyprlang

  # Development Tools
  ripgrep
  fd
  lazygit
  git-lfs
  hyprls
  shellcheck
  fish-lsp

  # Android Tools
  android-tools

  # Programming Languages and Runtimes
  jdk
  nodejs_latest
  yarn-berry
  rustup
  python3
]
