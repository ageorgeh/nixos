#!/usr/bin/env bash
# Setup SSH key and access for a media server at 192.168.20.75

set -euo pipefail

MEDIA_HOST="192.168.20.75"
DEFAULT_ALIAS="media-server"
DEFAULT_PORT="22"
SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/media_server_id"
SSH_CONFIG="$SSH_DIR/config"

read -rp "Remote username on ${MEDIA_HOST}: " MEDIA_USER
MEDIA_USER="${MEDIA_USER:?username required}"
read -rp "SSH port [${DEFAULT_PORT}]: " PORT
PORT="${PORT:-$DEFAULT_PORT}"
read -rp "Host alias for ~/.ssh/config [${DEFAULT_ALIAS}]: " HOST_ALIAS
HOST_ALIAS="${HOST_ALIAS:-$DEFAULT_ALIAS}"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [[ -f "$SSH_KEY" ]]; then
  echo "Key exists: $SSH_KEY"
else
  echo "Generating ed25519 key..."
  ssh-keygen -t ed25519 -C "${USER}@${HOST_ALIAS}" -f "$SSH_KEY" -N ""
  chmod 600 "$SSH_KEY"
  chmod 644 "${SSH_KEY}.pub"
fi

# Ensure ssh-agent and add key if not already loaded
if ! ssh-add -l >/dev/null 2>&1; then
  eval "$(ssh-agent -s)"
fi
if ! ssh-add -l | grep -q "$(ssh-keygen -lf "$SSH_KEY" | awk '{print $2}')" 2>/dev/null; then
  ssh-add "$SSH_KEY"
fi

# Known_hosts priming (accept first key automatically)
echo "Probing host key for ${MEDIA_HOST}:${PORT}..."
ssh -o StrictHostKeyChecking=accept-new -p "$PORT" "${MEDIA_USER}@${MEDIA_HOST}" true || true

# Install public key on the remote
if command -v ssh-copy-id >/dev/null 2>&1; then
  echo "Copying key with ssh-copy-id..."
  ssh-copy-id -i "${SSH_KEY}.pub" -p "$PORT" "${MEDIA_USER}@${MEDIA_HOST}"
else
  echo "ssh-copy-id not found. Using manual append over SSH..."
  cat "${SSH_KEY}.pub" | ssh -p "$PORT" "${MEDIA_USER}@${MEDIA_HOST}" 'umask 077; mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys'
fi

# Write ~/.ssh/config host block if missing
if ! grep -qE "^[Hh]ost[[:space:]]+${HOST_ALIAS}([[:space:]]|\$)" "$SSH_CONFIG" 2>/dev/null; then
  {
    echo ""
    echo "Host ${HOST_ALIAS}"
    echo "  HostName ${MEDIA_HOST}"
    echo "  User ${MEDIA_USER}"
    echo "  Port ${PORT}"
    echo "  IdentityFile ${SSH_KEY}"
    echo "  IdentitiesOnly yes"
    echo "  PubkeyAuthentication yes"
    echo "  ForwardAgent no"
  } >> "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"
  echo "Wrote host entry '${HOST_ALIAS}' to $SSH_CONFIG"
else
  echo "Host entry '${HOST_ALIAS}' already present in $SSH_CONFIG"
fi

# Test login
echo "Testing key-based SSH..."
if ssh -o BatchMode=yes "${HOST_ALIAS}" 'echo ok' 2>/dev/null | grep -q '^ok$'; then
  echo "Success. Connect with: ssh ${HOST_ALIAS}"
else
  echo "Key auth failed. Check ~/.ssh/authorized_keys on remote and permissions."
fi

