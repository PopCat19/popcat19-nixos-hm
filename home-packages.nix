# Home Manager Package Configuration
# This file contains all user packages for the home configuration
# Imported by home.nix

{ pkgs, inputs, system }:

with pkgs; [
  btop-rocm                              # Added by nixpkg
  # ─── CORE DESKTOP APPLICATIONS ───
  kitty                              # Terminal emulator (configured above)
  fuzzel                             # Application launcher (configured above)
  micro                              # Text editor (configured below)

  # ─── WEB BROWSERS ───
  inputs.zen-browser.packages."${system}".default # Zen browser (flake input)
  firefox                            # Firefox browser (moved from system-level)

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

  # ─── DEVELOPMENT TOOLS ───
  jdk                                # Java Development Kit (moved from system-level)
  nodejs                             # Node.js runtime (moved from system-level)
  git-lfs                            # Git Large File Storage
  jq                                 # JSON processor
  tree                               # Directory tree display
  eza                                # Modern ls replacement (used in fish abbrs)
  starship                           # Shell prompt (configured above)

  # ─── FILE MANAGERS (ADDITIONAL) ───
  ranger                             # Terminal file manager (moved from system-level)
  superfile                          # Modern terminal file manager (moved from system-level)

  # ─── GRAPHICS TOOLS ───
  hyprpicker                         # Color picker for Hyprland
  pureref                            # Reference viewer

  # ─── SCREENSHOT AND CLIPBOARD TOOLS ───
  grim                               # Screenshot utility for Wayland
  slurp                              # Screen area selection for Wayland
  wl-clipboard                       # Clipboard utilities for Wayland
  wtype                              # Wayland typing utility for auto-pasting

  # ─── HYPRLAND ECOSYSTEM ───
  hyprpolkitagent                    # Polkit agent for Hyprland
  hyprutils                          # Hyprland utilities
  hyprshade                          # Screen shader manager
  hyprpanel                          # Panel for Hyprland (using package until HM module is fixed)

  # ─── GAMING AND PERFORMANCE ───
  obs-studio                         # Screen recording and streaming
  lutris                             # Gaming platform
  osu-lazer-bin                      # Rhythm game

  # ─── AUDIO CONTROL ───
  pavucontrol                        # PulseAudio volume control GUI
  playerctl                          # Media player control (used by services)

  # ─── SYSTEM MONITORING ───
  glances                            # System monitor

  # ─── HARDWARE CONTROL ───
  ddcui                              # Display configuration utility
  openrgb-with-all-plugins           # RGB lighting control

  # ─── MOBILE AND ANDROID TOOLS ───
  universal-android-debloater        # Android debloating tool
  android-tools                      # ADB and other Android utilities
  scrcpy                             # Android screen mirroring
  sidequest                          # Quest 2 adb manager

  # ─── GAME STREAMING ───
  moonlight-qt                       # Moonlight game streaming client

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
  code-cursor-fhs                    # LLM oriented text editor
  vscodium.fhs                       # VSCodium with fhs

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

  # ─── SYSTEM INTEGRATION ───
  libnotify                          # Desktop notifications
  zenity                             # Dialog boxes for scripts
  dunst                              # Notification daemon

  # ─── UTILITIES ───
  fastfetch                          # System information display
]
