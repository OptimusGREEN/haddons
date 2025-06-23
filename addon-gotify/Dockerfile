FROM gotify/server:2.6.3

# Install bashio and Home Assistant add-on requirements
USER root
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    tzdata

# Install bashio
RUN curl -J -L -o /tmp/bashio.tar.gz \
    "https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio.tar.gz /tmp/bashio

# Copy configuration files
COPY run.sh /
RUN chmod a+x /run.sh

# Create data directory with proper permissions
RUN mkdir -p /data && chown -R 1000:1000 /data

# Switch back to gotify user
USER 1000

# Set working directory
WORKDIR /data

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start with our custom run script
CMD ["/run.sh"]