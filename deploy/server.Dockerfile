# ZimaOS server-backed Memini API image.
#
# This first server slice packages the Dart API and SQLite persistence. The
# existing local-first Flutter Web app remains built by deploy/Dockerfile until
# the client gains a server-mode login/repository layer.

ARG DART_IMAGE=dart:stable

FROM --platform=$BUILDPLATFORM ${DART_IMAGE} AS server_build
WORKDIR /src/apps/server
COPY apps/server/pubspec.yaml apps/server/pubspec.lock* ./
RUN dart pub get
COPY apps/server/ ./
RUN dart compile exe bin/server.dart -o /src/memini-server

FROM ${DART_IMAGE} AS runtime
RUN apt-get update \
    && apt-get install -y --no-install-recommends sqlite3 libsqlite3-0 libsqlite3-dev wget \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=server_build /src/memini-server /app/memini-server
RUN mkdir -p /app/data /app/public \
    && printf '%s\n' '<!doctype html><meta charset="utf-8"><title>Memini Server</title><h1>Memini Server</h1><p>API is running. Check <a href="/healthz">/healthz</a>.</p>' > /app/public/index.html

ENV HOST=0.0.0.0 \
    PORT=8080 \
    DATA_DIR=/app/data \
    PUBLIC_DIR=/app/public

EXPOSE 8080
VOLUME ["/app/data"]

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://127.0.0.1:8080/healthz || exit 1

CMD ["/app/memini-server"]
