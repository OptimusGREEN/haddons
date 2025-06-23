#!/usr/bin/with-contenv bashio

# Enable debug output but handle errors more gracefully
set -x

# Debug function with error handling
debug_info() {
    bashio::log.info "=== DEBUG INFO ==="
    bashio::log.info "Current user: $(whoami || echo 'unknown')"
    bashio::log.info "Current directory: $(pwd || echo 'unknown')"
    bashio::log.info "Available memory: $(free -h 2>/dev/null | head -2 || echo 'memory info unavailable')"
    bashio::log.info "Disk space: $(df -h /data 2>/dev/null || echo 'disk info unavailable')"
    bashio::log.info "Process list: $(ps aux 2>/dev/null | head -10 || echo 'process list unavailable')"
    bashio::log.info "Network interfaces: $(ip addr show 2>/dev/null | grep inet || echo 'network info unavailable')"
    bashio::log.info "Listening ports: $(netstat -tlnp 2>/dev/null | head -10 || echo 'netstat not available')"
    bashio::log.info "=================="
}

# Run initial debug
debug_info

# Get configuration options with debugging
bashio::log.info "Reading configuration options..."
LOG_LEVEL=$(bashio::config 'log_level' 'info')
ADMIN_USER=$(bashio::config 'admin_user' 'admin')
ADMIN_PASS=$(bashio::config 'admin_pass' 'admin')
DATABASE_PATH=$(bashio::config 'database_path' '/data/gotify.db')
UPLOAD_DIR=$(bashio::config 'upload_dir' '/data/uploads')
REGISTRATION=$(bashio::config 'registration' 'false')
PLUGINS_DIR=$(bashio::config 'plugins_dir' '/data/plugins')

bashio::log.info "Configuration read successfully"
bashio::log.info "Log level: ${LOG_LEVEL}"
bashio::log.info "Admin user: ${ADMIN_USER}"
bashio::log.info "Database path: ${DATABASE_PATH}"
bashio::log.info "Upload directory: ${UPLOAD_DIR}"
bashio::log.info "Plugins directory: ${PLUGINS_DIR}"
bashio::log.info "Registration enabled: ${REGISTRATION}"

# Create directories if they don't exist
bashio::log.info "Creating required directories..."
mkdir -p "$(dirname "$DATABASE_PATH")" || {
    bashio::log.error "Failed to create database directory"
    exit 1
}
mkdir -p "$UPLOAD_DIR" || {
    bashio::log.error "Failed to create upload directory" 
    exit 1
}
mkdir -p "$PLUGINS_DIR" || {
    bashio::log.error "Failed to create plugins directory"
    exit 1
}

# Set proper permissions
bashio::log.info "Setting permissions..."
chown -R root:root /data 2>/dev/null || bashio::log.warning "Could not change ownership of /data"
chmod -R 755 /data 2>/dev/null || bashio::log.warning "Could not change permissions of /data"

# Verify directories were created
bashio::log.info "Directory structure:"
ls -la /data/ || bashio::log.warning "Could not list /data directory"

# Check if gotify binary exists and is executable FIRST
bashio::log.info "Checking Gotify binary..."
if [ ! -f "/usr/local/bin/gotify" ]; then
    bashio::log.error "Gotify binary not found at /usr/local/bin/gotify!"
    bashio::log.info "Contents of /usr/local/bin/:"
    ls -la /usr/local/bin/ || bashio::log.error "Cannot list /usr/local/bin/"
    exit 1
fi

if [ ! -x "/usr/local/bin/gotify" ]; then
    bashio::log.warning "Gotify binary not executable, fixing permissions..."
    chmod +x /usr/local/bin/gotify || {
        bashio::log.error "Failed to make gotify executable"
        exit 1
    }
fi

# Test the binary
bashio::log.info "Testing Gotify binary..."
bashio::log.info "Binary file info:"
file /usr/local/bin/gotify 2>/dev/null || bashio::log.warning "Cannot determine file type"
bashio::log.info "System architecture info:"
uname -a || bashio::log.warning "Cannot get system info"

bashio::log.info "Attempting version check..."
if /usr/local/bin/gotify --version 2>/dev/null; then
    bashio::log.info "Version check successful!"
else
    bashio::log.error "Version check failed - this usually indicates binary architecture mismatch"
    bashio::log.info "System architecture: $(uname -m)"
    bashio::log.info "Binary architecture: $(file /usr/local/bin/gotify 2>/dev/null || echo 'unknown')"
    exit 1
fi

# Generate configuration file
bashio::log.info "Generating Gotify configuration..."
cat > /data/config.yml << EOF || {
    bashio::log.error "Failed to create configuration file"
    exit 1
}
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

bashio::log.info "Configuration file created successfully"
bashio::log.info "Configuration file contents:"
cat /data/config.yml

# Final startup message
bashio::log.info "Starting Gotify server..."
bashio::log.info "Gotify will be available at http://localhost:8080"

# Start Gotify server directly (remove timeout wrapper that was causing issues)
bashio::log.info "Launching Gotify server..."
bashio::log.info "Command: /usr/local/bin/gotify --config-file /data/config.yml"

# Execute Gotify directly - this replaces the current shell process
exec /usr/local/bin/gotify --config-file /data/config.yml