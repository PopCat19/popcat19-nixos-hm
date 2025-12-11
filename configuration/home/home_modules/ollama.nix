{
  system,
  pkgs,
  ...
}: {
  # Ollama with ROCm acceleration configuration
  # This module provides ollama service with ROCm GPU acceleration support

  home.packages = [
    pkgs.ollama-vulkan
  ];

  services = {
    ollama = {
      enable = true;
    };
  };
}
