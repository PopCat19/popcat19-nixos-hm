#!/usr/bin/env bash

# push-to-cachix.sh
#
# Purpose: Push build derivations to personal Cachix cache
#
# This module:
# - Identifies relevant Nix store paths for the current configuration
# - Authenticates with Cachix using available credentials
# - Uploads binaries to accelerate fleet-wide builds
# - Supports selective host pushing and dry-run mode
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/logging.sh"

# === Configuration ===
CACHE="popcat19-shared"
HOSTS=()
SKIP_HOSTS=()
DRY_RUN=0

# === Usage ===
usage() {
	cat <<'EOF'
Usage: push-to-cachix.sh [OPTIONS]

Options:
    --host HOST              Host to push (can be specified multiple times)
    --all-hosts             Push all hosts
    --skip-host HOST        Skip specific host (can be specified multiple times)
    --dry-run               Show what would be done
    --help                 Show this help

Examples:
    # Push single host
    ./tools/push-to-cachix.sh --host popcat19-nixos0

    # Push multiple hosts
    ./tools/push-to-cachix.sh --host popcat19-nixos0 --host popcat19-thinkpad0

    # Push all hosts except one
    ./tools/push-to-cachix.sh --all-hosts --skip-host popcat19-surface0
EOF
}

# === Parse arguments ===
while [[ $# -gt 0 ]]; do
	case "$1" in
	--host)
		HOSTS+=("${2:-}")
		shift 2
		;;
	--all-hosts)
		ALL_HOSTS=1
		shift
		;;
	--skip-host)
		SKIP_HOSTS+=("${2:-}")
		shift 2
		;;
	--dry-run)
		DRY_RUN=1
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		log_error "Unknown option: $1"
		usage
		exit 1
		;;
	esac
done

# === Helpers ===
is_skipped() {
	local host="$1"
	for skip in "${SKIP_HOSTS[@]}"; do
		[[ "$host" == "$skip" ]] && return 0
	done
	return 1
}

should_push_host() {
	local host="$1"
	if [[ ${#HOSTS[@]} -gt 0 ]]; then
		for h in "${HOSTS[@]}"; do
			[[ "$host" == "$h" ]] && return 0
		done
		return 1
	fi
	[[ "${ALL_HOSTS:-0}" -eq 1 ]] && return 0
	return 1
}

# === Check dependencies ===
check_deps() {
	local missing=()
	for cmd in cachix nix; do
		if ! command -v "$cmd" >/dev/null 2>&1; then
			missing+=("$cmd")
		fi
	done
	if [[ ${#missing[@]} -gt 0 ]]; then
		log_error "Missing dependencies: ${missing[*]}"
		return 1
	fi
}

# === Push host system ===
push_host() {
	local host="$1"
	log_info "Pushing system for host: $host"

	local drv=".#nixosConfigurations.${host}.config.system.build.toplevel"

	if [[ "$DRY_RUN" -eq 1 ]]; then
		log_info "[DRY-RUN] Would push: $drv"
		return 0
	fi

	local store_path
	store_path=$(nix path-info --impure --accept-flake-config "$drv" 2>/dev/null || echo "")

	if [[ -z "$store_path" ]]; then
		log_warn "Could not resolve $drv for host $host"
		return 1
	fi

	log_info "Pushing to $CACHE: $(basename "$store_path")"

	if cachix push "$CACHE" "$store_path" 2>&1 | grep -v -E "(Compressing|All done)" | grep -q .; then
		log_success "Pushed $host"
	else
		log_error "Failed to push $host"
		return 1
	fi
}

# === Main ===
main() {
	log_info "Cachix Push Tool"
	log_info "Cache: $CACHE"

	[[ "$DRY_RUN" -eq 1 ]] && log_warn "DRY-RUN mode enabled"

	check_deps || exit 1

	if [[ ${#HOSTS[@]} -eq 0 && "${ALL_HOSTS:-0}" -eq 0 ]]; then
		log_error "No hosts specified. Use --host or --all-hosts"
		exit 1
	fi

	local failed=0
	for host in "${HOSTS[@]}"; do
		if is_skipped "$host"; then
			log_info "Skipping host: $host"
			continue
		fi

		if ! should_push_host "$host"; then
			continue
		fi

		push_host "$host" || ((failed++))
	done

	[[ $failed -gt 0 ]] && log_error "$failed host(s) failed to push" && exit 1

	log_success "Cachix push complete"
}

main "$@"
