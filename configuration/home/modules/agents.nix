# agents.nix
#
# Purpose: Home-level LLM agent configuration
#
# This module:
# - Provides home-level settings for AI coding agents
# - Fish shell integration for ForgeCode is managed system-wide via fish-functions.nix
# - Disables forge auto-update (Nix manages the binary version)
{ config, ... }:
{
  home.activation.forgeUpdates = config.lib.dag.entryAfter [ "writeBoundary" ] ''
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
}
