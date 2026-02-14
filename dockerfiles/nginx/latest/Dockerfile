# Base image with latest stable Nginx on Alpine Linux.
FROM nginx:1.29-alpine-slim

# Use root for package operations and file collection.
USER root

# Refresh package metadata, apply upgrades, and install helper tools.
RUN set -eux; \
    apk update; \
    apk upgrade --no-cache; \
    apk add --no-cache tzdata wget tar rsync

# Assemble Nginx runtime files and dependent shared libraries under /opt.
RUN set -eux; \
    mkdir -p /opt/var/cache/nginx /opt/etc /opt/var/www/html; \
    cp -a /usr/share/nginx/html/. /opt/var/www/html/; \
    cp -a --parents /usr/lib/nginx /opt; \
    cp -a --parents /usr/share/nginx /opt; \
    cp -a --parents /var/log/nginx /opt; \
    cp -aL --parents /var/run /opt; \
    cp -a --parents /etc/nginx /opt; \
    cp -a --parents /etc/passwd /opt; \
    cp -a --parents /etc/group /opt; \
    cp -a --parents /usr/sbin/nginx /opt; \
    ldd /usr/sbin/nginx \
      | awk '{ if ($3 ~ /^\//) print $3; else if ($1 ~ /^\//) print $1; }' \
      | sort -u \
      | while IFS= read -r so; do \
          case "$so" in \
            /lib/*) target="/opt/usr/lib/${so#/lib/}" ;; \
            /lib64/*) target="/opt/usr/lib64/${so#/lib64/}" ;; \
            *) target="/opt${so}" ;; \
          esac; \
          mkdir -p "$(dirname "$target")"; \
          cp -aL "$so" "$target"; \
        done
