# vscodium.nix
#
# Purpose: Configure VSCodium editor with extensions and settings
#
# This module:
# - Enables VSCodium (VS Code without telemetry)
# - Configures Nix language support extensions
# - Sets editor preferences and keybindings
{ pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isx86_64;
in
{
  programs.vscodium = {
    enable = true;

    profiles.default = {
      extensions =
        (with pkgs.vscode-extensions; [
          jnoortheen.nix-ide
          redhat.vscode-yaml
          rust-lang.rust-analyzer
        ])
        ++ pkgs.lib.optionals isx86_64 [ pkgs.vscode-extensions.redhat.vscode-xml ];

      userSettings = {
        "editor.minimap.enabled" = true;
        "editor.minimap.renderCharacters" = true;

        "extensions.experimental.affinity" = {
          "ms-vscode.vscode-typescript-next" = 1;
          "ms-vscode.vscode-json" = 1;
          "vscode.yaml" = 1;
        };

        "files.autoSave" = "onFocusChange";
        "files.autoSaveDelay" = 1000;
        "files.insertFinalNewline" = true;
        "files.trimFinalNewlines" = true;
        "files.trimTrailingWhitespace" = true;
        "files.watcherExclude" = {
          "**/.git/objects/**" = true;
          "**/.git/subtree-cache/**" = true;
          "**/.hg/store/**" = true;
          "**/node_modules/*/**" = true;
          "**/target/debug/**" = true;
        };

        "git.autofetch" = true;
        "git.confirmSync" = false;
        "git.enableCommitSigning" = true;
        "git.enableSmartCommit" = true;

        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = "nixfmt";
        "nix.serverPath" = "nixd";

        "redhat.telemetry.enabled" = false;

        "security.workspace.trust.enabled" = true;
        "security.workspace.trust.startupPrompt" = "never";
        "security.workspace.trust.untrustedFiles" = "open";

        "terminal.integrated.defaultProfile.linux" = "fish";

        "workbench.activityBar.location" = "bottom";
        "workbench.colorTheme" = "Stylix";
        "workbench.preferredDarkColorTheme" = "Stylix";
        "workbench.preferredLightColorTheme" = "Stylix";
        "kilo-code.debug" = false;
        "kilo-code.allowedCommands" = [ ];
        "kilo-code.deniedCommands" = [ ];
      };
    };
  };
}
