# default.nix
#
# Purpose: Expose default service via Zrok tunnel
#
{
  imports = [
    ./sillytavern.nix
    ./searxng.nix
    ./odysseus.nix
  ];
}
