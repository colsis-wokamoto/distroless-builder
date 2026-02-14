# Base image with WordPress PHP 8.3 FPM on Alpine Linux.
FROM wordpress:php8.3-fpm-alpine

# Use root for package operations and file collection.
USER root

# Refresh package metadata, apply upgrades, and install helper tools.
RUN set -eux; \
    apk update; \
    apk upgrade --no-cache; \
    apk add --no-cache tzdata wget tar rsync

# Assemble PHP/WordPress runtime files and shared libraries under /opt.
RUN set -eux; \
    mkdir -p /opt; \
    cp -a --parents /usr/local /opt; \
    cp -a --parents /var/www/html /opt; \
    cp -a --parents /etc/passwd /opt; \
    cp -a --parents /etc/group /opt; \
    cp -a --parents /etc/ssl /opt; \
    cp -a --parents /etc/services /opt; \
    cp -a --parents /etc/nsswitch.conf /opt; \
    ( \
      ldd /usr/local/sbin/php-fpm; \
      ldd /usr/local/bin/php; \
      find /usr/local/lib/php/extensions -type f -name '*.so' -exec ldd '{}' ';' \
    ) 2>/dev/null \
      | awk '{ if ($3 ~ /^\//) print $3; else if ($1 ~ /^\//) print $1; }' \
      | sort -u \
      | while IFS= read -r so; do \
          case "${so}" in \
            /lib/*) target="/opt/usr/lib/${so#/lib/}" ;; \
            /lib64/*) target="/opt/usr/lib64/${so#/lib64/}" ;; \
            *) target="/opt${so}" ;; \
          esac; \
          mkdir -p "$(dirname "${target}")"; \
          cp -aL "${so}" "${target}"; \
        done
