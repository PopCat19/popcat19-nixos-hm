{
  system,
  pkgs,
  ...
}: let
  isX86_64 = system == "x86_64-linux";
  # Note: ROCm acceleration currently disabled due to upstream nixpkgs issue with rocmPackages.stdenv
  # TODO: Re-enable ROCm when upstream issue is resolved
  # The rocm-pinned.nix overlay provides pinned ROCm packages, but stdenv issue still exists
  ollamaAcceleration = null; # CPU fallback for now, will be "rocm" when issue is fixed
in {
  # Ollama with ROCm acceleration configuration
  # This module provides ollama service with ROCm GPU acceleration support
  # Currently using CPU fallback due to ROCm stdenv issue

  services = {
    ollama = {
      enable = true;
      acceleration = ollamaAcceleration;
    };
  };
}
