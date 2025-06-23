#!/usr/bin/with-contenv bashio

# Set up logging
bashio::log.info "Starting Gotify Home Assistant Add-on..."

# Get configuration options
LOG_LEVEL=$(bashio::config 'log_level' 'info')
ADMIN_USER=$(bashio::config 'admin_user' 'admin')
ADMIN_PASS=$(bashio::config 'admin_pass' 'admin')
DATABASE_PATH=$(bashio::config 'database_path' '/data/gotify.db')
UPLOAD_DIR=$(bashio::config 'upload_dir' '/data/uploads')
REGISTRATION=$(bashio::config 'registration' 'false')
PLUGINS_DIR=$(bashio::config 'plugins_dir' '/data/plugins')

bashio::log.info "Configuration loaded:"
bashio::log.info "- Log level: ${LOG_LEVEL}"
bashio::log.info "- Admin user: ${ADMIN_USER}"
bashio::log.info "- Database path: ${DATABASE_PATH}"
bashio::log.info "- Upload directory: ${UPLOAD_DIR}"
bashio::log.info "- Plugins directory: ${PLUGINS_DIR}"
bashio::log.info "- Registration enabled: ${REGISTRATION}"

# Create directories
bashio::log.info "Creating required directories..."
mkdir -p "$(dirname "$DATABASE_PATH")" || bashio::log.error "Failed to create database directory"
mkdir -p "$UPLOAD_DIR" || bashio::log.error "Failed to create upload directory"
mkdir -p "$PLUGINS_DIR" || bashio::log.error "Failed to create plugins directory"

# Generate Gotify configuration file
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

bashio::log.info "Starting Gotify server..."
bashio::log.info "Gotify will be available at http://localhost:8080"

# Set environment variables for Gotify
export GOTIFY_SERVER_LISTENADDR="0.0.0.0"
export GOTIFY_SERVER_PORT="8080"
export GOTIFY_DATABASE_DIALECT="sqlite3"
export GOTIFY_DATABASE_CONNECTION="${DATABASE_PATH}"
export GOTIFY_DEFAULTUSER_NAME="${ADMIN_USER}"
export GOTIFY_DEFAULTUSER_PASS="${ADMIN_PASS}"
export GOTIFY_PASSSTRENGTH="10"
export GOTIFY_UPLOADEDIMAGESDIR="${UPLOAD_DIR}"
export GOTIFY_PLUGINSDIR="${PLUGINS_DIR}"
export GOTIFY_REGISTRATION="${REGISTRATION}"

# Start Gotify using the official entrypoint
exec /usr/bin/gotify-app