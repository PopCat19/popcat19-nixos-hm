{ lib
, stdenvNoCC
, fetchFromGitHub
, gtk3
, gtk4
, gnome-themes-extra
, gtk-engine-murrine
, gtk_engines
}:

stdenvNoCC.mkDerivation rec {
  pname = "rose-pine-gtk-theme-full";
  version = "2024-12-21";

  src = fetchFromGitHub {
    owner = "Fausto-Korpsvart";
    repo = "Rose-Pine-GTK-Theme";
    rev = "main";
    sha256 = "sha256-wFzyF59jjudjOoS/K5zmlNUbEZcHhp5kkcbrd8k0CC4=";
  };

  buildInputs = [
    gtk3
    gtk4
    gnome-themes-extra
    gtk_engines
  ];

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    # Create destination directories
    mkdir -p $out/share/themes
    mkdir -p $out/share/icons

    # Install Rose Pine Main BL-GS theme (borderless, perfect for Hyprland)
    mkdir -p "$out/share/themes/Rose-Pine-Main-BL-GS"

    # Copy GTK theme files
    cp -r themes/src/main/* "$out/share/themes/Rose-Pine-Main-BL-GS/"

    # Copy assets
    cp -r themes/src/assets/* "$out/share/themes/Rose-Pine-Main-BL-GS/"

    # Install Rose Pine Moon BL-GS theme
    mkdir -p "$out/share/themes/Rose-Pine-Moon-BL-GS"
    cp -r themes/src/main/* "$out/share/themes/Rose-Pine-Moon-BL-GS/"
    cp -r themes/src/assets/* "$out/share/themes/Rose-Pine-Moon-BL-GS/"

    # Install icon themes
    cp -r icons/Rose-Pine "$out/share/icons/"
    cp -r icons/Rose-Pine-Moon "$out/share/icons/"

    # Create index.theme files for proper theme recognition
    cat > "$out/share/themes/Rose-Pine-Main-BL-GS/index.theme" << 'EOF'
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=Rose Pine Main BL-GS
Comment=Rose Pine dark theme with borderless windows, optimized for Hyprland
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=Rose-Pine-Main-BL-GS
MetacityTheme=Rose-Pine-Main-BL-GS
IconTheme=Rose-Pine
CursorTheme=rose-pine-hyprcursor
ButtonLayout=appmenu:minimize,maximize,close
EOF

    cat > "$out/share/themes/Rose-Pine-Moon-BL-GS/index.theme" << 'EOF'
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=Rose Pine Moon BL-GS
Comment=Rose Pine moon theme with borderless windows, optimized for Hyprland
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=Rose-Pine-Moon-BL-GS
MetacityTheme=Rose-Pine-Moon-BL-GS
IconTheme=Rose-Pine-Moon
CursorTheme=rose-pine-hyprcursor
ButtonLayout=appmenu:minimize,maximize,close
EOF

    # Fix permissions
    find $out/share -type f -exec chmod 644 {} \;
    find $out/share -type d -exec chmod 755 {} \;

    runHook postInstall
  '';

  meta = with lib; {
    description = "Rose Pine GTK theme with borderless design optimized for Hyprland";
    longDescription = ''
      A complete Rose Pine theme suite with borderless windows (BL-GS variant)
      optimized for tiling window managers like Hyprland. Features modern
      rounded design elements and floating panel style.

      Includes both Main (default dark) and Moon (darker) variants with
      matching icon themes from Fausto-Korpsvart's enhanced Rose Pine collection.
    '';
    homepage = "https://github.com/Fausto-Korpsvart/Rose-Pine-GTK-Theme";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
