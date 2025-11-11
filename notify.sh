#!/usr/bin/env bash
set -euo pipefail
ENV_FILE="$(dirname "$0")/.env"
[ -f "$ENV_FILE" ] && source "$ENV_FILE" || true
source "$(dirname "$0")/log.sh"

notify() {
  local SUBJECT="${1:-Task Notification}"
  local BODY="${2:-No message}"
  local TO="${NOTIFY_EMAIL:-}"

  if command -v mail >/dev/null 2>&1 && [ -n "${TO}" ]; then
    printf '%s\n' "$BODY" | mail -s "$SUBJECT" "$TO" || log WARN "mail send failed"
    log INFO "Notification sent via mail to $TO: $SUBJECT"
  elif command -v sendmail >/dev/null 2>&1 && [ -n "${TO}" ]; then
    {
      echo "Subject: $SUBJECT"
      echo "To: $TO"
      echo
      echo "$BODY"
    } | sendmail -t || log WARN "sendmail failed"
    log INFO "Notification sent via sendmail to $TO: $SUBJECT"
  else
    log INFO "Notify (console): $SUBJECT - $BODY"
    echo "=== Notification ==="
    echo "$SUBJECT"
    echo "$BODY"
  fi
}
