# dgcastillof.com.ar

La página de inicio con los accesos a los proyectos. Es un solo `index.html`,
sin build: lo sirve directo el Caddy del servidor de Lightsail (el mismo de
Moneta, ver `moneta/docs/aws.md`).

## Sumar o activar una app

En `index.html`, en `PROJECTS`: cada app tiene su subdominio y `live`. Solo
aparecen las que tienen `live: true`. El ícono va en `icons/`.

## Publicar por primera vez

1. **DNS** — Lightsail › Domains & DNS › `dgcastillof.com.ar` › Add record:
   - Tipo **A**, nombre `@` (vacío) → IP fija de `sv-dgcastillof`
   - Tipo **A**, nombre `www` → la misma IP
2. **Servidor** — Lightsail › `sv-dgcastillof` › Connect (SSH en el navegador):

```bash
sudo -u deploy git clone https://github.com/dgcastillof/landing.git /srv/apps/caddy/sites/landing
sudo -u deploy cp /srv/apps/caddy/sites/landing/landing.caddy /srv/apps/caddy/sites/landing.caddy
sudo docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

Caddy saca solo el certificado HTTPS en cuanto el DNS apunta al servidor
(puede tardar unos minutos).

## Actualizar

Después de hacer push:

```bash
sudo -u deploy git -C /srv/apps/caddy/sites/landing pull
```

Si cambió `landing.caddy`, además:

```bash
sudo -u deploy cp /srv/apps/caddy/sites/landing/landing.caddy /srv/apps/caddy/sites/landing.caddy
sudo docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

## Por qué está en `sites/`

Cada deploy de Moneta reescribe `compose.yaml` y `Caddyfile` en
`/srv/apps/caddy` con los del repo de Moneta, pero no toca nada más de
`sites/`. Esa carpeta ya está montada en el contenedor de Caddy, así que la
landing entra sin cambiar la configuración compartida ni reiniciar Caddy.
