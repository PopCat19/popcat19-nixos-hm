# agents.nix
#
# Purpose: Home-level LLM agent configuration
#
# This module:
# - Provides home-level settings for AI coding agents
# - Fish shell integration for ForgeCode is managed system-wide via fish-functions.nix
_: {
  # Currently no home-level agent configuration is managed here.
  # Fish integration (forge-accept-line, forge-tab, forge-init) is wired in fish-functions.nix.
  # Agent state (e.g. ~/.forgecode/, ~/.kilocode/, ~/.pi/extensions, ~/.opencode/, ~/.reasonix/) is user-managed.
}
