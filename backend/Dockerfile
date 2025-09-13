# Multi-stage Dockerfile for Node.js backend with OEMER
FROM node:18-alpine AS base

# Install Python and system dependencies for OEMER
RUN apk add --no-cache \
    python3 \
    py3-pip \
    py3-numpy \
    py3-opencv \
    py3-pillow \
    libpng \
    libjpeg-turbo \
    libtiff \
    openblas \
    lapack \
    g++ \
    make \
    && ln -sf python3 /usr/bin/python

# Install OEMER in a separate layer for better caching
FROM base AS oemer-install
WORKDIR /tmp
RUN pip3 install --no-cache-dir oemer

# Production dependencies
FROM base AS deps
WORKDIR /app
COPY backend/package.json backend/package-lock.json* ./
RUN npm ci --only=production

# Build stage
FROM base AS builder
WORKDIR /app
COPY backend/ ./
COPY --from=deps /app/node_modules ./node_modules
RUN npm run build 2>/dev/null || echo "No build step required"

# Production stage
FROM base AS runner
WORKDIR /app

# Copy OEMER installation
COPY --from=oemer-install /usr/lib/python3.*/site-packages /usr/lib/python3.*/site-packages
COPY --from=oemer-install /usr/bin/oemer /usr/bin/oemer

# Copy application code
COPY --from=builder /app ./

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nodejs

# Create necessary directories with correct permissions
RUN mkdir -p downloads temp logs \
    && chown -R nodejs:nodejs downloads temp logs

# Switch to non-root user
USER nodejs

# Environment variables
ENV NODE_ENV=production
ENV PYTHON_PATH=python3
ENV PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8080/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

EXPOSE 8080

CMD ["npm", "start"]
