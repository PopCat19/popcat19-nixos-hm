# ollama.nix
#
# Purpose: Configures Ollama LLM service with ROCm acceleration.
#
# This module:
# - Enables Ollama service
# - Adds ROCm-enabled package for AMD GPU support

{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    acceleration = "rocm";
    environmentVariables = {
      OLLAMA_KV_CACHE_TYPE = "q8_0";
    };
  };
}
