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
{userConfig, ...}: {
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

      # Load individual fish function files
      if test -f "${../../../fish_functions/nix-shell-unfree.fish}"
          source ${../../../fish_functions/nix-shell-unfree.fish}
      end

      if test -f "${../../../fish_functions/fish-greeting.fish}"
          source ${../../../fish_functions/fish-greeting.fish}
      end

      if test -f "${../../../fish_functions/list-fish-helpers.fish}"
          source ${../../../fish_functions/list-fish-helpers.fish}
      end

      if test -f "${../../../fish_functions/nixos-commit-rebuild-push.fish}"
          source ${../../../fish_functions/nixos-commit-rebuild-push.fish}
      end

      if test -f "${../../../fish_functions/nixos-rebuild-basic.fish}"
          source ${../../../fish_functions/nixos-rebuild-basic.fish}
      end

      if test -f "${../../../fish_functions/dev-to-main.fish}"
          source ${../../../fish_functions/dev-to-main.fish}
      end

      if test -f "${../../../fish_functions/nixos-flake-update.fish}"
          source ${../../../fish_functions/nixos-flake-update.fish}
      end

      if test -f "${../../../fish_functions/fix-fish-history.fish}"
          source ${../../../fish_functions/fix-fish-history.fish}
      end

      if test -f "${../../../fish_functions/cnup.fish}"
          source ${../../../fish_functions/cnup.fish}
      end

      if test -f "${../../../fish_functions/sillytavern.fish}"
          source ${../../../fish_functions/sillytavern.fish}
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
