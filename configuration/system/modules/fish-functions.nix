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
    "fish/functions/cdh.fish".text = builtins.readFile ../../fish_functions/cdh.fish;
    "fish/functions/cnup.fish".text = builtins.readFile ../../fish_functions/cnup.fish;
    "fish/functions/dev-session.fish".text = builtins.readFile ../../fish_functions/dev-session.fish;
    "fish/functions/dev-to-main.fish".text = builtins.readFile ../../fish_functions/dev-to-main.fish;
    "fish/functions/devs.fish".text = builtins.readFile ../../fish_functions/devs.fish;
    "fish/functions/dtm.fish".text = builtins.readFile ../../fish_functions/dtm.fish;
    "fish/functions/find.fish".text = builtins.readFile ../../fish_functions/find.fish;
    "fish/functions/fix-fish-history.fish".text =
      builtins.readFile ../../fish_functions/fix-fish-history.fish;
    "fish/functions/fixhist.fish".text = builtins.readFile ../../fish_functions/fixhist.fish;
    "fish/functions/fish_greeting.fish".text =
      builtins.readFile ../../fish_functions/fish-greeting.fish;
    "fish/functions/flconf.fish".text = builtins.readFile ../../fish_functions/flconf.fish;
    "fish/functions/flup.fish".text = builtins.readFile ../../fish_functions/flup.fish;
    "fish/functions/forge-accept-line.fish".text =
      builtins.readFile ../../fish_functions/forge-accept-line.fish;
    "fish/functions/forge-init.fish".text = builtins.readFile ../../fish_functions/forge-init.fish;
    "fish/functions/forge-tab.fish".text = builtins.readFile ../../fish_functions/forge-tab.fish;
    "fish/functions/gac.fish".text = builtins.readFile ../../fish_functions/gac.fish;
    "fish/functions/grep.fish".text = builtins.readFile ../../fish_functions/grep.fish;
    "fish/functions/greset.fish".text = builtins.readFile ../../fish_functions/greset.fish;
    "fish/functions/hconf.fish".text = builtins.readFile ../../fish_functions/hconf.fish;
    "fish/functions/list-fish-helpers.fish".text =
      builtins.readFile ../../fish_functions/list-fish-helpers.fish;
    "fish/functions/lsa.fish".text = builtins.readFile ../../fish_functions/lsa.fish;
    "fish/functions/nconf.fish".text = builtins.readFile ../../fish_functions/nconf.fish;
    "fish/functions/ngit.fish".text = builtins.readFile ../../fish_functions/ngit.fish;
    "fish/functions/nix-flake-update.fish".text =
      builtins.readFile ../../fish_functions/nix-flake-update.fish;
    "fish/functions/nix-shell-unfree.fish".text =
      builtins.readFile ../../fish_functions/nix-shell-unfree.fish;
    "fish/functions/nixos-rebuild-auto.fish".text =
      builtins.readFile ../../fish_functions/nixos-rebuild-auto.fish;
    "fish/functions/nixos-rebuild-basic.fish".text =
      builtins.readFile ../../fish_functions/nixos-rebuild-basic.fish;
    "fish/functions/nrb.fish".text = builtins.readFile ../../fish_functions/nrb.fish;
    "fish/functions/nsp.fish".text = builtins.readFile ../../fish_functions/nsp.fish;
    "fish/functions/pkgs.fish".text = builtins.readFile ../../fish_functions/pkgs.fish;
    "fish/functions/scrc.fish".text = builtins.readFile ../../fish_functions/scrc.fish;
    "fish/functions/scrch.fish".text = builtins.readFile ../../fish_functions/scrch.fish;
    "fish/functions/scrcx.fish".text = builtins.readFile ../../fish_functions/scrcx.fish;
    "fish/functions/scrcxh.fish".text = builtins.readFile ../../fish_functions/scrcxh.fish;
    "fish/functions/show-shortcuts.fish".text =
      builtins.readFile ../../fish_functions/show-shortcuts.fish;
    "fish/functions/slp.fish".text = builtins.readFile ../../fish_functions/slp.fish;
  };

  programs.fish = {
    enable = true;

    shellAbbrs = {
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";
      l = "eza -lh --icons=auto";
      ld = "eza -lhD --icons=auto";
      ll = "eza -lha --icons=auto --sort=name --group-directories-first";
      ls = "eza -1 --icons=auto";
      lt = "eza --tree --icons=auto";
      mkdir = "mkdir -p";
    };

    shellInit = ''
      set -g fish_greeting ""

      fish_add_path $HOME/bin
      fish_add_path $HOME/.npm-global/bin

      if not contains /etc/fish/functions $fish_function_path
          set -g fish_function_path /etc/fish/functions $fish_function_path
      end

      if status is-interactive
          starship init fish | source
          if command -q forge
              if not set -q FORGE_TERM
                  set -gx FORGE_TERM true
              end
              forge-init
          end
      end
    '';
  };
}
