#!/usr/bin/env bash

set -euo pipefail

# Turn a Debian/Ubuntu/Raspberry Pi OS device into a Resonate listening room by
# installing Snapclient and pointing it at the Resonate host. The new room
# appears automatically in the Rooms panel of the UI.
#
# Usage:
#   bash install-room.sh <resonate-host-ip> [room-name]
#
# Examples:
#   bash install-room.sh 192.168.1.20            # room name defaults to hostname
#   bash install-room.sh 192.168.1.20 Kitchen

log() {
  printf '[resonate-room] %s\n' "$*"
}

HOST="${1:-}"
NAME="${2:-$(hostname)}"
STREAM_PORT="${SNAPCAST_STREAM_PORT:-1704}"

if [[ -z "${HOST}" ]]; then
  log 'Usage: install-room.sh <resonate-host-ip> [room-name]'
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  log 'This helper supports Debian/Ubuntu/Raspberry Pi OS (apt).'
  log 'On other systems, install snapclient yourself and run:'
  log "  snapclient --host ${HOST} --port ${STREAM_PORT} --hostID ${NAME}"
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  log 'sudo is required.'
  exit 1
fi

log 'Installing snapclient...'
sudo apt-get update
sudo apt-get install -y snapclient

# The Debian snapclient service reads its arguments from /etc/default/snapclient.
log "Pointing this room at ${HOST}:${STREAM_PORT} as '${NAME}'..."
sudo tee /etc/default/snapclient >/dev/null <<EOF
# Managed by Resonate install-room.sh
START_SNAPCLIENT=true
SNAPCLIENT_OPTS="--host ${HOST} --port ${STREAM_PORT} --hostID ${NAME}"
EOF

log 'Enabling and starting the snapclient service...'
sudo systemctl enable --now snapclient
sudo systemctl restart snapclient

log "Done. '${NAME}' should now appear in the Rooms panel of the Resonate UI."
log 'If it does not, check: systemctl status snapclient'
