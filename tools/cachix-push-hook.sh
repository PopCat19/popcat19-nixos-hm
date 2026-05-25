#!/usr/bin/env bash
# cachix-push-hook.sh
#
# Purpose: Nix post-build-hook that pushes built derivations to Cachix
#
# This script:
# - Reads $OUT_PATHS from the environment (set by nix)
# - Pushes each output path to popcat19-shared Cachix cache
# - Spawns pushes in parallel, waits for all to complete
# - Skips silently if cachix is not available
set -euo pipefail

CACHE="popcat19-shared"

if ! command -v cachix &>/dev/null; then
	exit 0
fi

for path in $OUT_PATHS; do
	cachix push "$CACHE" "$path" &
done

wait
