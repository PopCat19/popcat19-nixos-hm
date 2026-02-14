# localization.nix
#
# Purpose: Configure system locale and timezone
#
# This module:
# - Sets timezone to America/New_York
# - Configures English UTF-8 locale
{ lib, ... }:
{
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault "America/New_York";
}
