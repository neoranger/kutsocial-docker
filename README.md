# KutSocial Docker

Dockerización del proyecto [KutSocial](https://github.com/ernestoacostame/kutsocial).

## Requisitos

- Docker
- Docker Compose

## Instalación

1. Clonar este repositorio y el código de KutSocial (el compose lo monta con bind, así que `git pull` refresca el código sin rebuild):

```bash
git clone https://github.com/neoranger/kutsocial-docker.git
cd kutsocial-docker
git clone https://github.com/ernestoacostame/kutsocial.git
```

> El `.gitignore` ya excluye `kutsocial/`, así que `config.php` (generado por el instalador dentro de `./kutsocial/`) no se commitea.

2. Levantar los contenedores:

```bash
docker compose up -d --build
```

3. Abrir `http://localhost:8080/install.php`, completar el instalador web y luego **eliminar o renombrar `install.php`** dentro del volumen por seguridad.

4. La aplicación estará disponible en: `http://localhost:8080`

## Servicios

| Servicio | Descripción |
|----------|-------------|
| `app` | PHP-FPM 8.3 (`pdo_sqlite`, `curl`, `zip`, `openssl`, `opcache`). Healthcheck + entrypoint que crea `data/uploads` y `data/backups` |
| `worker` | Procesa la cola vía `cron.php` cada 60s (espera a `app` healthy) |
| `web` | Nginx (puerto 8080), `root /var/www/html`, `fastcgi_pass app:9000`, bloquea `/data`, `/src` y `config.php`, sirve `/data/uploads`, `client_max_body_size 50M`, buffering off para SSE |

## Volúmenes y actualización

- **Código:** bind mount `./kutsocial:/var/www/html` (y `:ro` en `web`). `git pull` en `./kutsocial` + `docker compose up -d` alcanza para desplegar código nuevo. Solo reconstruí la imagen si cambió `Dockerfile`, `nginx/` o `docker-entrypoint.sh`.
- **Datos persistentes:** volumen nombrado `kutsocial_data` montado en `/var/www/html/data` (DB sqlite, `uploads`, `backups`, `data/updates` con zips y `rollback-*.tar.gz`). Sobrevive a rebuilds y a `docker compose down`. Solo se borra con `down -v`.
- **`config.php`:** vive en `./kutsocial/config.php` (bind, no se commitea). Sobrevive a rebuilds.
- **Actualizador del admin:** funciona (tiene `zip`, `curl`, `openssl`, `tar` y escritura como `www-data` tanto en el código como en `data/`). Sus cambios caen sobre el bind `./kutsocial` (visibles en el host) y sus backups en el volumen. Elegí una vía canónica: o actualizás por git, o por el updater — si usás el updater y después hacés `git pull`, resolvé el posible conflicto en `./kutsocial` como en cualquier repo.

## Backup (antes de actualizar o llevar a prod)

```bash
# Backup de datos (DB, uploads, updates/rollbacks)
docker run --rm -v kutsocial_kutsocial_data:/data -v "$PWD":/backup alpine \
  tar -czf /backup/kutsocial_data_$(date +%F).tar.gz -C /data .

# Backup de config
cp kutsocial/config.php "config.php.bak_$(date +%F)"

# Restore de datos
docker run --rm -v kutsocial_kutsocial_data:/data -v "$PWD":/backup alpine \
  tar -xzf /backup/kutsocial_data_<fecha>.tar.gz -C /data
```

## Comandos útiles

```bash
# Ver logs
docker compose logs -f

# Detener contenedores (mantiene datos)
docker compose down

# Detener y borrar datos (incluye config.php y la DB sqlite)
docker compose down -v

# Reconstruir imágenes
docker compose build --no-cache

# Cambiar el dominio (usado por cron.php en modo CLI)
KUTSOCIAL_DOMAIN=ejemplo.com docker compose up -d
```
