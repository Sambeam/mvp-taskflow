#!/usr/bin/env bash
set -euo pipefail
ENV_FILE="$(dirname "$0")/.env"
[ -f "$ENV_FILE" ] && source "$ENV_FILE" || true
source "$(dirname "$0")/log.sh"

# ---- Sample tasks ----

sample_echo() {
  local MSG="${1:-Hello from sample_echo}"
  log INFO "sample_echo: $MSG"
  echo "$MSG"
  notify "Task sample_echo OK" "$MSG"
}

sample_maybe_fail() {
  # Fails ~50% of the time to demonstrate retries
  if [ $(( RANDOM % 2 )) -eq 0 ]; then
    log ERROR "sample_maybe_fail: Simulated failure"
    return 1
  fi
  log INFO "sample_maybe_fail: Succeeded"
  return 0
}

# A real task example: ping a URL (requires curl)
ping_url() {
  local URL="${1:-https://example.org}"
  log INFO "ping_url: GET $URL"
  curl -fsS "$URL" >/dev/null
  log INFO "ping_url: OK"
}

# Dispatcher (internal)
run_task() {
  local NAME="${1:-}"; shift || true
  case "$NAME" in
    sample_echo)        sample_echo "$@";;
    sample_maybe_fail)  sample_maybe_fail "$@";;
    ping_url)           ping_url "$@";;
    *) log ERROR "Unknown task: $NAME"; echo "Unknown task: $NAME" >&2; exit 2;;
  esac
}
