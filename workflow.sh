#!/usr/bin/env bash
set -euo pipefail
ENV_FILE="$(dirname "$0")/.env"
[ -f "$ENV_FILE" ] && source "$ENV_FILE" || true
source "$(dirname "$0")/log.sh"
source "$(dirname "$0")/tasks.sh"
source "$(dirname "$0")/notify.sh"

retry() {
  local CMD=("$@")
  local MAX="${RETRY_MAX:-2}"
  local DELAY="${RETRY_DELAY_SEC:-3}"
  local n=0
  until "${CMD[@]}"; do
    n=$((n+1))
    if [ "$n" -gt "$MAX" ]; then
      log ERROR "Retry: command failed after $MAX attempts: ${CMD[*]}"
      return 1
    fi
    log WARN "Retry: attempt $n failed. Retrying in ${DELAY}s ..."
    sleep "$DELAY"
  done
}

sample_workflow() {
  log INFO "Workflow start: sample_workflow"
  retry run_task sample_echo "Step 1 says hi"

  if ! retry run_task sample_maybe_fail; then
    notify "Workflow sample_workflow FAILED" "Step 2 failed after retries"
    log ERROR "Workflow sample_workflow: FAILED"
    return 1
  fi

  notify "Workflow sample_workflow OK" "All steps completed successfully"
  log INFO "Workflow sample_workflow: SUCCESS"
}

run_workflow() {
  local NAME="${1:-}"; shift || true
  case "$NAME" in
    sample_workflow) sample_workflow "$@";;
    *) log ERROR "Unknown workflow: $NAME"; echo "Unknown workflow: $NAME" >&2; exit 2;;
  esac
}
