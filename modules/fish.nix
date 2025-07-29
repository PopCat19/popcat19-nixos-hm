{ pkgs, ... }:

{
  # Fish Shell Configuration
  programs.fish = {
    enable = true;
    shellInit = ''
      set -Ux NIXOS_CONFIG_DIR $HOME/nixos-config
      set -Ux NIXOS_FLAKE_HOSTNAME popcat19-nixos0
      set -Ux EDITOR micro
      set -g fish_greeting "" # Disable default fish greeting.

      # Custom greeting disabled - fastfetch removed
      function fish_greeting
          # Empty greeting
      end

      # NixOS commit function
      function nixos-commit-function
          set -l original_dir (pwd)
          cd $NIXOS_CONFIG_DIR
          git add .
          git commit -m "$argv"
          cd $original_dir
      end
      fish_add_path $HOME/bin # Add user's bin directory to PATH.
      fish_add_path $HOME/.npm-global/bin # Add npm global packages to PATH.
      if status is-interactive
          starship init fish | source # Initialize Starship prompt.
      end
    '';
    # Custom shell abbreviations for convenience.
    shellAbbrs = {
      # Navigation shortcuts.
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";

      # File Operations using eza.
      mkdir = "mkdir -p";
      l = "eza -lh --icons=auto";
      ls = "eza -1 --icons=auto";
      ll = "eza -lha --icons=auto --sort=name --group-directories-first";
      ld = "eza -lhD --icons=auto";
      lt = "eza --tree --icons=auto";

      # NixOS Configuration Management.
      nconf = "$EDITOR $NIXOS_CONFIG_DIR/configuration.nix";
      hconf = "$EDITOR $NIXOS_CONFIG_DIR/home.nix";
      flconf = "$EDITOR $NIXOS_CONFIG_DIR/flake.nix";
      flup = "begin; cd $NIXOS_CONFIG_DIR; cp flake.lock flake.lock.bak; nix flake update; cd -; end";
      ngit = "begin; cd $NIXOS_CONFIG_DIR; git $argv; cd -; end";
      cdh = "cd $NIXOS_CONFIG_DIR";

      # NixOS Build and Switch operations.
      nrb = "begin; cd $NIXOS_CONFIG_DIR; sudo nixos-rebuild switch --flake .; cd -; end";
      nrbm = "nixos-commit-function";

      # Package Management with nix search.
      pkgs = "nix search nixpkgs";
      nsp = "nix-shell -p";

      # Git shortcuts.
      gac = "git add . && git commit -m $argv";
      greset = "git reset --hard && git clean -fd";

      # SillyTavern launcher.
      sillytavern = "begin; cd ~/SillyTavern-Launcher/SillyTavern; git pull origin staging 2>/dev/null || true; ./start.sh; cd -; end";
    };
  };

  # Fish configuration files
  home.file.".config/fish/themes" = {
    source = ../fish_themes;
    recursive = true;
  };
}