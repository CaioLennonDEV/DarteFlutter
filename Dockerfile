# ==========================================
# Stage 1: Build Flutter Web Application
# ==========================================
FROM ghcr.io/cirruslabs/flutter:3.24.5 AS builder

WORKDIR /app

# Enable Flutter Web
RUN flutter config --enable-web

# Copy dependency specifications first to leverage Docker layer caching
COPY pubspec.yaml analysis_options.yaml ./
RUN flutter pub get

# Copy all source files
COPY . .

# Build production Flutter Web bundle
RUN flutter build web --release

# ==========================================
# Stage 2: Serve with Nginx Alpine (Lightweight)
# ==========================================
FROM nginx:alpine AS production

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy built web files from Stage 1
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom Nginx configuration for Flutter SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose HTTP port
EXPOSE 80

# Health check to ensure Nginx is responding
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:80/ || exit 1

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
