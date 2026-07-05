# agents.nix
#
# Purpose: Consolidated LLM agent packages and configuration
#
# This module:
# - Installs agent binaries from llm-agents.nix (opencode, pi, forgecode, etc.)
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
    ++ (pkgs.lib.optional (userConfig.agents.pi or false) agentsPkgs.pi)
    # t3code-flake only exposes x86_64-linux (and aarch64-darwin). Guard so
    # enabling agents.t3code on aarch64-linux (nix-on-droid) no-ops instead
    # of breaking the build on a missing package output.
    ++ (pkgs.lib.optional (
      (userConfig.agents.t3code or false) && system == "x86_64-linux"
    ) inputs.t3code-flake.packages.${system}.t3-code);
in
{
  environment.systemPackages = agentList;
}
