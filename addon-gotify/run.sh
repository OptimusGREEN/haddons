#!/usr/bin/env bash
set -e

CONFIG_PATH="/data/config.yml"

echo "[INFO] Generating Gotify config at $CONFIG_PATH..."

cat > "$CONFIG_PATH" <<EOF
server:
  listenaddr: "0.0.0.0"
  port: ${PORT}
  ssl:
    enabled: false

database:
  dialect: "sqlite3"
  connection: "data/gotify.db"

pass_strength: 60

default_user:
  name: ${USERNAME}
  pass: ${PASSWORD}

registration: ${ALLOW_REGISTRATION}
EOF

echo "[INFO] Starting Gotify..."
exec gotify --config "$CONFIG_PATH"