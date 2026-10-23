#!/usr/bin/env bash
# /usr/local/bin/landing-actualizar: lo corre el timer landing-actualizar cada
# minuto, como `deploy`. Si `origin/main` tiene un commit que todavía no está
# publicado, copia public/ a la carpeta que sirve Caddy y recarga Caddy.
#
# Igual que moneta-actualizar: tira desde el servidor, sin Actions ni llaves en
# GitHub. El repo es público, así que no hace falta deploy key.
# Lo que pasó queda en `journalctl -u landing-actualizar`.
set -euo pipefail

BASE=/srv/apps/landing
REPO="$BASE/repo"
SITIO=/srv/apps/caddy/sites/landing
exec 9>"$BASE/.lock"
flock -n 9 || exit 0

git -C "$REPO" fetch --quiet origin main
nuevo=$(git -C "$REPO" rev-parse origin/main)
publicado=$(cat "$BASE/publicado" 2>/dev/null || true)
[ "$nuevo" = "$publicado" ] && [ -z "${FORZAR:-}" ] && exit 0

echo "Publicando ${nuevo:0:7} (antes: ${publicado:0:7})"
git -C "$REPO" checkout --quiet --force --detach "$nuevo"

# Se arma al lado y se cambia de golpe, para no servir nunca una copia a medias.
rm -rf "$SITIO.nuevo" "$SITIO.viejo"
cp -r "$REPO/public" "$SITIO.nuevo"
if [ -d "$SITIO" ]; then mv "$SITIO" "$SITIO.viejo"; fi
mv "$SITIO.nuevo" "$SITIO"
rm -rf "$SITIO.viejo"

cp "$REPO/deploy/landing.caddy" /srv/apps/caddy/sites/landing.caddy
docker exec caddy caddy reload --config /etc/caddy/Caddyfile >/dev/null

echo "$nuevo" > "$BASE/publicado"
