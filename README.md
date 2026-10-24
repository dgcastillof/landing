# Asterión

La página de inicio de dgcastillof.com.ar, con los accesos a los proyectos. Es un solo
`public/index.html`, sin build: lo sirve directo el Caddy del servidor de
Lightsail (el mismo de Moneta, ver `moneta/docs/aws.md`).

**Cada push a `main` se publica solo** en menos de un minuto, igual que Moneta.

## Sumar o activar una app

En `public/index.html`, en `PROJECTS`: cada app tiene su subdominio (o `url`
si tiene dominio propio) y `live`.
Solo aparecen las que tienen `live: true`. El ícono va en `public/icons/`.

## Logo

`public/asterion.svg` es el original (512 px, esquinas de 114 px). Todo lo
demás sale de él: `favicon.ico` (16/32/48), `apple-touch-icon.png` (180,
cuadrado: iOS redondea solo), `icon-192.png` e `icon-512.png` (redondeados),
`icon-maskable-512.png` (fondo hasta el borde, dibujo al 78% para la zona
segura de Android) y `og.png` (1200×630, vista previa al compartir el link).
Si cambia el logo, hay que volver a exportarlos.

## Cómo se publica

| Qué | Dónde |
|---|---|
| Repo en el servidor | `/srv/apps/landing/repo` |
| Lo que sirve Caddy | `/srv/apps/caddy/sites/landing` (copia de `public/`) |
| Config de Caddy | `/srv/apps/caddy/sites/landing.caddy` (copia de `deploy/landing.caddy`) |
| Deploy | `landing-actualizar.timer`: cada minuto, como `deploy`, corre `/usr/local/bin/landing-actualizar` (`deploy/actualizar.sh`) |

- Ver qué pasó: `journalctl -u landing-actualizar -n 50`
- Commit publicado: `/srv/apps/landing/publicado`
- Volver a publicar el mismo commit: `sudo -u deploy FORZAR=1 landing-actualizar`

Va en `sites/` porque cada deploy de Moneta reescribe `compose.yaml` y
`Caddyfile` en `/srv/apps/caddy`, pero no toca el resto de `sites/`. Esa
carpeta ya está montada en el contenedor de Caddy, así que la landing entra sin
cambiar la configuración compartida.

## Instalación (una sola vez)

1. **DNS**: Lightsail › Domains & DNS › `dgcastillof.com.ar` › Add record:
   - Tipo **A**, nombre `@` (vacío) → IP fija de `sv-dgcastillof`
   - Tipo **A**, nombre `www` → la misma IP
2. **Servidor**: Lightsail › `sv-dgcastillof` › Connect (SSH en el navegador):

```bash
curl -fsSL https://raw.githubusercontent.com/dgcastillof/landing/main/deploy/instalar.sh | sudo bash
```

Caddy saca solo el certificado HTTPS en cuanto el DNS apunta al servidor
(puede tardar unos minutos).

Si cambia `deploy/actualizar.sh` o las unidades de systemd, hay que volver a
correr `instalar.sh` (el resto se actualiza solo).
