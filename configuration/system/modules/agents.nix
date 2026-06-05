# agents.nix
#
# Purpose: Consolidated LLM agent packages and configuration
#
# This module:
# - Installs agent binaries from llm-agents.nix (forgecode, kilocode-cli, omp, opencode, pi, reasonix, etc.)
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
    (pkgs.lib.optional (userConfig.agents.forgecode or false) agentsPkgs.forgecode)
    ++ (pkgs.lib.optional (userConfig.agents.kilocode-cli or false) agentsPkgs.kilocode-cli)
    ++ (pkgs.lib.optional (userConfig.agents.omp or false) agentsPkgs.omp)
    ++ (pkgs.lib.optional (userConfig.agents.opencode or false) agentsPkgs.opencode)
    ++ (pkgs.lib.optional (userConfig.agents.pi or false) agentsPkgs.pi)
    ++ (pkgs.lib.optional (userConfig.agents.reasonix or false) agentsPkgs.reasonix);
in
{
  environment.systemPackages = agentList;
}
