# nvim.nix
#
# Purpose: Configure LazyVim via lazyvim-nix flake
#
# This module:
# - Imports lazyvim home-manager module
# - Configures LazyVim with stylix theming via pmd
{ inputs, ... }:
{
  imports = [
    inputs.lazyvim.homeManagerModules.default
  ];

  programs.lazyvim = {
    enable = true;

    extras = {
      lang.nix.enable = true;
    };

    config = {
      options = ''
        vim.opt.relativenumber = true
        vim.opt.expandtab = true
        vim.opt.shiftwidth = 2
        vim.opt.tabstop = 2
        vim.opt.softtabstop = 2
        vim.opt.smartindent = true
        vim.opt.wrap = false
        vim.opt.ignorecase = true
        vim.opt.smartcase = true
        vim.opt.termguicolors = true
        vim.opt.scrolloff = 8
        vim.opt.signcolumn = "yes"
        vim.opt.updatetime = 100
        vim.opt.splitright = true
        vim.opt.splitbelow = true
      '';
    };

    plugins.colorscheme = ''
      return {
        "popcat19/project-minimalist-design",
        opts = {
          style = "all",
        },
      }
    '';
  };
}
