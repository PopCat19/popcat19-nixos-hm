# forgecode.nix
#
# Purpose: Centralized ForgeCode configuration — binary, shell integration, auto-update
#
# This module:
# - Installs forgecode binary from llm-agents flake (when userConfig.agents.forgecode is true)
# - Loads Fish shell functions (forge-init, forge-accept-line, forge-tab, forge-rprompt)
# - Initializes forge on interactive fish startup
# - Disables forge self-update (Nix manages the binary version)
{
  pkgs,
  inputs,
  userConfig,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  cfg = userConfig.agents.forgecode or false;
in
{
  config = lib.mkIf cfg {
    environment.systemPackages = [
      inputs.llm-agents.packages.${system}.forgecode
    ];

    environment.etc = {
      "fish/functions/forge-accept-line.fish".text =
        builtins.readFile ../../fish_functions/forge-accept-line.fish;
      "fish/functions/forge-init.fish".text = builtins.readFile ../../fish_functions/forge-init.fish;
      "fish/functions/forge-tab.fish".text = builtins.readFile ../../fish_functions/forge-tab.fish;
      "fish/functions/forge-rprompt.fish".text =
        builtins.readFile ../../fish_functions/forge-rprompt.fish;
    };

    programs.fish.shellInit = ''
      if status is-interactive
          if command -q forge
              if not set -q FORGE_TERM
                  set -gx FORGE_TERM true
              end
              forge-init
          end
      end
    '';

    home-manager.users.${userConfig.username}.home.activation.forgeUpdates = ''
      forge_config="$HOME/forge/.forge.toml"
      mkdir -p "$(dirname "$forge_config")"
      if [ -f "$forge_config" ]; then
        if grep -q '^\[updates\]' "$forge_config" 2>/dev/null; then
          sed -i '/^\[updates\]/,/^\[/{s/^frequency = .*/frequency = "never"/;s/^auto_update = .*/auto_update = false/}' "$forge_config"
        else
          printf '\n[updates]\nfrequency = "never"\nauto_update = false\n' >> "$forge_config"
        fi
      else
        printf '[updates]\nfrequency = "never"\nauto_update = false\n' > "$forge_config"
      fi
    '';
  };
}
