FROM php:8.3-fpm-alpine

RUN apk add --no-cache \
    sqlite-dev \
    libzip-dev \
    curl-dev \
    openssl \
    zip \
    unzip \
    tzdata \
    shadow \
    fcgi

RUN usermod -u 1000 www-data && \
    groupmod -g 1000 www-data

RUN docker-php-ext-install pdo pdo_sqlite zip curl opcache

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' "$PHP_INI_DIR/php.ini" && \
    sed -i 's/post_max_size = 8M/post_max_size = 50M/g' "$PHP_INI_DIR/php.ini"

WORKDIR /var/www/html

COPY ./kutsocial .
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    mkdir -p /var/www/html/data/uploads /var/www/html/data/backups && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

USER www-data

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.0.0.1:9000 || exit 1
