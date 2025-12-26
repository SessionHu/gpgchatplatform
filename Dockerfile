# ---- Builder Stage ----
FROM alpine:latest AS builder

# Install build dependencies
RUN apk add --no-cache \
  coreutils \
  findutils \
  gcc \
  ldc \
  make \
  musl-dev

# Copy source code
COPY . /app

# Set working directory
WORKDIR /app

# Build the project
RUN make -j$(nproc)


# ---- Runner Stage ----
FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache \
  gnupg \
  busybox \
  coreutils \
  bash

# Copy built artifacts from builder stage
COPY --from=builder /app/server /app/server
COPY --from=builder /app/start_server.sh /app/start_server.sh

# Set working directory
WORKDIR /app

# Expose port
EXPOSE 8080

# Set entrypoint
ENTRYPOINT ["./start_server.sh"]
