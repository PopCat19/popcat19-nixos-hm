# Home Manager Package Configuration
# This file contains all user packages for the home configuration
# Imported by home.nix

{ pkgs, inputs, system }:

with pkgs; [
  # ─── CORE DESKTOP APPLICATIONS ───
  kitty                              # Terminal emulator (configured above)
  fuzzel                             # Application launcher (configured above)
  micro                              # Text editor (configured below)

  # ─── THEME MANAGEMENT TOOLS ───
  nwg-look                           # GTK theme configuration GUI
  dconf-editor                       # dconf settings editor
  libsForQt5.qt5ct                   # Qt5 configuration tool
  qt6ct                              # Qt6 configuration tool (used in environment vars)
  themechanger                       # Theme switching utility

  # ─── ROSE PINE THEME PACKAGES ───
  rose-pine-kvantum                  # Kvantum Rose Pine themes
  rose-pine-gtk-theme-full           # Complete Rose Pine GTK theme (custom package)
  inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default # Rose Pine cursors

  # ─── FONTS ───
  nerd-fonts.jetbrains-mono          # Programming font with icons (used in Kitty)
  nerd-fonts.caskaydia-cove          # Alternative programming font
  nerd-fonts.fantasque-sans-mono     # Another programming font option
  noto-fonts                         # Comprehensive Unicode support
  noto-fonts-cjk-sans               # CJK (Chinese/Japanese/Korean) support
  noto-fonts-emoji                   # Emoji support
  font-awesome                       # Icon font

  # ─── FILE MANAGERS ───
  kdePackages.dolphin                # Primary file manager (KDE, themed via kdeglobals)
  nautilus                           # GNOME file manager (backup)
  nemo                               # Cinnamon file manager (configured below)

  # ─── MEDIA APPLICATIONS ───
  mpv                                # Video player (used in MIME associations)
  audacious                          # Audio player
  audacious-plugins                  # Audio player plugins
  kdePackages.gwenview               # Image viewer (used in MIME associations)
  kdePackages.okular                 # PDF viewer (used in MIME associations)

  # ─── ARCHIVE MANAGEMENT ───
  kdePackages.ark                    # Archive manager (used in MIME associations)

  # ─── WEB BROWSER ───
  inputs.zen-browser.packages."${system}".default # Zen browser (flake input)

  # ─── DEVELOPMENT TOOLS ───
  git-lfs                            # Git Large File Storage
  jq                                 # JSON processor (used in screenshot scripts)
  tree                               # Directory tree display
  eza                                # Modern ls replacement (used in fish abbrs)
  starship                           # Shell prompt (configured above)

  # ─── SCREENSHOT AND GRAPHICS TOOLS ───
  grim                               # Wayland screenshot utility (used in scripts)
  slurp                              # Region selection for screenshots (used in scripts)
  wl-clipboard                       # Wayland clipboard utilities (used in scripts)
  swappy                             # Screenshot annotation tool
  satty                              # Another screenshot annotation tool
  hyprpicker                         # Color picker for Hyprland

  # ─── HYPRLAND ECOSYSTEM ───
  hyprpolkitagent                    # Polkit agent for Hyprland
  hyprutils                          # Hyprland utilities
  hyprshade                          # Screen shader manager (used in screenshot scripts)
  hyprpanel                          # Panel for Hyprland

  # ─── GAMING AND PERFORMANCE ───
  mangohud                           # Gaming performance overlay (configured above)
  goverlay                           # MangoHud configuration GUI
  obs-studio                         # Screen recording and streaming
  lutris                             # Gaming platform
  osu-lazer-bin                      # Rhythm game

  # ─── AUDIO CONTROL ───
  pavucontrol                        # PulseAudio volume control GUI
  playerctl                          # Media player control (used by services)

  # ─── SYSTEM MONITORING ───
  btop-rocm                          # System monitor with ROCm support
  glances                            # System monitor

  # ─── HARDWARE CONTROL ───
  ddcui                              # Display configuration utility
  openrgb-with-all-plugins           # RGB lighting control

  # ─── MOBILE AND ANDROID TOOLS ───
  universal-android-debloater        # Android debloating tool
  android-tools                      # ADB and other Android utilities
  scrcpy                             # Android screen mirroring

  # ─── EMBEDDED SYSTEMS TOOLS ───
  sunxi-tools                        # Tools for Allwinner SoCs
  binwalk                            # Firmware analysis tool
  vboot_reference                    # ChromeOS bootloader tools

  # ─── SYSTEM UTILITIES ───
  pv                                 # Progress viewer
  parted                             # Partition management
  squashfsTools                      # SquashFS utilities
  nixos-install-tools                # NixOS installation utilities
  nixos-generators                   # NixOS image generators

  # ─── NETWORKING AND SHARING ───
  localsend                          # Local file sharing
  zrok                               # Zero-trust networking
  vesktop                            # Discord client with better Wayland support

  # ─── PRODUCTIVITY APPLICATIONS ───
  keepassxc                          # Password manager
  zed-editor_git                     # Modern text editor

  # ─── ENTERTAINMENT ───
  mangayomi                          # Manga reader

  # ─── AI/ML TOOLS ───
  ollama-rocm                        # Local AI models with ROCm acceleration (used by service)

  # ─── THUMBNAIL GENERATION ───
  # These packages enable thumbnail generation for various file types in file managers
  ffmpegthumbnailer                  # Video thumbnails
  poppler_utils                      # PDF thumbnails
  libgsf                             # Office document thumbnails
  webp-pixbuf-loader                 # WebP image support
  kdePackages.kdegraphics-thumbnailers # KDE thumbnail generators
  kdePackages.kimageformats          # Additional image format support
  kdePackages.kio-extras             # KDE I/O plugins

  # ─── ADDITIONAL THEME PACKAGES ───
  # These provide alternative themes and ensure broad compatibility
  catppuccin-gtk                     # Alternative theme option
  catppuccin-cursors                 # Alternative cursor theme
  papirus-icon-theme                 # Icon theme (used throughout config)
  adwaita-icon-theme                 # Fallback icon theme

  # ─── SYSTEM INTEGRATION ───
  polkit_gnome                       # GNOME polkit agent (used by systemd service)
  gsettings-desktop-schemas          # GSettings schemas for desktop integration
  libnotify                          # Desktop notifications (used in screenshot scripts)
  zenity                             # Dialog boxes for scripts

  # ─── UTILITIES ───
  fastfetch                          # System information display
]
