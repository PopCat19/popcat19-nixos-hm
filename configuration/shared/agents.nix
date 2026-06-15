# agents.nix
#
# Purpose: Configure agents settings across all hosts
#
{
  agents = {
    enable = false;
    forgecode = false;
    kilocode-cli = false;
    omp = true;
    opencode = false;
    pi = false;
    reasonix = false;
  };
}
