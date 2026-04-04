#!/usr/bin/env bash
# debug-nix-config.sh
#
# Purpose: Diagnose Nix daemon config mismatches
#
# This module:
# - Checks all nix.conf sources for conflicts
# - Compares daemon-reported config vs system config
# - Detects root-level overrides that shadow /etc/nix/nix.conf

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

warn() { echo -e "${YELLOW}WARN${NC} $*"; }
ok() { echo -e "${GREEN}OK${NC}   $*"; }
fail() { echo -e "${RED}FAIL${NC} $*"; }

echo "=== Nix Config Diagnostic ==="
echo ""

# 1. System nix.conf
echo "--- /etc/nix/nix.conf (system) ---"
if [ -f /etc/nix/nix.conf ]; then
	grep -E '^\s*(experimental-features|substituters|trusted-public-keys)\s*=' /etc/nix/nix.conf | sed 's/^/  /'
	ok "/etc/nix/nix.conf exists"
else
	fail "/etc/nix/nix.conf not found"
fi
echo ""

# 2. Root user nix.conf (common override source)
echo "--- /root/.config/nix/nix.conf (root user) ---"
if [ -f /root/.config/nix/nix.conf ]; then
	grep -E '^\s*(experimental-features|substituters|trusted-public-keys)\s*=' /root/.config/nix/nix.conf | sed 's/^/  /'
	warn "Root nix.conf exists and may override system config"
else
	ok "No root-level nix.conf"
fi
echo ""

# 3. Current user nix.conf
echo "--- ~/.config/nix/nix.conf (user) ---"
if [ -f "$HOME/.config/nix/nix.conf" ]; then
	grep -E '^\s*(experimental-features|substituters|trusted-public-keys)\s*=' "$HOME/.config/nix/nix.conf" | sed 's/^/  /'
	warn "User nix.conf exists"
else
	ok "No user-level nix.conf"
fi
echo ""

# 4. Daemon-reported config
echo "--- Daemon-reported config ---"
if command -v nix &>/dev/null; then
	daemon_features=$(sudo nix config show 2>/dev/null | grep experimental-features | awk -F' = ' '{print $2}')
	if [ -n "$daemon_features" ]; then
		echo "  experimental-features = $daemon_features"
	else
		fail "Could not read daemon config"
	fi
fi
echo ""

# 5. Restart trigger check
echo "--- Daemon restart trigger ---"
trigger_file=$(systemctl show nix-daemon.service --property=X-Restart-Triggers 2>/dev/null | sed 's/X-Restart-Triggers=//')
if [ -n "$trigger_file" ] && [ -f "$trigger_file" ]; then
	trigger_content=$(cat "$trigger_file")
	echo "  Trigger: $trigger_file"
	echo "  Points to: $trigger_content"
	if [ -f "$trigger_content" ]; then
		sys_features=$(grep -E '^\s*experimental-features' "$trigger_content" | head -1 | sed 's/.*= //')
		echo "  Features in trigger: $sys_features"
	fi
else
	warn "No restart trigger found or daemon not managed by systemd"
fi
echo ""

# 6. Daemon status
echo "--- Daemon status ---"
if systemctl is-active --quiet nix-daemon 2>/dev/null; then
	ok "nix-daemon is running"
	daemon_pid=$(systemctl show nix-daemon.service --property=MainPID | sed 's/MainPID=//')
	echo "  PID: $daemon_pid"
else
	fail "nix-daemon is not running"
fi
echo ""

echo "=== Done ==="
