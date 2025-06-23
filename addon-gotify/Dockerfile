ARG BUILD_FROM
FROM $BUILD_FROM

# Set gotify version
ARG GOTIFY_VERSION=2.4.0

# Install dependencies
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    curl \
    bash \
    net-tools \
    procps

# Determine architecture and download appropriate gotify binary
RUN echo "=== DEBUG: Architecture detection ===" && \
    ARCH="$(apk --print-arch)" && \
    echo "Detected architecture: ${ARCH}" && \
    uname -m && \
    file /bin/sh && \
    case "${ARCH}" in \
        x86_64) GOTIFY_ARCH="amd64" ;; \
        aarch64) GOTIFY_ARCH="arm64" ;; \
        armhf) GOTIFY_ARCH="arm-6" ;; \
        armv7) GOTIFY_ARCH="arm-7" ;; \
        i386) GOTIFY_ARCH="386" ;; \
        *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
    esac && \
    echo "Gotify architecture: ${GOTIFY_ARCH}" && \
    DOWNLOAD_URL="https://github.com/gotify/server/releases/download/v${GOTIFY_VERSION}/gotify-linux-${GOTIFY_ARCH}" && \
    echo "Download URL: ${DOWNLOAD_URL}" && \
    curl -L "$DOWNLOAD_URL" -o /usr/local/bin/gotify && \
    echo "Download completed" && \
    ls -la /usr/local/bin/gotify && \
    file /usr/local/bin/gotify && \
    chmod +x /usr/local/bin/gotify && \
    echo "Binary made executable" && \
    ls -la /usr/local/bin/gotify

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