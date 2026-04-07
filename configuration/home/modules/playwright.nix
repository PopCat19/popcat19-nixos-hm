# playwright.nix
#
# Purpose: Configure Playwright browser testing environment for NixOS
#
# This module:
# - Provides Playwright browsers from nixpkgs (avoids broken native installs)
# - Sets environment variables for browser path and host requirement bypass
{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.playwright-driver.browsers
    pkgs.playwright-mcp
  ];

  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
    PLAYWRIGHT_HOST_PLATFORM_OVERRIDE = "ubuntu-24.04";
  };
}
