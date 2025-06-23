#!/usr/bin/with-contenv bashio

# Enable strict error handling and debug output
set -e
set -x

# Debug function
debug_info() {
    bashio::log.info "=== DEBUG INFO ==="
    bashio::log.info "Current user: $(whoami)"
    bashio::log.info "Current directory: $(pwd)"
    bashio::log.info "Available memory: $(free -h | head -2)"
    bashio::log.info "Disk space: $(df -h /data)"
    bashio::log.info "Process list: $(ps aux | head -10)"
    bashio::log.info "Network interfaces: $(ip addr show | grep inet)"
    bashio::log.info "Listening ports: $(netstat -tlnp 2>/dev/null | head -10 || echo 'netstat not available')"
    bashio::log.info "=================="
}

# Run initial debug
debug_info

# Get configuration options with debugging
bashio::log.info "Reading configuration options..."
LOG_LEVEL=$(bashio::config 'log_level')
ADMIN_USER=$(bashio::config 'admin_user')
ADMIN_PASS=$(bashio::config 'admin_pass')
DATABASE_PATH=$(bashio::config 'database_path')
UPLOAD_DIR=$(bashio::config 'upload_dir')
REGISTRATION=$(bashio::config 'registration')
PLUGINS_DIR=$(bashio::config 'plugins_dir' '/data/plugins')

bashio::log.info "Configuration read successfully"

# Create directories if they don't exist
bashio::log.info "Creating required directories..."
mkdir -p "$(dirname "$DATABASE_PATH")"
mkdir -p "$UPLOAD_DIR"
mkdir -p "$PLUGINS_DIR"

# Set proper permissions
bashio::log.info "Setting permissions..."
chown -R root:root /data
chmod -R 755 /data

# Verify directories were created
bashio::log.info "Directory structure:"
ls -la /data/

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
bashio::log.info "Checking Gotify binary..."
if [ ! -f "/usr/local/bin/gotify" ]; then
    bashio::log.error "Gotify binary not found at /usr/local/bin/gotify!"
    bashio::log.info "Contents of /usr/local/bin/:"
    ls -la /usr/local/bin/
    exit 1
fi

if [ ! -x "/usr/local/bin/gotify" ]; then
    bashio::log.error "Gotify binary not executable!"
    bashio::log.info "Binary permissions:"
    ls -la /usr/local/bin/gotify
    chmod +x /usr/local/bin/gotify
    bashio::log.info "Fixed permissions, new permissions:"
    ls -la /usr/local/bin/gotify
fi

# Test the binary
bashio::log.info "Testing Gotify binary..."
/usr/local/bin/gotify --version || bashio::log.warning "Version check failed"

# Start Gotify server with configuration file
bashio::log.info "Launching Gotify server..."
bashio::log.info "Command: /usr/local/bin/gotify --config-file /data/config.yml"
bashio::log.info "Configuration file contents:"
cat /data/config.yml

# Try to start Gotify with timeout and error handling
bashio::log.info "Starting Gotify process..."
timeout 10s /usr/local/bin/gotify --config-file /data/config.yml &
GOTIFY_PID=$!

# Wait a few seconds and check if it's running
sleep 5
if kill -0 $GOTIFY_PID 2>/dev/null; then
    bashio::log.info "Gotify started successfully with PID: $GOTIFY_PID"
    # Check if port is listening
    if netstat -tlnp 2>/dev/null | grep :8080; then
        bashio::log.info "Port 8080 is listening!"
    else
        bashio::log.warning "Port 8080 is not listening"
    fi
    # Bring the process to foreground
    wait $GOTIFY_PID
else
    bashio::log.error "Gotify process died immediately"
    debug_info
    exit 1
fi