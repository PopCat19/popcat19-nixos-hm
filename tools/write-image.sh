#!/usr/bin/env bash

# write-image.sh
#
# Purpose: Safely write a flake-built installer or Pi SD image to a target device
#
# This module:
# - Builds images from the flake (installer-zst, sd-popcat19-klipper0) or uses a pre-built path
# - Auto-detects removable USB/SD candidate devices (excludes system disks)
# - Handles zstd decompression
# - Interactive device selection with countdown confirmation
# - Unmounts UDisks-managed mounts before writing
# - Does not support ISO (use Ventoy for those)

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---------- Colors ----------
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
CLEAR='\033[0m'

# ---------- Logging ----------
info()  { echo -e "${CYAN}$*${CLEAR}"; }
ok()    { echo -e "${GREEN}$*${CLEAR}"; }
warn()  { echo -e "${YELLOW}WARN:${CLEAR} $*" >&2; }
err()   { echo -e "${RED}ERROR:${CLEAR} $*" >&2; }
bold()  { echo -e "${BOLD}$*${CLEAR}"; }
action(){ echo -e "${MAGENTA}$*${CLEAR}"; }
dim()   { echo -e "${DIM}$*${CLEAR}"; }

# ---------- Defaults ----------
IMAGE_TYPE="${IMAGE_TYPE:-installer}"     # installer | klipper
IMAGE_PATH="${IMAGE_PATH:-}"              # pre-built .img or .img.zst
OUTPUT_DEVICE="${OUTPUT_DEVICE:-}"
SKIP_CONFIRM="${SKIP_CONFIRM:-false}"
COUNTDOWN="${COUNTDOWN:-10}"
DRY_RUN="${DRY_RUN:-false}"
AUTO_UNMOUNT="${AUTO_UNMOUNT:-true}"
BUILD_FROM_FLAKE="${BUILD_FROM_FLAKE:-false}"
SYSTEM_PKNAMES=""

# ---------- Help ----------
usage() {
  cat <<'EOF'
Usage: write-image.sh [--type installer|klipper] [--device /dev/sdX] [--image path.img.zst]

Options:
  --type TYPE          Image type: installer (x86_64) or klipper (Pi 4 SD). Default: installer
  --device DEV         Target block device path (e.g., /dev/sda). Prompts interactively if omitted.
  --image PATH         Pre-built image file (.img or .img.zst). Skips flake build if given.
  --build              Build the image from the flake before writing.
  --yes                Skip countdown confirmation (DANGEROUS).
  --countdown N        Confirmation countdown in seconds. Default: 10.
  --dry-run            Show what would happen without writing.
  -h, --help           Show this help.

Examples:
  sudo ./tools/write-image.sh --type installer --build --device /dev/sdd
  sudo ./tools/write-image.sh --type klipper --device /dev/mmcblk0
  sudo ./tools/write-image.sh --image /tmp/installer.img.zst --device /dev/sdc
EOF
}

# ---------- System disk detection ----------
pk_of() {
  local src="$1"
  src="$(readlink -f "$src" 2>/dev/null || echo "$src")"
  local pk
  pk="$(lsblk -no PKNAME "$src" 2>/dev/null | head -n1 || true)"
  if [[ -n "$pk" ]]; then echo "$pk" && return 0; fi
  pk="$(lsblk -no NAME "$src" 2>/dev/null | head -n1 || true)"
  [[ -n "$pk" ]] && echo "$pk"
}

collect_system_pknames() {
  SYSTEM_PKNAMES=""
  local src pk

  for mp in / /home /boot /boot/efi; do
    src="$(findmnt -no SOURCE "$mp" 2>/dev/null || true)"
    [[ -z "$src" ]] && continue
    pk="$(pk_of "$src")"
    [[ -z "$pk" ]] && continue
    if [[ " ${SYSTEM_PKNAMES} " != *" ${pk} "* ]]; then
      SYSTEM_PKNAMES="${SYSTEM_PKNAMES} ${pk}"
    fi
  done

  if [[ -r /proc/swaps ]]; then
    while read -r filename type _; do
      [[ "$filename" == Filename* ]] && continue
      [[ "$type" == "partition" || "$filename" == /dev/* ]] || continue
      pk="$(pk_of "$filename")"
      [[ -z "$pk" ]] && continue
      if [[ " ${SYSTEM_PKNAMES} " != *" ${pk} "* ]]; then
        SYSTEM_PKNAMES="${SYSTEM_PKNAMES} ${pk}"
      fi
    done < <(awk '{print $1" "$2}' /proc/swaps)
  fi

  SYSTEM_PKNAMES="${SYSTEM_PKNAMES#" "}"
}

is_system_pk() {
  [[ -n "${1:-}" && " ${SYSTEM_PKNAMES} " == *" ${1} "* ]]
}

# ---------- Candidate listing ----------
list_candidates() {
  bold "SAFE devices (removable, unmounted, non-system):"
  printf "%-16s %-10s %-8s %-4s %s\n" "DEVICE" "SIZE" "TRAN" "RM" "MODEL"
  echo "--------------------------------------------------------------------------------"
  while IFS= read -r line; do
    local name path size model tran rm
    name="$(  awk -F'|' '{print $1}' <<<"$line")"
    path="$(  awk -F'|' '{print $2}' <<<"$line")"
    size="$(  awk -F'|' '{print $3}' <<<"$line")"
    model="$( awk -F'|' '{print $4}' <<<"$line")"
    tran="$(  awk -F'|' '{print $5}' <<<"$line")"
    rm="$(    awk -F'|' '{print $6}' <<<"$line")"

    [[ "$(awk -F'|' '{print $7}' <<<"$line")" == "disk" ]] || continue
    [[ "$name" =~ ^loop|^zram|^ram|^md|^dm- ]] && continue
    is_system_pk "$name" && continue

    if lsblk -nr "$path" -o MOUNTPOINT | grep -qE '\S'; then continue; fi

    printf "%-16s %-10s %-8s %-4s %s\n" "$path" "$size" "$tran" "$rm" "$model"
  done < <(lsblk -dn -o NAME,PATH,SIZE,MODEL,TRAN,RM,TYPE | awk '{n=$1; p=$2; s=$3; m=""; t=""; rm=""; for(i=4;i<=NF-3;i++) m=m $i " "; t=$(NF-2); rm=$(NF-1); type=$(NF); gsub(/ *$/,"",m); print n "|" p "|" s "|" m "|" t "|" rm "|" type }')
}

# ---------- UDisks helpers ----------
udisks_running() {
  pgrep -x udisksd >/dev/null 2>&1 || systemctl is-active --quiet udisks2.service 2>/dev/null || return 1
}

udisks_unmount() {
  local dev="$1"
  local parts
  mapfile -t parts < <(lsblk -nr "$dev" -o PATH | tail -n +2 || true)
  [[ ${#parts[@]} -eq 0 ]] && return 0

  local re=""
  for p in "${parts[@]}"; do re="${re}|^${p//\//\\/}\$"; done
  re="${re#|}"

  while IFS='|' read -r src tgt _; do
    [[ "$src" =~ $re ]] || continue
    action "Unmounting $tgt ($src)"
    if command -v udisksctl &>/dev/null; then
      udisksctl unmount -b "$src" >/dev/null 2>&1 || true
    fi
    umount "$tgt" >/dev/null 2>&1 || true
  done < <(findmnt -rn -o SOURCE,TARGET | sed 's/  */|/')
}

# ---------- Validate ----------
validate_device() {
  local dev="$1"
  [[ -b "$dev" ]] || { err "$dev is not a block device."; return 1; }

  local type
  type="$(lsblk -dno TYPE "$dev" 2>/dev/null)"
  [[ "$type" == "disk" ]] || { err "$dev is TYPE=$type, not a whole disk."; return 1; }

  local pk
  pk="$(pk_of "$dev")"
  if is_system_pk "$pk"; then
    err "Refusing to write to a system disk ($pk)."
    return 1
  fi
}

# ---------- Build from flake ----------
build_image() {
  local type="$1"
  local attr
  case "$type" in
    installer) attr="installer-zst";;
    klipper)   attr="sd-popcat19-klipper0";;
    *) err "Unknown image type: $type"; return 1;;
  esac

  action "Building .#$attr ..."
  nix build "$REPO_DIR#$attr" --accept-flake-config --no-link --print-out-paths
}

# ---------- Main ----------
main() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    exec sudo "$0" "$@"
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --type)     IMAGE_TYPE="${2:-}"; shift 2;;
      --device)   OUTPUT_DEVICE="${2:-}"; shift 2;;
      --image)    IMAGE_PATH="${2:-}"; shift 2;;
      --build)    BUILD_FROM_FLAKE="true"; shift;;
      --yes)      SKIP_CONFIRM="true"; shift;;
      --countdown) COUNTDOWN="${2:-}"; shift 2;;
      --dry-run)  DRY_RUN="true"; shift;;
      -h|--help)  usage; exit 0;;
      *)          err "Unknown argument: $1"; usage; exit 2;;
    esac
  done

  collect_system_pknames

  # Resolve image path
  if [[ -z "$IMAGE_PATH" ]]; then
    if [[ "$BUILD_FROM_FLAKE" == "true" ]]; then
      local out
      out="$(build_image "$IMAGE_TYPE")"
      IMAGE_PATH="$out"
    else
      err "No --image given. Use --build to build from flake, or pass --image PATH."
      usage
      exit 2
    fi
  fi

  if [[ ! -f "$IMAGE_PATH" ]]; then
    err "Image not found: $IMAGE_PATH"
    exit 3
  fi

  # Handle zstd
  local write_path="$IMAGE_PATH"
  if [[ "$IMAGE_PATH" == *.zst ]]; then
    action "Decompressing..."
    write_path="${IMAGE_PATH%.zst}"
    if [[ ! -f "$write_path" ]]; then
      zstd -d --long -T0 -f "$IMAGE_PATH" -o "$write_path"
      ok "Decompressed to $write_path"
    fi
  fi

  local img_bytes
  img_bytes="$(stat -Lc %s "$write_path")"

  # Prompt for device
  if [[ -z "$OUTPUT_DEVICE" ]]; then
    echo
    list_candidates
    echo
    read -r -p "Device path to write to [e.g., /dev/sda]: " OUTPUT_DEVICE
    [[ -z "$OUTPUT_DEVICE" ]] && { err "No device entered."; exit 4; }
  fi

  # Validate
  validate_device "$OUTPUT_DEVICE" || exit 5

  local dev_bytes dev_human img_human model tran
  dev_bytes="$(lsblk -bdno SIZE "$OUTPUT_DEVICE")"
  dev_human="$(numfmt --to=iec --suffix=B --format='%.1f' "$dev_bytes" 2>/dev/null || echo "$dev_bytes bytes")"
  img_human="$(numfmt --to=iec --suffix=B --format='%.1f' "$img_bytes" 2>/dev/null || echo "$img_bytes bytes")"
  model="$(lsblk -dno MODEL "$OUTPUT_DEVICE" | xargs)"
  tran="$(lsblk -dno TRAN "$OUTPUT_DEVICE" | xargs)"

  echo
  bold "=== Write summary ==="
  echo "Image:   $write_path ($img_human)"
  echo "Target:  $OUTPUT_DEVICE  model=$model  transport=$tran  size=$dev_human"
  echo

  [[ "$img_bytes" -gt "$dev_bytes" ]] && {
    err "Image ($img_human) larger than target ($dev_human). Aborting."
    exit 7
  }

  [[ "$DRY_RUN" == "true" ]] && {
    info "[DRY-RUN] Would run: dd if=$write_path of=$OUTPUT_DEVICE bs=4M status=progress conv=fdatasync"
    exit 0
  }

  # Confirmation
  bold "THIS WILL DESTROY ALL DATA on $OUTPUT_DEVICE."
  if [[ "$SKIP_CONFIRM" != "true" ]]; then
    local n="$COUNTDOWN"
    info "Proceeding in ${n}s. Press Ctrl-C to abort."
    while [[ "$n" -gt 0 ]]; do
      printf "${DIM}  %2d...${CLEAR}\r" "$n"
      sleep 1
      ((n--)) || true
    done
    echo "               "
  fi

  # Unmount if needed
  if lsblk -nr "$OUTPUT_DEVICE" -o MOUNTPOINT | grep -qE '\S'; then
    if [[ "$AUTO_UNMOUNT" == "true" ]]; then
      warn "Device has mounted partitions. Unmounting..."
      if udisks_running; then udisks_unmount "$OUTPUT_DEVICE"; fi
      for p in $(lsblk -nr "$OUTPUT_DEVICE" -o PATH | tail -n +2); do
        umount "$p" 2>/dev/null || true
      done
    else
      err "Device has mounted partitions. Unmount them first."
      exit 8
    fi
  fi

  # Write
  action "Writing image..."
  dd if="$write_path" of="$OUTPUT_DEVICE" bs=4M status=progress conv=fdatasync

  sync
  ok "Done. Remove device safely."
}

main "$@"
