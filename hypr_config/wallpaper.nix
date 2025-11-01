{
  lib,
  pkgs,
  ...
}: let
  # UNUSED: This file is no longer needed as Stylix handles wallpaper management
  # Kept for reference in case you want to restore manual wallpaper configuration
  
  # Force inclusion of the wallpaper directory into the Nix store, even if empty.
  # This prevents ENOENT during evaluation when the directory exists in the repo
  # but Nix didn't copy it because it had no referenced files.
  wallpaperDir = builtins.path {
    path = ../wallpaper;
    name = "wallpaper";
  };

  entries = builtins.readDir wallpaperDir;

  isImage = name: let
    lower = lib.toLower name;
  in
    lib.hasSuffix ".jpg" lower
    || lib.hasSuffix ".jpeg" lower
    || lib.hasSuffix ".png" lower
    || lib.hasSuffix ".webp" lower
    || lib.hasSuffix ".bmp" lower;

  imageNames =
    lib.filter (n: (entries.${n} or null) == "regular" && isImage n)
    (builtins.attrNames entries);

  images =
    map (n: toString (wallpaperDir + ("/" + n))) imageNames;

  hyprpaperText = let
    specificImage = "${wallpaperDir}/kasane_teto_utau_drawn_by_yananami_numata220.jpg";
    preloads = ["preload = ${specificImage}"];
    wallpaperLine = ["wallpaper = , ${specificImage}"];
  in
    lib.concatStringsSep "\n" (preloads ++ wallpaperLine) + "\n";

  hyprpaperConf = pkgs.writeText "hyprpaper.conf" hyprpaperText;
in {
  inherit images hyprpaperText hyprpaperConf;
}
