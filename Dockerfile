# ---- Builder Stage ----
FROM debian:stable-slim AS builder

# Install build dependencies
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  clang \
  coreutils \
  findutils \
  ldc \
  make && \
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
  gnupg && \
  rm -rf /var/lib/apt/lists/*

# Copy built artifacts from builder stage
COPY --from=builder /app/server /app/server
COPY --from=builder /app/start_server.sh /app/start_server.sh

# Set working directory
WORKDIR /app

# Expose port
EXPOSE 8080

# Set entrypoint
ENTRYPOINT ["./start_server.sh"]
