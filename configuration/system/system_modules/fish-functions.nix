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

      # Load all custom fish functions from default.fish
      if test -f "${../../../fish_functions/default.fish}"
          source ${../../../fish_functions/default.fish}
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
      flup = "nixos-flake-update";
      ngit = "begin; cd $NIXOS_CONFIG_DIR; git $argv; cd -; end";
      cdh = "cd $NIXOS_CONFIG_DIR";

      # NixOS Build and Switch operations
      nrb = "nixos-rebuild-basic";
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
}
