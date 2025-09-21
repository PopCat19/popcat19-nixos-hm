{ lib, pkgs, config, system, inputs, userConfig, ... }:
let
  # Default wallpaper to derive palette from
  wpDir = builtins.path { path = ../wallpaper; name = "wallpaper"; };
  defaultWallpaper = "${wpDir}/kasane_teto_utau_drawn_by_yananami_numata220.jpg";

  # Absolute template path in store for Matugen
  hyprTemplate = builtins.toString (./matugen_templates/hypr.conf);

  # Matugen config TOML content (kept minimal)
  matugenToml = ''
    [config]

    [templates.hypr]
    input_path = "${hyprTemplate}"
    output_path = "~/.config/hypr/colors.conf"
  '';

  matugenBin = "${pkgs.matugen}/bin/matugen";

  # CLI selections (align with nixpkgs' matugen CLI)
  mode = "dark";                # "light" | "dark" | "amoled"
  scheme = "scheme-tonal-spot"; # palette type
  jsonFmt = "strip";            # "rgb" | "rgba" | "hsl" | "hsla" | "hex" | "strip"
  contrast = "0.0";

  # The config file path in XDG config
  matugenConfigRel = "matugen/config.toml";
  matugenConfigAbs = "${config.xdg.configHome}/${matugenConfigRel}";
in
{
  # Provide Matugen binary
  home.packages = [ pkgs.matugen ];

  # Write Matugen config under XDG config
  xdg.configFile.${matugenConfigRel}.text = matugenToml;

  # Ensure Hypr config dir exists
  home.file.".config/hypr/".directory = true;

  # Generate colors at activation time to avoid module incompatibilities
  home.activation.matugenGenerate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "[matugen] Generating Material You palette for Hypr colors..." >&2
    mkdir -p "$HOME/.config/hypr"
    # Prefer user override if provided via HM extraSpecialArgs/userConfig in the future
    WALL="${defaultWallpaper}"
    ${matugenBin} image \
      --config "${matugenConfigAbs}" \
      --mode "${mode}" \
      --type "${scheme}" \
      --json "${jsonFmt}" \
      --contrast "${contrast}" \
      --quiet \
      "${WALL}" || {
        echo "[matugen] Generation failed" >&2
        exit 1
      }
  '';
}