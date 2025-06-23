#!/usr/bin/with-contenv bashio

# Get configuration options
LOG_LEVEL=$(bashio::config 'log_level')
ADMIN_USER=$(bashio::config 'admin_user')
ADMIN_PASS=$(bashio::config 'admin_pass')
DATABASE_PATH=$(bashio::config 'database_path')
UPLOAD_DIR=$(bashio::config 'upload_dir')
REGISTRATION=$(bashio::config 'registration')

# Create directories if they don't exist
mkdir -p "$(dirname "$DATABASE_PATH")"
mkdir -p "$UPLOAD_DIR"

# Set permissions
chown -R root:root /data
chmod -R 755 /data

# Generate configuration file
cat > /tmp/config.yml << EOF
server:
  listenaddr: "0.0.0.0"
  port: 8080
  ssl:
    enabled: false
  responseheaders:
    Access-Control-Allow-Origin: "*"
    Access-Control-Allow-Methods: "GET,POST,DELETE"
    Access-Control-Allow-Headers: "Authorization,content-type"
database:
  dialect: sqlite3
  connection: ${DATABASE_PATH}
defaultuser:
  name: ${ADMIN_USER}
  pass: ${ADMIN_PASS}
passstrength: 10
uploadedimagesdir: ${UPLOAD_DIR}
pluginsdir: /data/plugins
registration: ${REGISTRATION}
EOF

# Log startup information
bashio::log.info "Starting Gotify server..."
bashio::log.info "Log level: ${LOG_LEVEL}"
bashio::log.info "Database path: ${DATABASE_PATH}"
bashio::log.info "Upload directory: ${UPLOAD_DIR}"
bashio::log.info "Registration enabled: ${REGISTRATION}"
bashio::log.info "Admin user: ${ADMIN_USER}"

# Set environment variables
export GOTIFY_SERVER_LISTENADDR="0.0.0.0"
export GOTIFY_SERVER_PORT="8080"
export GOTIFY_DATABASE_DIALECT="sqlite3"
export GOTIFY_DATABASE_CONNECTION="${DATABASE_PATH}"
export GOTIFY_DEFAULTUSER_NAME="${ADMIN_USER}"
export GOTIFY_DEFAULTUSER_PASS="${ADMIN_PASS}"
export GOTIFY_PASSSTRENGTH="10"
export GOTIFY_UPLOADEDIMAGESDIR="${UPLOAD_DIR}"
export GOTIFY_REGISTRATION="${REGISTRATION}"

# Start Gotify server
exec gotify