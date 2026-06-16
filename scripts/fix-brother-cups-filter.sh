#!/usr/bin/env bash
#
# fix-brother-cups-filter.sh
# -----------------------------------------------------------------------------
# Fixes the CUPS error: "Stopping job because the scheduler could not execute
# a filter." seen with Brother label printers (QL-810W, QL-820, PT series, etc.)
# on any Linux machine using CUPS.
#
# CAUSE: the Brother driver installer makes its files under /opt/brother
# world-writable (0777). CUPS refuses to run a print filter that is
# world-writable, so jobs fail. This script removes the unsafe permissions,
# restarts CUPS, and re-enables every Brother queue it finds.
#
# This script is GENERIC: it auto-detects all Brother printer queues and all
# Brother driver directories. It does not need the printer name hardcoded.
#
# USAGE:
#   sudo ./fix-brother-cups-filter.sh         # fix everything automatically
#   sudo ./fix-brother-cups-filter.sh -t      # fix, then send a test page
#   sudo ./fix-brother-cups-filter.sh -n      # dry run, change nothing
#   sudo ./fix-brother-cups-filter.sh -p NAME # also target a specific queue
#   sudo ./fix-brother-cups-filter.sh -h      # help
# -----------------------------------------------------------------------------

set -euo pipefail

# ---- Defaults / options -----------------------------------------------------
PRINTER_NAME=""
SEND_TEST=0
DRY_RUN=0
# Common locations Brother drivers install into. Existing ones are processed.
CANDIDATE_DIRS=(/opt/brother /usr/local/Brother /opt/Brother)

log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
err() { printf '[%s] ERROR: %s\n' "$(date '+%H:%M:%S')" "$*" >&2; }
run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '  (dry-run) %s\n' "$*"
  else
    eval "$@"
  fi
}

usage() {
  grep '^#' "$0" | sed 's/^# \{0,1\}//' | sed -n '2,30p'
  exit 0
}

while getopts ":p:tnh" opt; do
  case "$opt" in
    p) PRINTER_NAME="$OPTARG" ;;
    t) SEND_TEST=1 ;;
    n) DRY_RUN=1 ;;
    h) usage ;;
    \?) err "Unknown option: -$OPTARG"; exit 2 ;;
    :)  err "Option -$OPTARG requires an argument"; exit 2 ;;
  esac
done

# ---- Pre-flight -------------------------------------------------------------
if [[ "${EUID}" -ne 0 ]]; then
  err "Please run as root:  sudo $0"
  exit 1
fi

for cmd in find chmod chown systemctl; do
  command -v "$cmd" >/dev/null 2>&1 || { err "Missing required command: $cmd"; exit 2; }
done

[[ "$DRY_RUN" -eq 1 ]] && log "DRY RUN mode: no changes will be made."

# ---- Step 1: Find Brother driver directories that actually exist ------------
FOUND_DIRS=()
for d in "${CANDIDATE_DIRS[@]}"; do
  [[ -d "$d" ]] && FOUND_DIRS+=("$d")
done

if [[ "${#FOUND_DIRS[@]}" -eq 0 ]]; then
  err "No Brother driver directory found (looked in: ${CANDIDATE_DIRS[*]})."
  err "If the driver lives elsewhere, fix it manually with:"
  err "  chown -R root:root <dir> && chmod -R o-w,g-w <dir>"
  exit 3
fi

# ---- Step 2: Secure each driver directory -----------------------------------
for d in "${FOUND_DIRS[@]}"; do
  log "Securing driver directory: $d"
  BEFORE="$(find "$d" -type f -perm -o+w 2>/dev/null | wc -l)"
  log "  world-writable files before: $BEFORE"
  run "chown -R root:root '$d'"
  run "chmod -R o-w,g-w '$d'"
  if [[ "$DRY_RUN" -eq 0 ]]; then
    AFTER="$(find "$d" -type f -perm -o+w 2>/dev/null | wc -l)"
    if [[ "$AFTER" -eq 0 ]]; then
      log "  OK: no world-writable files remain."
    else
      err "  WARNING: $AFTER world-writable files still present in $d"
    fi
  fi
done

# ---- Step 3: Restart CUPS ---------------------------------------------------
log "Restarting CUPS ..."
run "systemctl restart cups"

# ---- Step 4: Detect and re-enable Brother queues ----------------------------
detect_brother_queues() {
  command -v lpstat >/dev/null 2>&1 || return 0
  lpstat -p 2>/dev/null | awk '/^printer /{print $2}' | while read -r q; do
    if lpstat -l -p "$q" 2>/dev/null | tr '[:upper:]' '[:lower:]' | grep -q brother; then
      echo "$q"
    fi
  done
}

if [[ -n "$PRINTER_NAME" ]]; then
  QUEUES="$PRINTER_NAME"
else
  log "Auto-detecting Brother print queues ..."
  QUEUES="$(detect_brother_queues || true)"
fi

if [[ -z "${QUEUES// /}" ]]; then
  log "No Brother queue detected to re-enable. (Permissions were still fixed.)"
else
  for q in $QUEUES; do
    log "Re-enabling queue: $q"
    run "cupsenable '$q' || true"
    run "cupsaccept '$q' || true"
  done
fi

# ---- Step 5: Optional test page ---------------------------------------------
if [[ "$SEND_TEST" -eq 1 && -n "${QUEUES// /}" && "$DRY_RUN" -eq 0 ]]; then
  for q in $QUEUES; do
    log "Sending test page to: $q"
    echo "CUPS filter repair test - $(date)" | lp -d "$q" || err "Test print to $q failed."
  done
fi

log "Done."
[[ "$DRY_RUN" -eq 0 ]] && cat <<'EOF'

If the printer still will not print, a job may be stuck on the device.
Power-cycle it: unplug the printer, wait ~5 seconds, plug it back in.

This error comes back whenever the Brother driver is reinstalled/updated
(that resets the permissions). If something reinstalls it automatically,
add this line at the end of that process:
    chown -R root:root /opt/brother && chmod -R o-w,g-w /opt/brother
EOF
