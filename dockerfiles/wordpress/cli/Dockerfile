# Base image with WordPress CLI tooling on Alpine Linux.
FROM wordpress:cli

# Use root for package operations and file collection.
USER root

# Refresh package metadata, apply upgrades, and install helper tools.
RUN set -eux; \
    apk update; \
    apk upgrade --no-cache; \
    apk add --no-cache tzdata wget tar rsync

# Copy WordPress source used by wp-cli workflows in this image.
COPY --from=wordpress:php8.3-fpm-alpine /usr/src/wordpress/ /usr/src/wordpress/

# Assemble CLI runtime files, BusyBox symlinks, and shared libraries under /opt.
RUN set -eux; \
    mkdir -p /opt; \
    BB="$(command -v busybox.static || command -v busybox)"; \
    mkdir -p /opt/usr/bin; \
    cp -a "${BB}" /opt/usr/bin/busybox; \
    chmod 0755 /opt/usr/bin/busybox; \
    ln -sf /usr/bin/busybox /opt/usr/bin/sh; \
    ln -sf /usr/bin/busybox /opt/usr/bin/sleep; \
    ln -sf /usr/bin/busybox /opt/usr/bin/grep; \
    ln -sf /usr/bin/busybox /opt/usr/bin/cat; \
    ln -sf /usr/bin/busybox /opt/usr/bin/rm; \
    ln -sf /usr/bin/busybox /opt/usr/bin/touch; \
    ln -sf /usr/bin/busybox /opt/usr/bin/env; \
    cp -a --parents /usr/local /opt; \
    cp -a --parents /var/www/html /opt; \
    cp -a --parents /etc/passwd /opt; \
    cp -a --parents /etc/group /opt; \
    cp -a --parents /etc/ssl /opt; \
    cp -a --parents /etc/services /opt; \
    cp -a --parents /etc/nsswitch.conf /opt; \
    ( \
      if [ -x /usr/local/sbin/php-fpm ]; then ldd /usr/local/sbin/php-fpm; fi; \
      if [ -x /usr/local/bin/php ]; then ldd /usr/local/bin/php; fi; \
      if [ -d /usr/local/lib/php/extensions ]; then \
        find /usr/local/lib/php/extensions -type f -name '*.so' -exec ldd '{}' ';'; \
      fi \
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
