# Fix fcitx5-qt6 build issues by disabling the problematic qt6 module
final: prev: {
  fcitx5 = prev.fcitx5.override {
    # Disable qt6 support to avoid build failures
    withQt6 = false;
  };
  
  # Override fcitx5-with-addons to exclude qt6
  fcitx5-with-addons = prev.fcitx5-with-addons.override {
    # Use only Qt5 version
    qt6Support = false;
  };
}