FROM golang:1.22-alpine as builder

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git ca-certificates

# Clone the latest stable Gotify release
RUN git clone --depth=1 --branch v2.4.0 https://github.com/gotify/server.git .

# Build the binary
RUN go build -o gotify

# --- Final stage image ---
FROM alpine:3.19

# Create non-root user
RUN adduser -D -H -u 1000 gotify

# Copy binary
COPY --from=builder /app/gotify /usr/local/bin/gotify

# Use non-root user
USER gotify

# Expose port
EXPOSE 80

# Run Gotify with config (mounted by addon)
COPY run.sh /run.sh
RUN chmod +x /run.sh
CMD [ "/run.sh" ]