{ lib, pkgs, config, system, inputs, userConfig, ... }:
let
  # Use the repo's wallpaper image as Matugen source by default.
  # You can override via programs.matugen.source_color or programs.matugen.wallpaper elsewhere.
  defaultWallpaper =
    let
      wpDir = builtins.path { path = ../wallpaper; name = "wallpaper"; };
    in
      "${wpDir}/kasane_teto_utau_drawn_by_yananami_numata220.jpg";
in
{
  # Import the Matugen NixOS/Home Manager module is already done at top-level (home.nix).
  # Here we enable and configure it with a template for Hyprland colors.

  programs.matugen = {
    enable = true;

    # Use the binary provided by the flake input
    package = inputs.matugen.packages.${system}.default;

    # Use either source_color (takes precedence) or wallpaper to derive palette
    # source_color = "#ff8a65"; # example override
    wallpaper = defaultWallpaper;

    # Palette generation options
    variant = "dark";                # "light" | "dark" | "amoled"
    type = "scheme-tonal-spot";      # per Matugen docs
    jsonFormat = "strip";            # emits hex without '#'
    contrast = 0.0;

    # Templates: Generate a Hyprland colors file to be sourced by Hypr config
    templates = {
      hypr = {
        # Template file with @{keywords} (we'll add this file next)
        input_path = ./matugen_templates/hypr.conf;
        # Matugen expands $HOME internally; module sanitizes to '~' per docs
        output_path = "$HOME/.config/hypr/colors.conf";
      };

      # Example placeholders to extend later (kitty/gtk/fuzzel/etc)
      # kitty = {
      #   input_path = ./matugen_templates/kitty.conf;
      #   output_path = "$HOME/.config/kitty/colors.conf";
      # };
      # gtk = {
      #   input_path = ./matugen_templates/gtk.css;
      #   output_path = "$HOME/.config/gtk-4.0/gtk.css";
      # };
    };

    # You can harmonize custom colors if desired
    # custom_colors.exampleAccent = {
    #   color = "#ff0000";
    #   blend = true;
    # };

    # Pass-through for advanced settings (custom keywords, etc.)
    config = {
      # Example:
      # custom_keywords.font1 = "Rounded Mplus 1c Medium";
    };
  };

  # Symlink the generated file into place, per upstream guidance in issue #28
  # Use Home Manager's home.file to place under ~/.config
  home.file.".config/hypr/colors.conf".source =
    "${config.programs.matugen.theme.files}/.config/hypr/colors.conf";
}