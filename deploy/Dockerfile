# Memini's web build served by nginx (STACK-APPS-DINAMICAS.md 5.A).
#
# Build context: repository root (the folder that contains apps/client and deploy/).
#   docker build -f deploy/Dockerfile -t memini .
#
# Multi-arch (ZimaBoard/ZimaBlade are x86_64; some home servers are ARM):
#   docker buildx build -f deploy/Dockerfile \
#     --platform linux/amd64,linux/arm64 \
#     -t ghcr.io/iezappa/memini:latest --push .
#
# The Flutter build output (HTML/JS/WASM) is architecture-independent, so the
# build stage always runs on the builder's native platform ($BUILDPLATFORM).
# Only the tiny nginx stage is resolved per target platform: no QEMU emulation
# of the Flutter SDK is needed.

# ---------- Stage 1: build Flutter web ----------
FROM --platform=$BUILDPLATFORM ubuntu:24.04 AS build

# Path of the Flutter project inside the repository.
ARG APP_DIR=apps/client
# The container serves the app at the root of its own origin.
ARG BASE_HREF=/
# Keep this in sync with release.yml/subosito-flutter-action.
ARG FLUTTER_VERSION=3.47.1

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      file \
      git \
      unzip \
      xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
      | tar -xJ -C /opt \
    && git config --global --add safe.directory /opt/flutter \
    && flutter --version \
    && flutter config --enable-web

WORKDIR /src
COPY ${APP_DIR}/pubspec.yaml ${APP_DIR}/pubspec.lock* ./
RUN flutter pub get

COPY ${APP_DIR}/ ./
# --no-web-resources-cdn: bundle CanvasKit/skwasm instead of loading them from
# gstatic.com. Required because nginx.conf sends
# Cross-Origin-Embedder-Policy: require-corp (see comments there).
RUN flutter build web --release \
      --base-href "${BASE_HREF}" \
      --no-web-resources-cdn

# Drift needs these two files next to index.html (same Drift version).
RUN test -f build/web/sqlite3.wasm && test -f build/web/drift_worker.js \
    || (echo "Missing web/sqlite3.wasm or web/drift_worker.js (see Drift web docs)" && exit 1)

# Own service worker (STACK-APPS-DINAMICAS.md 8.2): inject version + precache
# manifest into build/web/sw.js. Must run after the last file lands in build/web.
RUN sh tool/generate_sw.sh build/web pubspec.yaml

# ---------- Stage 2: serve with nginx (non-root, port 8080) ----------
FROM nginxinc/nginx-unprivileged:stable-alpine

COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/build/web /usr/share/nginx/html

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://127.0.0.1:8080/healthz || exit 1

