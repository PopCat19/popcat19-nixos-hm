# agents.nix
#
# Purpose: Consolidated LLM agent packages and configuration
#
# This module:
# - Installs agent binaries from llm-agents.nix (opencode, pi, etc.)
# - Controlled via userConfig.agents options
{
  pkgs,
  inputs,
  userConfig,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  agentsPkgs = inputs.llm-agents.packages.${system};

  agentList =
    (pkgs.lib.optional (userConfig.agents.opencode or false) agentsPkgs.opencode)
    ++ (pkgs.lib.optional (userConfig.agents.pi or false) agentsPkgs.pi);
in
{
  environment.systemPackages = agentList;
}
