#!/usr/bin/with-contenv bashio

# Enable strict error handling
set -e

# Get configuration options
LOG_LEVEL=$(bashio::config 'log_level')
ADMIN_USER=$(bashio::config 'admin_user')
ADMIN_PASS=$(bashio::config 'admin_pass')
DATABASE_PATH=$(bashio::config 'database_path')
UPLOAD_DIR=$(bashio::config 'upload_dir')
REGISTRATION=$(bashio::config 'registration')
PLUGINS_DIR=$(bashio::config 'plugins_dir' '/data/plugins')

# Create directories if they don't exist
mkdir -p "$(dirname "$DATABASE_PATH")"
mkdir -p "$UPLOAD_DIR"
mkdir -p "$PLUGINS_DIR"

# Set proper permissions
chown -R root:root /data
chmod -R 755 /data

# Generate configuration file
bashio::log.info "Generating Gotify configuration..."
cat > /data/config.yml << EOF
server:
  listenaddr: "0.0.0.0"
  port: 8080
  ssl:
    enabled: false
    redirecttohttps: false
  responseheaders:
    Access-Control-Allow-Origin: "*"
    Access-Control-Allow-Methods: "GET,POST,PUT,DELETE,OPTIONS"
    Access-Control-Allow-Headers: "Authorization,Content-Type,X-Gotify-Key"
    X-Frame-Options: "SAMEORIGIN"
    X-Content-Type-Options: "nosniff"
    X-XSS-Protection: "1; mode=block"
    Referrer-Policy: "strict-origin-when-cross-origin"
database:
  dialect: sqlite3
  connection: ${DATABASE_PATH}
defaultuser:
  name: ${ADMIN_USER}
  pass: ${ADMIN_PASS}
passstrength: 10
uploadedimagesdir: ${UPLOAD_DIR}
pluginsdir: ${PLUGINS_DIR}
registration: ${REGISTRATION}
EOF

# Log startup information
bashio::log.info "Starting Gotify server..."
bashio::log.info "Log level: ${LOG_LEVEL}"
bashio::log.info "Database path: ${DATABASE_PATH}"
bashio::log.info "Upload directory: ${UPLOAD_DIR}"
bashio::log.info "Plugins directory: ${PLUGINS_DIR}"
bashio::log.info "Registration enabled: ${REGISTRATION}"
bashio::log.info "Admin user: ${ADMIN_USER}"
bashio::log.info "Gotify will be available at http://localhost:8080"

# Wait a moment for the system to be ready
sleep 2

# Check if gotify binary exists and is executable
if [ ! -x "/usr/local/bin/gotify" ]; then
    bashio::log.error "Gotify binary not found or not executable!"
    exit 1
fi

# Start Gotify server with configuration file
bashio::log.info "Launching Gotify server..."
exec /usr/local/bin/gotify --config-file /data/config.yml