# KutSocial Docker

Dockerización del proyecto [KutSocial](https://github.com/ernestoacostame/kutsocial).

## Requisitos

- Docker
- Docker Compose

## Instalación

1. Clonar este repositorio:

```bash
git clone https://github.com/neoranger/kutsocial-docker.git
cd kutsocial
```

2. Clonar el proyecto KutSocial dentro del directorio actual:

```bash
git clone https://github.com/ernestoacostame/kutsocial.git
```

3. Levantar los contenedores:

```bash
docker-compose up -d
```

4. La aplicación estará disponible en: `http://localhost:8080`

## Servicios

| Servicio | Descripción |
|----------|-------------|
| `app` | Contenedor PHP-FPM con la aplicación |
| `worker` | Procesa tareas en segundo plano y ActivityPub (cron cada 60s) |
| `web` | Servidor Nginx (puerto 8080) |

## Comandos útiles

```bash
# Ver logs
docker-compose logs -f

# Detener contenedores
docker-compose down

# Reconstruir imágenes
docker-compose build --no-cache
```
