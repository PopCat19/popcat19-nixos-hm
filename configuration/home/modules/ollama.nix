# ollama.nix
#
# Purpose: Configures Ollama LLM service.
#
# This module:
# - Enables Ollama service
# - Uses ROCm on AMD GPU hosts, CPU-only on Intel

{ pkgs, lib, userConfig, ... }:
let
  rocm = userConfig.gaming.enableROCm or false;
in
{
  services.ollama = {
    enable = true;
    package = if rocm then pkgs.ollama-rocm else pkgs.ollama;
    acceleration = lib.mkIf rocm "rocm";
    environmentVariables = {
      OLLAMA_KV_CACHE_TYPE = "q8_0";
    };
  };
}
