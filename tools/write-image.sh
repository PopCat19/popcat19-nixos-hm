#!/usr/bin/env bash

# write-image.sh
#
# Purpose: Safely write a flake-built installer image to a target device
#
# This module:
# - Builds the installer-zst image or uses a pre-built path
# - Auto-detects removable USB/SD candidate devices (excludes system disks)
# - Handles zstd decompression
# - Interactive device selection with countdown confirmation
# - Unmounts UDisks-managed mounts before writing
# - Provides onboarding when run without arguments

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

BOLD='\033[1m'
DIM='\033[2m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
MAGENTA='\033[35m'
CYAN='\033[36m'
CLEAR='\033[0m'

info() { echo -e "${CYAN}$*${CLEAR}"; }
ok() { echo -e "${GREEN}$*${CLEAR}"; }
warn() { echo -e "${YELLOW}WARN:${CLEAR} $*" >&2; }
err() { echo -e "${RED}ERROR:${CLEAR} $*" >&2; }
bold() { echo -e "${BOLD}$*${CLEAR}"; }
action() { echo -e "${MAGENTA}$*${CLEAR}"; }
dim() { echo -e "${DIM}$*${CLEAR}"; }

ARG_IMAGE=""
ARG_DEV=""
ARG_TYPE=""
ARG_YES=false
ARG_COUNT=10
ARG_DRY=false
SYSTEM_PKNAMES=""

usage() {
	cat <<'EOF'
write-image.sh [installer] [-d /dev/sdX] [-i image.zst] [-y] [-n]

Write a flake-built NixOS installer image to a target device.

  installer             Image type (default: asks if not given)
  -d PATH                Target device (e.g., /dev/sda). Prompts if omitted.
  -i PATH                Pre-built image. Skips flake build if given.
  -y                     Skip countdown confirmation.
  -n                     Dry-run: show plan without writing.

Examples:
  sudo ./tools/write-image.sh installer -d /dev/sdd
  sudo ./tools/write-image.sh -i /tmp/installer.img.zst -d /dev/sdc
EOF
}

pk_of() {
	local s
	s="$(readlink -f "${1:-}" 2>/dev/null)" || s="$1"
	lsblk -no PKNAME "$s" 2>/dev/null | head -n1 || lsblk -no NAME "$s" 2>/dev/null | head -n1
}

collect_system_pknames() {
	SYSTEM_PKNAMES=""
	local src pk
	for mp in / /home /boot /boot/efi; do
		src="$(findmnt -no SOURCE "$mp" 2>/dev/null)" || continue
		pk="$(pk_of "$src")" && [[ -n "$pk" ]] || continue
		[[ " ${SYSTEM_PKNAMES} " == *" $pk "* ]] && continue
		SYSTEM_PKNAMES="${SYSTEM_PKNAMES} $pk"
	done
	if [[ -r /proc/swaps ]]; then
		while read -r f t _; do
			[[ "$f" == Filename* ]] && continue
			[[ "$t" == partition || "$f" == /dev/* ]] || continue
			pk="$(pk_of "$f")" && [[ -n "$pk" ]] || continue
			[[ " ${SYSTEM_PKNAMES} " == *" $pk "* ]] && continue
			SYSTEM_PKNAMES="${SYSTEM_PKNAMES} $pk"
		done < <(awk '{print $1,$2}' /proc/swaps)
	fi
}

is_system_pk() { [[ -n "${1:-}" && " ${SYSTEM_PKNAMES} " == *" $1 "* ]]; }

list_candidates() {
	bold "SAFE devices (removable, unmounted, non-system):"
	printf "%-16s %-10s %-8s %-4s %s\n" "DEVICE" "SIZE" "TRAN" "RM" "MODEL"
	echo "--------------------------------------------------------------------------------"
	while IFS='|' read -r name path size model tran rm type; do
		[[ "$type" == disk ]] || continue
		[[ "$name" =~ ^loop|^zram|^ram|^md|^dm- ]] && continue
		is_system_pk "$name" && continue
		lsblk -nr "$path" -o MOUNTPOINT | grep -qE '\S' && continue
		printf "%-16s %-10s %-8s %-4s %s\n" "$path" "$size" "$tran" "$rm" "$model"
	done < <(lsblk -dn -o NAME,PATH,SIZE,MODEL,TRAN,RM,TYPE | awk '
    { n=$1; p=$2; s=$3; m=""; rm=""; t=""
      for(i=4;i<=NF-3;i++) m=m $i " "
      t=$(NF-2); rm=$(NF-1); type=$(NF)
      gsub(/ *$/,"",m)
      print n "|" p "|" s "|" m "|" t "|" rm "|" type }')
}

udisks_running() {
	pgrep -x udisksd &>/dev/null || systemctl is-active --quiet udisks2.service 2>/dev/null
}

udisks_unmount() {
	local dev="$1" parts re="" p
	mapfile -t parts < <(lsblk -nr "$dev" -o PATH | tail -n +2 || true)
	((${#parts[@]})) || return 0
	for p in "${parts[@]}"; do re+="|^${p//\//\\/}\$"; done
	re="${re#|}"
	while IFS='|' read -r src tgt _; do
		[[ "$src" =~ $re ]] || continue
		action "Unmounting $tgt ($src)"
		command -v udisksctl &>/dev/null && udisksctl unmount -b "$src" >/dev/null 2>&1 || true
		umount "$tgt" >/dev/null 2>&1 || true
	done < <(findmnt -rn -o SOURCE,TARGET | sed 's/  */|/')
}

validate_device() {
	local dev="$1" t pk
	[[ -b "$dev" ]] || {
		err "$dev is not a block device."
		return 1
	}
	t="$(lsblk -dno TYPE "$dev" 2>/dev/null)"
	[[ "$t" == disk ]] || {
		err "$dev is TYPE=$t, not a whole disk."
		return 1
	}
	pk="$(pk_of "$dev")"
	is_system_pk "$pk" && {
		err "Refusing to write to a system disk ($pk)."
		return 1
	}
}

build_image() {
	local type="$1" attr
	case "$type" in
	installer) attr="installer-zst" ;;
	*)
		err "Unknown type: $type"
		return 1
		;;
	esac
	action "Building .#$attr ..."
	nix build "$REPO_DIR#$attr" --accept-flake-config --no-link --print-out-paths
}

onboard() {
	echo
	bold "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	bold "  NixOS Image Writer"
	bold "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	echo
	echo "This tool writes a flake-built NixOS installer image to a USB stick or SD card."
	echo

	ARG_TYPE="installer"

	echo "1. Build fresh or use pre-built image?"
	echo "   ${BOLD}[b]${CLEAR} build   nix build .#installer-zst"
	echo "   ${BOLD}[p]${CLEAR} path    I already have a .img/.img.zst"
	echo
	read -r -p "   Choose [b/p]: " choice
	case "${choice,,}" in
	b | build)
		ARG_IMAGE=""
		;;
	p | path)
		read -r -p "   Path to image file: " img_in
		ARG_IMAGE="$img_in"
		;;
	*)
		err "Invalid choice."
		exit 1
		;;
	esac
	echo

	list_candidates
	echo
	read -r -p "2. Target device path [e.g., /dev/sda]: " ARG_DEV
	[[ -n "${ARG_DEV:-}" ]] || {
		err "No device entered."
		exit 4
	}
	echo

	info "Ready to write installer image to $ARG_DEV."
	read -r -p "Press Enter to continue or Ctrl-C to abort." _
}

main() {
	local img_bytes dev_bytes dev_human img_human model tran write_path out

	while (($#)); do
		case "$1" in
		installer)
			ARG_TYPE="$1"
			shift
			;;
		-d)
			ARG_DEV="${2:-}"
			shift 2
			;;
		-i)
			ARG_IMAGE="${2:-}"
			shift 2
			;;
		-y)
			ARG_YES=true
			shift
			;;
		-n)
			ARG_DRY=true
			shift
			;;
		-h)
			usage
			exit 0
			;;
		*)
			err "Unknown: $1"
			usage
			exit 2
			;;
		esac
	done

	[[ ${EUID:-$(id -u)} -ne 0 ]] && exec sudo "$0" "$@"

	collect_system_pknames

	if [[ -z "$ARG_IMAGE" ]]; then
		if [[ -z "$ARG_TYPE" ]]; then
			onboard
		fi
	fi

	if [[ -z "$ARG_TYPE" && -z "$ARG_IMAGE" ]]; then
		err "No image type specified."
		exit 2
	fi

	if [[ -n "$ARG_IMAGE" ]]; then
		write_path="$ARG_IMAGE"
	else
		out="$(build_image "$ARG_TYPE")"
		write_path="$out"
	fi

	if [[ -d "$write_path" ]]; then
		img=$(echo "$write_path"/sd-image/*.img.zst "$write_path"/*.img.zst "$write_path"/*.img 2>/dev/null | head -n1)
		[[ -n "$img" ]] || {
			err "No image found in $write_path"
			exit 3
		}
		write_path="$img"
	fi

	[[ -f "$write_path" ]] || {
		err "Image not found: $write_path"
		exit 3
	}

	if [[ "$write_path" == *.zst ]]; then
		action "Decompressing..."
		local raw="${write_path%.zst}"
		if [[ ! -f "$raw" ]]; then
			zstd -d --long -T0 -f "$write_path" -o "$raw"
		fi
		write_path="$raw"
		ok "Decompressed to $write_path"
	fi

	img_bytes="$(stat -Lc %s "$write_path")"
	img_human="$(numfmt --to=iec --suffix=B --format='%.1f' "$img_bytes" 2>/dev/null || echo "$img_bytes bytes")"

	if [[ -z "$ARG_DEV" ]]; then
		echo
		list_candidates
		echo
		read -r -p "Device path to write to [e.g., /dev/sda]: " ARG_DEV
		[[ -n "$ARG_DEV" ]] || {
			err "No device entered."
			exit 4
		}
	fi

	validate_device "$ARG_DEV" || exit 5

	dev_bytes="$(lsblk -bdno SIZE "$ARG_DEV")"
	dev_human="$(numfmt --to=iec --suffix=B --format='%.1f' "$dev_bytes" 2>/dev/null || echo "$dev_bytes bytes")"
	model="$(lsblk -dno MODEL "$ARG_DEV" | xargs)"
	tran="$(lsblk -dno TRAN "$ARG_DEV" | xargs)"

	echo
	bold "=== Write summary ==="
	echo "Image:   $write_path ($img_human)"
	echo "Target:  $ARG_DEV  model=$model  transport=$tran  size=$dev_human"
	echo

	((img_bytes > dev_bytes)) && {
		err "Image ($img_human) larger than target ($dev_human)."
		exit 7
	}

	$ARG_DRY && {
		info "[DRY-RUN] dd if=$write_path of=$ARG_DEV bs=4M status=progress conv=fdatasync"
		exit 0
	}

	bold "THIS WILL DESTROY ALL DATA on $ARG_DEV."
	if ! $ARG_YES; then
		local n="$ARG_COUNT"
		info "Proceeding in ${n}s. Press Ctrl-C to abort."
		while ((n > 0)); do
			printf "${DIM}  %2d...${CLEAR}\r" "$n"
			sleep 1
			((n--)) || true
		done
		echo "               "
	fi

	if lsblk -nr "$ARG_DEV" -o MOUNTPOINT | grep -qE '\S'; then
		warn "Device has mounted partitions. Unmounting..."
		udisks_running && udisks_unmount "$ARG_DEV"
		for p in $(lsblk -nr "$ARG_DEV" -o PATH | tail -n +2); do
			umount "$p" 2>/dev/null || true
		done
	fi

	action "Writing..."
	dd if="$write_path" of="$ARG_DEV" bs=4M status=progress conv=fdatasync
	sync
	ok "Done. Remove device safely."
}

main "$@"
