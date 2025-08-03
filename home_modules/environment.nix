{ lib, ... }:

{
  # **ENVIRONMENT VARIABLES**
  # Defines user-specific environment variables for various applications.
  home.sessionVariables = {
    EDITOR = "micro"; # Default terminal editor.
    VISUAL = "$EDITOR"; # Visual editor alias.
    BROWSER = "zen-twilight"; # Default web browser.
    TERMINAL = "kitty";
    FILE_MANAGER = "dolphin";
    # Ensure thumbnails work properly
    WEBKIT_DISABLE_COMPOSITING_MODE = "1";

    # Input Method (fcitx5) with Wayland support
    GTK_IM_MODULE = lib.mkForce "fcitx5";
    QT_IM_MODULE = lib.mkForce "fcitx5";
    XMODIFIERS = lib.mkForce "@im=fcitx5";
    # Firefox/Zen Browser specific for Wayland input method
    MOZ_ENABLE_WAYLAND = "1";
    GTK4_IM_MODULE = "fcitx5";
  };

  # Add local bin to PATH
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];
}