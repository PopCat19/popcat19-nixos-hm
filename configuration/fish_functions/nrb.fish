# nrb.fish
#
# Purpose: Shortcut for nixos-rebuild-basic
#
# Runs passwordless: security.sudo.extraRules in
# configuration/system/modules/users.nix whitelists `nh` and
# `nixos-rebuild` as NOPASSWD for the user. n-basic calls one of those
# under sudo, so no prompt is expected on a configured host.
function nrb
    nixos-rebuild-basic $argv
end
