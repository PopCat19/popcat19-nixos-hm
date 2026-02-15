# vscodium.nix
#
# Purpose: Configure VSCodium with mutable settings and stylix theming
#
# This module:
# - Installs VSCodium with essential extensions
# - Seeds default settings via activation script (write-once, merge-on-change)
# - Preserves manual modifications to settings.json

{ lib, pkgs, ... }:
let
  settingsJson = builtins.toJSON {
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
  };
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      redhat.vscode-xml
      redhat.vscode-yaml
      rust-lang.rust-analyzer
    ];
  };

  home.activation.vscodiumSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings_dir="$HOME/.config/VSCodium/User"
    settings_file="$settings_dir/settings.json"

    mkdir -p "$settings_dir"

    if [ ! -f "$settings_file" ]; then
      echo '${settingsJson}' > "$settings_file"
    else
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' \
        "$settings_file" \
        <(echo '${settingsJson}') \
        > "$settings_file.tmp" \
      && mv "$settings_file.tmp" "$settings_file"
    fi
  '';
}
