# Fix fcitx5-qt6 build issues by overriding the package to exclude qt6
final: prev: {
  # Override fcitx5-with-addons to use only Qt5 version and exclude qt6
  fcitx5-with-addons = prev.fcitx5-with-addons.overrideAttrs (oldAttrs: {
    buildInputs = builtins.filter (input: !(builtins.match ".*fcitx5-qt6.*" (input.name or ""))) oldAttrs.buildInputs or [];
    propagatedBuildInputs = builtins.filter (input: !(builtins.match ".*fcitx5-qt6.*" (input.name or ""))) oldAttrs.propagatedBuildInputs or [];
    propagatedUserEnvPkgs = builtins.filter (input: !(builtins.match ".*fcitx5-qt6.*" (input.name or ""))) oldAttrs.propagatedUserEnvPkgs or [];
  });
}