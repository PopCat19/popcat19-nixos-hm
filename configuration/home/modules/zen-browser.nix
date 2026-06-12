# zen-browser.nix
#
# Purpose: Configure Zen Browser with extensions
#
# This module:
# - Imports Zen Browser Home Manager module
# - Configures browser policies and extensions
# - Manages profiles.ini to use home-manager profile (for Stylix)

{
  config,
  inputs,
  ...
}:
let
  forceInstall = "force_installed";
  homeDir = config.home.homeDirectory;
in
{
  imports = [ inputs.zen-browser.homeModules.twilight ];

  # Point Zen's profiles.ini to the home-manager managed profile
  # This ensures Stylix theming works on all hosts automatically
  home.file.".zen/profiles.ini".text = ''
    [General]
    StartWithLastProfile=1
    Version=2

    [Profile0]
    Default=1
    IsRelative=0
    Name=default
    Path=${homeDir}/.config/zen/default
  '';

  programs.zen-browser = {
    enable = true;

    policies = {
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      EnableTrackingProtection = {
        Cryptomining = true;
        Fingerprinting = true;
        Locked = true;
        Value = true;
      };
      ExtensionSettings = {
        # Dark Reader
        "addon@darkreader.org" = {
          inherit forceInstall;
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        };
        # Return YouTube Dislikes
        "{762f9885-5a13-4abd-9c77-433d12138f26}" = {
          inherit forceInstall;
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
        };
        # SponsorBlock
        "sponsorBlocker@ajay.app" = {
          inherit forceInstall;
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
        };
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          inherit forceInstall;
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
        # YouTube NonStop
        "youtube-nonstop@eliasfox" = {
          inherit forceInstall;
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-nonstop/latest.xpi";
        };
      };
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      Preferences = {
        "browser.compactmode.show" = {
          Status = "locked";
          Value = true;
        };
        "browser.startup.page" = {
          Status = "locked";
          Value = 3;
        };
        "browser.tabs.warnOnClose" = {
          Status = "locked";
          Value = true;
        };
        "zen.theme.mode" = {
          Status = "locked";
          Value = "dark";
        };
        "zen.view.compact" = {
          Status = "locked";
          Value = true;
        };
      };
    };
  };
}
