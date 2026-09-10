FROM php:8.3-fpm-alpine

# Instalar dependencias del sistema requeridas
RUN apk add --no-cache \
    sqlite-dev \
    libzip-dev \
    zip \
    unzip \
    tzdata \
    shadow

# Ajustar el usuario www-data al UID 1000 para sincronizar los permisos con el host local
RUN usermod -u 1000 www-data && \
    groupmod -g 1000 www-data
# Instalar las extensiones de PHP necesarias
RUN docker-php-ext-install pdo pdo_sqlite zip

# Configurar PHP para permitir subidas de archivos más grandes
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' "$PHP_INI_DIR/php.ini" && \
    sed -i 's/post_max_size = 8M/post_max_size = 50M/g' "$PHP_INI_DIR/php.ini"

# Configurar el directorio de trabajo
WORKDIR /var/www/html

COPY ./kutsocial .

# Crear el directorio de datos (si no existe) y asignar permisos
RUN mkdir -p /var/www/html/data && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html
