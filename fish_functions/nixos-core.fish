#!/usr/bin/env fish
# ~/nixos-config/fish_functions/nixos-core.fish
# ⚠️ DEPRECATED: This file is deprecated and will be removed in a future version
# 
# Core functionality has been moved to modular components:
# - Environment validation: nixos-env-core.fish
# - System operations: nixos-system-core.fish
# - Utility functions: nixos-utils-core.fish
# - Git operations: nixos-git-core.fish
#
# Please update your scripts to source the specific modules you need.
# This file remains for backward compatibility but will be removed.

echo "⚠️  WARNING: nixos-core.fish is deprecated" >&2
echo "   Please source individual modules instead:" >&2
echo "   - nixos-env-core.fish (environment validation)" >&2
echo "   - nixos-system-core.fish (system operations)" >&2
echo "   - nixos-utils-core.fish (utility functions)" >&2
echo "   - nixos-git-core.fish (git operations)" >&2

# System operations are now in nixos-system-core.fish
# Utility functions are now in nixos-utils-core.fish
# Environment functions are now in nixos-env-core.fish
