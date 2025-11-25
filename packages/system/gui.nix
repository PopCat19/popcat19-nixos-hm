# GUI and launcher tools
{pkgs, ...}:
with pkgs; [
  fuzzel
  kdePackages.filelight
  # Qt theming engine for EasyEffects and other Qt applications
  kdePackages.qtstyleplugin-kvantum
]
