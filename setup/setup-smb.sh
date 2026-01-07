#!/usr/bin/env bash
set -euo pipefail

cred_dir="/etc/nixos/secret"
cred_file="$cred_dir/smb-credentials"

sudo mkdir -p "$cred_dir"
sudo chmod 700 "$cred_dir"

read -rp "SMB username: " smb_user
read -rsp "SMB password: " smb_pass
echo

tmp="$(mktemp)"
cat > "$tmp" <<EOF
username=$smb_user
password=$smb_pass
EOF

sudo install -m 600 -o root -g root "$tmp" "$cred_file"
rm -f "$tmp"

echo "Wrote $cred_file (root:root 0600)"
