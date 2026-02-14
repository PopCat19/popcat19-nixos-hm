# development.nix
#
# Purpose: Development tools and language support
#
# This module:
# - Provides Nix language servers and tooling
# - Provides code formatters and linters
# - Provides programming language runtimes
{ pkgs, ... }:
with pkgs;
[
  alejandra
  android-tools
  black
  bun
  clang-tools
  deadnix
  fd
  fish-lsp
  git-lfs
  glslang
  hyprlang
  hyprls
  jdk
  lazygit
  nil
  nixd
  nixfmt
  nixfmt-tree
  nodejs_latest
  prettierd
  python3
  ripgrep
  rustup
  shellcheck
  shfmt
  statix
  yamllint
  yarn-berry
]
