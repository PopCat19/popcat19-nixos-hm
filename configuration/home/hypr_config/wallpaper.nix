# Wallpaper Discovery Module
#
# Purpose: Discover and list image files from wallpaper directory
# Dependencies: None
# Related: hyprland.nix
#
# This module:
# - Forces wallpaper directory inclusion in Nix store
# - Filters files by image extension (jpg, jpeg, png, webp, bmp)
# - Returns list of absolute paths to image files
{lib, ...}: let
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
in {
  inherit images;
}
