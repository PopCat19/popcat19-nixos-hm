# Development tools and language support

{ pkgs, ... }:

with pkgs;
[
  # Nix Development
  nil
  nixd
  nixfmt-rfc-style

  # Neovim and Language Servers
  neovim

  pyright
  lua-language-server
  nodePackages_latest.typescript-language-server
  nodePackages_latest.vscode-langservers-extracted

  # Code Formatters
  black
  prettierd

  # Development Tools
  ripgrep
  fd
  lazygit
  git-lfs
  hyprls
]