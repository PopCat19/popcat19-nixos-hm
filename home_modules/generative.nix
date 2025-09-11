{
  system,
  pkgs,
  ...
}: let
  isX86_64 = system == "x86_64-linux";
  # ROCm on x86_64 only
  ollamaAcceleration =
    if isX86_64
    then "rocm"
    else null;
in {
  # Generative/AI related packages and services
  home.packages = with pkgs; [
    ollama-rocm
  ];

  services = {
    # AI/ML Services
    ollama = {
      enable = true;
      acceleration = ollamaAcceleration; # ROCm on x86_64, CPU on other architectures
    };
  };
}
