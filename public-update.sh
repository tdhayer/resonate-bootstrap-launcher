#!/usr/bin/env bash

set -euo pipefail

# This launcher is intended to be hosted in a small PUBLIC repository.
# It fetches the private Proxmox update script through the GitHub API
# using an authenticated token, then executes it locally.

log() {
  printf '[resonate-update] %s\n' "$*"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "Missing required command: $1"
    exit 1
  fi
}

prompt_token_if_missing() {
  if [[ -n "${GH_TOKEN:-}" ]]; then
    return
  fi

  if [[ -t 0 ]]; then
    printf 'Enter GitHub token with private repo read access: ' >&2
    read -r -s GH_TOKEN
    printf '\n' >&2
    export GH_TOKEN
  else
    log 'GH_TOKEN is required for non-interactive mode.'
    exit 1
  fi
}

cleanup() {
  if [[ -n "${TMP_SCRIPT:-}" && -f "${TMP_SCRIPT}" ]]; then
    rm -f "${TMP_SCRIPT}"
  fi
}

trap cleanup EXIT

require_command bash
require_command curl
require_command mktemp

RESONATE_OWNER="${RESONATE_OWNER:-tdhayer}"
RESONATE_REPO="${RESONATE_REPO:-resonate}"
RESONATE_REF="${RESONATE_REF:-main}"
RESONATE_PRIVATE_SCRIPT_PATH="${RESONATE_PRIVATE_SCRIPT_PATH:-scripts/proxmox-update.sh}"

prompt_token_if_missing

PRIVATE_SCRIPT_URL="https://api.github.com/repos/${RESONATE_OWNER}/${RESONATE_REPO}/contents/${RESONATE_PRIVATE_SCRIPT_PATH}?ref=${RESONATE_REF}"

TMP_SCRIPT="$(mktemp -t resonate-private-update.XXXXXX.sh)"

log 'Fetching private update script from GitHub API...'
curl -fsSL \
  -H "Authorization: Bearer ${GH_TOKEN}" \
  -H 'Accept: application/vnd.github.raw' \
  "${PRIVATE_SCRIPT_URL}" \
  -o "${TMP_SCRIPT}"

chmod +x "${TMP_SCRIPT}"

export RESONATE_GITHUB_TOKEN="${GH_TOKEN}"
export RESONATE_REPO_URL="${RESONATE_REPO_URL:-https://github.com/${RESONATE_OWNER}/${RESONATE_REPO}.git}"

log 'Launching private Proxmox update script...'
bash "${TMP_SCRIPT}" "$@"

unset GH_TOKEN
unset RESONATE_GITHUB_TOKEN