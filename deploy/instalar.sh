#!/usr/bin/env bash
# Instala la landing en el servidor, una sola vez. Se corre como root:
#   curl -fsSL https://raw.githubusercontent.com/dgcastillof/landing/main/deploy/instalar.sh | sudo bash
# Después, cada push a main se publica solo en un minuto.
set -euo pipefail

BASE=/srv/apps/landing
REPO="$BASE/repo"

install -d -o deploy -g deploy "$BASE"
if [ ! -d "$REPO/.git" ]; then
  sudo -u deploy git clone --quiet https://github.com/dgcastillof/landing.git "$REPO"
fi

install -m 755 "$REPO/deploy/actualizar.sh" /usr/local/bin/landing-actualizar
install -m 644 "$REPO/deploy/landing-actualizar.service" "$REPO/deploy/landing-actualizar.timer" /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now landing-actualizar.timer

sudo -u deploy FORZAR=1 /usr/local/bin/landing-actualizar
echo "Listo: la landing se publica sola con cada push a main."
