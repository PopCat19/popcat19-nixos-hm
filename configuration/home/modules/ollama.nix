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
  };
}
