ARG BUILD_FROM
FROM $BUILD_FROM

# Install gotify server
RUN apk add --no-cache \
    ca-certificates \
    tzdata

# Copy gotify binary from official image
COPY --from=gotify/server:latest /app/gotify-linux-amd64 /usr/local/bin/gotify

# Make gotify executable
RUN chmod +x /usr/local/bin/gotify

# Copy configuration files
COPY run.sh /
COPY config.yml.tmpl /

# Make run script executable
RUN chmod a+x /run.sh

# Set working directory
WORKDIR /data

# Expose port
EXPOSE 8080

# Start gotify
CMD ["/run.sh"]