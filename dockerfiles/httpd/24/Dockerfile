FROM httpd:2.4-alpine

USER root

RUN set -eux; \
    mkdir -p /opt/etc /opt/var/www/html; \
    cp -a /usr/local/apache2/htdocs/. /opt/var/www/html/; \
    cp -a --parents /usr/local/apache2 /opt; \
    cp -a --parents /etc/passwd /opt; \
    cp -a --parents /etc/group /opt; \
    cp -aL --parents /var/run /opt; \
    ( \
      ldd /usr/local/apache2/bin/httpd; \
      find /usr/local/apache2/modules -type f -name '*.so' -exec ldd '{}' ';' \
    ) 2>/dev/null \
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
