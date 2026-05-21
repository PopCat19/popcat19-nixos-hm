# fish-functions.nix
#
# Purpose: Configure Fish shell with custom functions and abbreviations
#
# This module:
# - Loads custom Fish functions from fish directory
# - Configures Fish shell environment and abbreviations
_: {
  environment.etc = {
    "fish/completions/proxify.fish".text =
      builtins.readFile ../../fish_functions/completions/proxify.fish;
    "fish/functions/cnup.fish".text = builtins.readFile ../../fish_functions/cnup.fish;
    "fish/functions/dev-to-main.fish".text = builtins.readFile ../../fish_functions/dev-to-main.fish;
    "fish/functions/fix-fish-history.fish".text =
      builtins.readFile ../../fish_functions/fix-fish-history.fish;
    "fish/functions/fish_greeting.fish".text =
      builtins.readFile ../../fish_functions/fish-greeting.fish;
    "fish/functions/list-fish-helpers.fish".text =
      builtins.readFile ../../fish_functions/list-fish-helpers.fish;
    "fish/functions/lsa.fish".text = builtins.readFile ../../fish_functions/lsa.fish;
    "fish/functions/nix-shell-unfree.fish".text =
      builtins.readFile ../../fish_functions/nix-shell-unfree.fish;
    "fish/functions/nix-flake-update.fish".text =
      builtins.readFile ../../fish_functions/nix-flake-update.fish;
    "fish/functions/nixos-rebuild-auto.fish".text =
      builtins.readFile ../../fish_functions/nixos-rebuild-auto.fish;
    "fish/functions/nixos-rebuild-basic.fish".text =
      builtins.readFile ../../fish_functions/nixos-rebuild-basic.fish;
    "fish/functions/show-shortcuts.fish".text =
      builtins.readFile ../../fish_functions/show-shortcuts.fish;
    "fish/functions/sillytavern.fish".text = builtins.readFile ../../fish_functions/sillytavern.fish;
    "fish/functions/dev-session.fish".text = builtins.readFile ../../fish_functions/dev-session.fish;
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
      devs = "dev-session";
      dtm = "dev-to-main";
      fixhist = "fix-fish-history";
      flconf = "$EDITOR $NIXOS_CONFIG_DIR/flake.nix";
      flup = "nix-flake-update";
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
      nsp = "nix-shell -p";
      pkgs = "nix search nixpkgs";
      slp = "systemctl sleep";
    };

    shellInit = ''
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
