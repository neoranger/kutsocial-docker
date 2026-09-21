#!/bin/sh
set -e
mkdir -p /var/www/html/data/uploads /var/www/html/data/backups
chown -R www-data:www-data /var/www/html/data
chmod -R 755 /var/www/html/data
exec "$@"
