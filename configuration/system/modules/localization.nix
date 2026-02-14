# localization.nix
#
# Purpose: Configure system locale and timezone
#
# This module:
# - Sets timezone to America/New_York
# - Configures English UTF-8 locale
_: {
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/New_York";
}
