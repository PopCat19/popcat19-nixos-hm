# ~/nixos-config/home.nix
{ pkgs, config, lib, inputs, ... }:

{
  home.username = "popcat19";
  home.homeDirectory = "/home/popcat19";
  home.stateVersion = "24.05";

  home.sessionVariables = {
    EDITOR = "micro";
    VISUAL = "$EDITOR"; # or "micro" directly
  };

  home.packages = with pkgs; [
    # Terminals, Launchers, Notifications
    kitty
    fuzzel
    # dunst # Managed by services.dunst.enable now
    # Hyprland specific tools
    hyprland # Make sure hyprland itself is listed if not using programs.hyprland module
    hyprpaper
    swww
    grim
    slurp
    wl-clipboard
    # cliphist # Managed by programs.cliphist.enable now
    jq
    hyprpolkitagent
    hyprutils
    hyprshade
    hyprpanel
    # Desktop Utilities
    vesktop
    zed-editor_git
    # blueberry # Managed by services.blueman.applet.enable now
    # udiskie # Managed by services.udiskie.enable now
    kdePackages.dolphin
    pavucontrol
    starship # programs.starship.enable is also below
    eza
    pkgs.libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    pkgs.rose-pine-kvantum
    pkgs.themechanger
    nwg-look
    kdePackages.ark
    ddcui
    # easyeffects # Managed by services.easyeffects.enable now
    papirus-icon-theme
    kdePackages.gwenview
    mpv
    ollama-rocm
    audacious
    audacious-plugins
    lutris
    mangohud
    goverlay
    scrcpy
    openrgb-with-all-plugins
    btop-rocm
    tree
    # Add fcitx5 and configtool if you want to configure it via GUI
    # fcitx5
    # fcitx5-configtool
  ];

  # --- Migrated exec-once services ---
  services.blueman-applet.enable = true;
  services.udiskie.enable = true;
  services.network-manager-applet.enable = true; # For the tray icon
  services.dunst.enable = true; # Watch since hyprpanel might not launch when dunst is already running
  services.easyeffects.enable = true;

  services.cliphist = { # Add or modify this block
    enable = true;
    # You might also need to specify the package if it's not inferred
    # package = pkgs.cliphist;
    # Check for options like 'maxEntries' or similar if you want to configure them
    # settings = {
    #   max_entries = 100; # Example, check actual option name
    # };
  };

  i18n.inputMethod = {
    type = "fcitx5";    # New way
    enable = true;      # New way
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      libsForQt5.fcitx5-qt
      fcitx5-mozc
    ];
  };
  # --- End of migrated exec-once services ---

  home.file.".config/hypr" = {
    source = ./hypr_config; # Path relative to home.nix
    recursive = true;
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      set -Ux NIXOS_CONFIG_DIR $HOME/nixos-config
      set -Ux NIXOS_FLAKE_HOSTNAME popcat19-nixos0 # Confirm this is still correct
      set -g fish_greeting "" # Clears the default greeting
      # Starship init
      if status is-interactive
          starship init fish | source
      end
    '';
    shellAbbrs = {
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";
      mkdir = "mkdir -p";
      # Abbreviations for your NixOS functions
      nconf = "nixconf-edit";
      nixos-ed = "nixconf-edit";
      hconf = "homeconf-edit";
      home-ed = "homeconf-edit";
      flconf = "flake-edit";     # Flake Config
      flake-ed = "flake-edit";   # Keeping this for muscle memory if you like      flup = "flake-update";
      flake-up = "flake-update";
      ngit = "nixos-git";

      # === UPDATED/NEW REBUILD ABBREVIATIONS ===
      # 'nrb' and 'nixos-sw' now point to the intelligent apply function
      nrb = "nixos-apply-config";        # Short for NixOS ReBuild (now intelligent)
      nixos-sw = "nixos-apply-config";   # NixOS Switch (now intelligent)

      # 'nerb' and 'nixoss' already use nixos-edit-rebuild, which now calls nixos-apply-config
      nerb = "nixos-edit-rebuild";
      nixoss = "nixos-edit-rebuild";
      # 'herb' and 'home-sw' already use home-edit-rebuild, which now calls nixos-apply-config
      herb = "home-edit-rebuild";
      home-sw = "home-edit-rebuild";

      # 'nup' and 'nixos-up' already use nixos-upgrade, which now calls nixos-apply-config
      nup = "nixos-upgrade";
      nixos-up = "nixos-upgrade";

      # If you kept the old simple nixos-rebuild-switch.fish and want an abbr for it:
      # nrbs = "nixos-rebuild-switch"; # NixOS ReBuild Switch (simple)
      # Your eza aliases
      l = "eza -lh --icons=auto";
      ls = "eza -1 --icons=auto";
      ll = "eza -lha --icons=auto --sort=name --group-directories-first";
      ld = "eza -lhD --icons=auto";
      lt = "eza --tree --icons=auto";
    };
    # plugins = [ # Only if you use a fish plugin manager that HM supports this way
    #   { name = "starship"; src = pkgs.starship.src; }
    # ];
  };

  home.file.".config/fish/functions" = {
    source = ./fish_functions; # Links your custom functions
    recursive = true;
  };

  home.file.".config/fish/themes" = {
    source = ./fish_themes; # Links your themes
    recursive = true;
  };

  programs.starship = {
    enable = true;
    # If you have a starship.toml, you can link it:
    # package = pkgs.starship; # Ensure starship package is used
    # settings = lib.importTOML ./starship_config/starship.toml; # Create ./starship_config/starship.toml
  };

  programs.git = {
    enable = true;
    userName = "PopCat19";
    userEmail = "atsuo11111@gmail.com"; # <<< IMPORTANT: Update this email
  };
}
