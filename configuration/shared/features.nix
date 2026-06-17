# features.nix
#
# Purpose: Configure features settings across all hosts
#
{
  zrok = {
    enable = false;
  };
  sillytavern = {
    enable = false;
  };
  odysseus = {
    enable = false;
    environmentFile = null;
    openFirewall = false;
  };
}
