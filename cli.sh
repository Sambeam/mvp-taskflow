#!/usr/bin/env bash
set -euo pipefail
[ -f ./.env ] && source ./.env || true
source "$(dirname "$0")/tasks.sh"
source "$(dirname "$0")/workflow.sh"
source "$(dirname "$0")/log.sh"

usage() {
  cat <<USAGE
Usage:
  $0 run-task <task_name> [args...]         Run a registered task now
  $0 run-workflow <workflow_name> [args...] Run a workflow now
  $0 cron-add "<cron_expr>" "<command>"     Add a cron entry for current user
  $0 cron-list                               Show current user's crontab
  $0 cron-clear                              Clear current user's crontab (CAREFUL)

Examples:
  $0 run-task sample_echo "Hello"
  $0 run-workflow sample_workflow
  $0 cron-add "*/5 * * * *" "/bin/bash $(pwd)/cli.sh run-task sample_echo"
USAGE
}

cron_add() {
  local EXPR="${1:-}"
  local CMD="${2:-}"
  if [ -z "$EXPR" ] || [ -z "$CMD" ]; then
    echo "cron-add requires a CRON_EXPR and a COMMAND" >&2
    exit 2
  fi
  (crontab -l 2>/dev/null; echo "${EXPR} ${CMD} >> $(pwd)/logs/cron.log 2>&1") | crontab -
  log INFO "Added cron: ${EXPR} ${CMD}"
}

cron_list()  { crontab -l || true; }
cron_clear() { crontab -r || true; }

cmd="${1:-}"; shift || true
case "$cmd" in
  run-task)     run_task "$@";;
  run-workflow) run_workflow "$@";;
  cron-add)     cron_add "$@";;
  cron-list)    cron_list;;
  cron-clear)   cron_clear;;
  *)            usage; exit 1;;
esac
