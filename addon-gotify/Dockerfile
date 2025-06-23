ARG BUILD_FROM
FROM $BUILD_FROM

# Set gotify version
ARG GOTIFY_VERSION=2.6.3

# Install dependencies
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    curl \
    bash \
    net-tools \
    procps \
    file \
    unzip

# Determine architecture and download appropriate gotify binary
RUN echo "=== DEBUG: Architecture detection ===" && \
    ARCH="$(apk --print-arch)" && \
    echo "Detected architecture: ${ARCH}" && \
    uname -m && \
    file /bin/sh && \
    case "${ARCH}" in \
        x86_64) GOTIFY_ARCH="linux-amd64" ;; \
        aarch64) GOTIFY_ARCH="linux-arm64" ;; \
        armhf) GOTIFY_ARCH="linux-arm-6" ;; \
        armv7) GOTIFY_ARCH="linux-arm-7" ;; \
        i386) GOTIFY_ARCH="linux-386" ;; \
        *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
    esac && \
    echo "Gotify architecture: ${GOTIFY_ARCH}" && \
    DOWNLOAD_URL="https://github.com/gotify/server/releases/download/v${GOTIFY_VERSION}/gotify-${GOTIFY_ARCH}.zip" && \
    echo "Download URL: ${DOWNLOAD_URL}" && \
    # Download the ZIP file
    curl -L "$DOWNLOAD_URL" -o /tmp/gotify.zip && \
    echo "Download completed" && \
    ls -la /tmp/gotify.zip && \
    file /tmp/gotify.zip && \
    # Extract ZIP file
    cd /tmp && \
    unzip gotify.zip && \
    echo "ZIP extracted, contents:" && \
    ls -la /tmp/ && \
    # Find the gotify binary (it might be named differently in the ZIP)
    GOTIFY_BINARY=$(find /tmp -name "gotify*" -type f -executable | head -1) && \
    if [ -z "$GOTIFY_BINARY" ]; then \
        echo "No executable gotify binary found in ZIP"; \
        echo "ZIP contents:"; \
        find /tmp -name "*" -type f; \
        exit 1; \
    fi && \
    echo "Found binary: $GOTIFY_BINARY" && \
    mv "$GOTIFY_BINARY" /usr/local/bin/gotify && \
    chmod +x /usr/local/bin/gotify && \
    echo "Binary installed" && \
    ls -la /usr/local/bin/gotify && \
    file /usr/local/bin/gotify && \
    # Test the binary
    echo "Testing binary..." && \
    /usr/local/bin/gotify --version && \
    # Cleanup
    rm -rf /tmp/gotify* /tmp/*.zip

# Copy configuration files
COPY run.sh /

# Make run script executable
RUN chmod a+x /run.sh

# Create data directory
RUN mkdir -p /data

# Set working directory
WORKDIR /data

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start gotify
CMD ["/run.sh"]