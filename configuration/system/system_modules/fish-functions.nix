# Fish Functions and Configuration Module
#
# Purpose: Configure Fish shell with custom functions and abbreviations
# Dependencies: fish, userConfig
# Related: fish.nix, ../../../fish_functions/
#
# This module:
# - Loads custom Fish functions from fish_functions directory
# - Configures Fish shell environment and abbreviations
# - Sets up NixOS-specific environment variables
# - Provides system-wide Fish helper functions
{ userConfig, ... }:
{
  programs.fish = {
    enable = true;

    # Load custom Fish functions
    shellInit = ''
      set -Ux NIXOS_CONFIG_DIR $HOME/nixos-config
      set -Ux NIXOS_FLAKE_HOSTNAME ${userConfig.host.hostname}
      set -Ux EDITOR ${userConfig.defaultApps.editor.command}
      set -g fish_greeting ""

      # Add paths
      fish_add_path $HOME/bin
      fish_add_path $HOME/.npm-global/bin

      # Initialize starship if interactive
      if status is-interactive
          starship init fish | source
      end

      # Make system-wide functions visible
      if not contains /etc/fish/functions $fish_function_path
          set -g fish_function_path /etc/fish/functions $fish_function_path
      end
    '';

    # Custom shell abbreviations for convenience
    shellAbbrs = {
      # Navigation shortcuts
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";

      # File Operations using eza
      mkdir = "mkdir -p";
      l = "eza -lh --icons=auto";
      ls = "eza -1 --icons=auto";
      ll = "eza -lha --icons=auto --sort=name --group-directories-first";
      ld = "eza -lhD --icons=auto";
      lt = "eza --tree --icons=auto";

      # NixOS Configuration Management
      nconf = "$EDITOR $NIXOS_CONFIG_DIR/configuration.nix";
      hconf = "$EDITOR $NIXOS_CONFIG_DIR/home.nix";
      flconf = "$EDITOR $NIXOS_CONFIG_DIR/flake.nix";
      ngit = "begin; cd $NIXOS_CONFIG_DIR; git $argv; cd -; end";
      cdh = "cd $NIXOS_CONFIG_DIR";
      nrbc = "nixos-commit-rebuild-push";

      # Package Management with nix search
      pkgs = "nix search nixpkgs";
      nsp = "nix-shell -p";

      # Git shortcuts
      gac = "git add . && git commit -m $argv";
      greset = "git reset --hard && git clean -fd";
      dtm = "dev-to-main";

      # SillyTavern launcher

      # Fish history management
      fixhist = "fix-fish-history";
    };
  };

  # Fish function files
  environment.etc = {
    "fish/functions/fish_greeting.fish".text =
      builtins.readFile ../../../fish_functions/fish-greeting.fish;
    "fish/functions/nixos-rebuild-basic.fish".text =
      builtins.readFile ../../../fish_functions/nixos-rebuild-basic.fish;
    "fish/functions/nixos-flake-update.fish".text =
      builtins.readFile ../../../fish_functions/nixos-flake-update.fish;
    "fish/functions/fix-fish-history.fish".text =
      builtins.readFile ../../../fish_functions/fix-fish-history.fish;
    "fish/functions/list-fish-helpers.fish".text =
      builtins.readFile ../../../fish_functions/list-fish-helpers.fish;
    "fish/functions/nixos-commit-rebuild-push.fish".text =
      builtins.readFile ../../../fish_functions/nixos-commit-rebuild-push.fish;
    "fish/functions/dev-to-main.fish".text = builtins.readFile ../../../fish_functions/dev-to-main.fish;
    "fish/functions/nix-shell-unfree.fish".text =
      builtins.readFile ../../../fish_functions/nix-shell-unfree.fish;
    "fish/functions/cnup.fish".text = builtins.readFile ../../../fish_functions/cnup.fish;
    "fish/functions/sillytavern.fish".text = builtins.readFile ../../../fish_functions/sillytavern.fish;
    "fish/functions/show-shortcuts.fish".text =
      builtins.readFile ../../../fish_functions/show-shortcuts.fish;
    "fish/functions/lsa.fish".text = builtins.readFile ../../../fish_functions/lsa.fish;
    "fish/functions/proxy-env.fish".text = builtins.readFile ../../../fish_functions/proxy-env.fish;
  };
}
