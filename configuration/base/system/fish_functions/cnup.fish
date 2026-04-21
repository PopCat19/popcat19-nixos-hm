# cnup.fish
#
# Purpose: Format and validate Nix code with optional flake check
#
# This module:
# - Runs statix, deadnix, and treefmt formatters
# - Optionally executes nix flake check
# - Handles sandbox settings for older kernels

function cnup
    argparse no-flake no-check -- $argv
    begin
        if test -d .git
            git add --intent-to-add . 2>/dev/null; or true
        end
        set -l use_nix_shell false
        for cmd in statix deadnix treefmt
            if not command -q $cmd
                set use_nix_shell true
                break
            end
        end

        set -l sandbox_args
        set -l nixshell_sandbox_args
        set -l kver (uname -r)
        if string match -qr '^([0-4]\.|5\.[0-5][^0-9])' "$kver"
            set_color yellow
            echo "[WARN] Kernel $kver (< 5.6) detected. Disabling sandbox."
            set_color normal
            set sandbox_args --option sandbox false
            set nixshell_sandbox_args --no-sandbox
        else
            set_color green
            echo "[INFO] Kernel $kver detected. Using default sandbox."
            set_color normal
        end

        set -l check_cmd ''
        if not set -q _flag_no_flake; and not set -q _flag_no_check
            set check_cmd "&& nix flake check --impure --accept-flake-config $sandbox_args"
        end

        if test $use_nix_shell = true
            nix-shell $nixshell_sandbox_args -p statix deadnix nixfmt-tree --run "statix fix . && deadnix -e . && treefmt .$check_cmd"
        else
            eval "statix fix . && deadnix -e . && treefmt .$check_cmd"
        end
    end
end
