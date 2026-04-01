# ollama.nix
#
# Purpose: Configures Ollama LLM service with ROCm acceleration.
#
# This module:
# - Enables Ollama service
# - Adds ROCm-enabled package for AMD GPU support

{ pkgs, ... }:
{
  home.packages = [ pkgs.ollama-rocm ];
  services.ollama.enable = true;
}
