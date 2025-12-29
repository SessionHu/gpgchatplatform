# ---- Builder Stage ----
FROM debian:stable-slim AS builder

# Install build dependencies
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  ca-certificates \
  clang \
  coreutils \
  curl \
  findutils \
  ldc \
  make && \
  rm -rf /var/lib/apt/lists/*

# Install cloudflared
RUN mkdir -p --mode=0755 /usr/share/keyrings && \
  curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg -o /usr/share/keyrings/cloudflare-public-v2.gpg
RUN echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' > /etc/apt/sources.list.d/cloudflared.list
RUN apt-get update && \
  apt-get install cloudflared && \
  rm -rf /var/lib/apt/lists/*

# Copy source code
COPY . /app

# Set working directory
WORKDIR /app

# Build the project
RUN make -j$(nproc)

# ---- Runner Stage ----
FROM debian:stable-slim

# Install runtime dependencies
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  bash \
  busybox \
  coreutils \
  curl \
  gnupg && \
  rm -rf /var/lib/apt/lists/*

# Copy cloudflared binary from builder stage
COPY --from=builder /usr/bin/cloudflared /usr/bin/cloudflared

# Copy built artifacts from builder stage
COPY --from=builder /app/server /app/server
COPY --from=builder /app/start_server.sh /app/start_server.sh

# Set working directory
WORKDIR /app

# Expose port
EXPOSE 8080

# Set entrypoint
ENTRYPOINT ["./start_server.sh"]

# Set labels
LABEL org.opencontainers.image.source=https://github.com/SessionHu/gpgchatplatform
LABEL org.opencontainers.image.licenses=GPL-3.0-or-later
