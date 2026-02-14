# fish-functions.nix
#
# Purpose: Configure Fish shell with custom functions and abbreviations
#
# This module:
# - Loads custom Fish functions from fish_functions directory
# - Configures Fish shell environment and abbreviations
# - Sets up NixOS-specific environment variables
{ userConfig, ... }:
{
  environment.etc = {
    "fish/completions/proxify.fish".text =
      builtins.readFile ../../base/system/fish_functions/completions/proxify.fish;
    "fish/functions/cnup.fish".text = builtins.readFile ../../base/system/fish_functions/cnup.fish;
    "fish/functions/dev-to-main.fish".text = builtins.readFile ../../base/system/fish_functions/dev-to-main.fish;
    "fish/functions/fix-fish-history.fish".text =
      builtins.readFile ../../base/system/fish_functions/fix-fish-history.fish;
    "fish/functions/fish_greeting.fish".text =
      builtins.readFile ../../base/system/fish_functions/fish-greeting.fish;
    "fish/functions/list-fish-helpers.fish".text =
      builtins.readFile ../../base/system/fish_functions/list-fish-helpers.fish;
    "fish/functions/lsa.fish".text = builtins.readFile ../../base/system/fish_functions/lsa.fish;
    "fish/functions/nix-shell-unfree.fish".text =
      builtins.readFile ../../base/system/fish_functions/nix-shell-unfree.fish;
    "fish/functions/nixos-commit-rebuild-push.fish".text =
      builtins.readFile ../../base/system/fish_functions/nixos-commit-rebuild-push.fish;
    "fish/functions/nixos-flake-update.fish".text =
      builtins.readFile ../../base/system/fish_functions/nixos-flake-update.fish;
    "fish/functions/nixos-rebuild-basic.fish".text =
      builtins.readFile ../../base/system/fish_functions/nixos-rebuild-basic.fish;
    "fish/functions/proxy_off.fish".text = builtins.readFile ../../base/system/fish_functions/proxy_off.fish;
    "fish/functions/proxy_on.fish".text = builtins.readFile ../../base/system/fish_functions/proxy_on.fish;
    "fish/functions/proxify.fish".text = builtins.readFile ../../base/system/fish_functions/proxify.fish;
    "fish/functions/show-shortcuts.fish".text =
      builtins.readFile ../../base/system/fish_functions/show-shortcuts.fish;
    "fish/functions/sillytavern.fish".text = builtins.readFile ../../base/system/fish_functions/sillytavern.fish;
  };

  programs.fish = {
    enable = true;

    shellAbbrs = {
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";
      cdh = "cd $NIXOS_CONFIG_DIR";
      dtm = "dev-to-main";
      fixhist = "fix-fish-history";
      flconf = "$EDITOR $NIXOS_CONFIG_DIR/flake.nix";
      flup = "nixos-flake-update";
      gac = "git add . && git commit -m $argv";
      greset = "git reset --hard && git clean -fd";
      hconf = "$EDITOR $NIXOS_CONFIG_DIR/home.nix";
      l = "eza -lh --icons=auto";
      ld = "eza -lhD --icons=auto";
      ll = "eza -lha --icons=auto --sort=name --group-directories-first";
      ls = "eza -1 --icons=auto";
      lt = "eza --tree --icons=auto";
      mkdir = "mkdir -p";
      nconf = "$EDITOR $NIXOS_CONFIG_DIR/configuration.nix";
      ngit = "begin; cd $NIXOS_CONFIG_DIR; git $argv; cd -; end";
      nrb = "nixos-rebuild-basic";
      nrbc = "nixos-commit-rebuild-push";
      nsp = "nix-shell -p";
      pkgs = "nix search nixpkgs";
    };

    shellInit = ''
      set -Ux NIXOS_CONFIG_DIR $HOME/nixos-config
      set -Ux NIXOS_FLAKE_HOSTNAME ${userConfig.hostname}
      set -Ux EDITOR ${userConfig.defaultApps.editor.command}
      set -g fish_greeting ""

      fish_add_path $HOME/bin
      fish_add_path $HOME/.npm-global/bin

      if status is-interactive
          starship init fish | source
      end

      if not contains /etc/fish/functions $fish_function_path
          set -g fish_function_path /etc/fish/functions $fish_function_path
      end
    '';
  };
}
