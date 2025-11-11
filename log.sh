#!/usr/bin/env bash
set -euo pipefail

log() {
local LEVEL="${1:-INFO}"; shift || true
local MSG="${*:-}"
local TS
TS="$(date '+%Y-%m-%d %H:%M:%S%z')"
local DEST="${LOG_FILE:-./logs/app.log}"
mkdir -p "$(dirname "$DEST")"
printf '%s [%s] %s\n' "$TS" "$LEVEL" "$MSG" | tee -a "$DEST" >/dev/null
}
