set -euo pipefail

systemctl --user reset-failed nosql-workbench-credentials-next.service nosql-workbench-credentials-next.timer 2>/dev/null || true
systemctl --user stop nosql-workbench-credentials-next.timer nosql-workbench-credentials-next.service 2>/dev/null || true

OUT="${AWS_SHARED_CREDENTIALS_FILE:-$HOME/.aws/credentials}"
mkdir -p "$(dirname "$OUT")"


# Get credentials from SSO profile. If not logged in, this will fail; do nothing.
if ! JSON="$(aws configure export-credentials 2>/dev/null)"; then
    echo "Not logged in; exiting"
    systemd-run --user \
        --unit=nosql-workbench-credentials-next \
        --on-active="60s" \
        /bin/sh -lc 'systemctl --user start nosql-workbench-credentials.service'
    exit 0
fi

access_key_id="$(printf '%s' "$JSON" | jq -r '.AccessKeyId // empty')"
secret_access_key="$(printf '%s' "$JSON" | jq -r '.SecretAccessKey // empty')"
session_token="$(printf '%s' "$JSON" | jq -r '.SessionToken // empty')"
expiration="$(printf '%s' "$JSON" | jq -r '.Expiration // empty')"

# If any are empty, treat as "not usable" and do nothing.
if [ -z "${access_key_id}" ] || [ -z "${secret_access_key}" ] || [ -z "${session_token}" ] || [ -z "${expiration}" ]; then
    echo "Invalid keys; exiting"
    exit 0
fi  



# echo $access_key_id
# echo $secret_access_key
# echo $session_token

cat <<EOF > "$OUT"
[workbench]
aws_access_key_id=${access_key_id}
aws_secret_access_key=${secret_access_key}
aws_session_token=${session_token}
region=ap-southeast-2
EOF

echo "File written"

exp_epoch=$(date -u -d "$expiration" +%s)
now_epoch=$(date -u +%s)


margin=300
delay=$(( exp_epoch - now_epoch - margin ))
[ "$delay" -lt 60 ] && delay=60

echo "Delay ${delay}"
systemd-run --user \
  --unit=nosql-workbench-credentials-next \
  --on-active="${delay}s" \
  /bin/sh -lc 'systemctl --user start nosql-workbench-credentials.service'
