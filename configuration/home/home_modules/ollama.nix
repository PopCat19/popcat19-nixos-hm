# ollama.nix
#
# Purpose: Configures Ollama LLM service with Vulkan acceleration.
#
# This module:
# - Enables Ollama service
# - Adds Vulkan-enabled package for GPU support

{ pkgs, ... }:
{
  home.packages = [ pkgs.ollama-vulkan ];
  services.ollama.enable = true;
}
