#!/usr/bin/env bash
set -euo pipefail

# Define o diretório da aplicação na VPS
# Pode ser configurado via GitHub Actions secret APP_DIR, default para /srv/chatwoot
APP_DIR="${APP_DIR:-/srv/chatwoot}"
cd "$APP_DIR" || { echo "Erro: Diretório da aplicação ($APP_DIR) não encontrado."; exit 1; }

echo "[1/5] Atualizando o repositório Git..."
git fetch --all
git reset --hard origin/main # Garante que o ambiente local corresponde ao remoto

echo "[2/5] Copiando .env para o diretório da aplicação (se não for um symlink)..."
# Se .env já existe e não é um symlink, ele será sobrescrito.
# Se for um symlink para um .env em outro lugar, mantenha-o.
if [ -f ".env" ] && [ ! -L ".env" ]; then
  cp .env.example .env.backup || true # Backup opcional do .env existente
  cp .env.template .env # Copia o template base para .env, o usuário irá editar.
  # TODO: Poderíamos fazer um merge mais inteligente aqui se houver um .env local personalizado
fi


echo "[3/5] Pull das imagens Docker mais recentes..."
docker compose pull

echo "[4/5] Subindo/atualizando os serviços Docker Swarm..."
# Este comando substituirá o docker stack deploy para usar docker compose no modo swarm
docker compose up -d

echo "[5/5] Limpeza de imagens Docker não utilizadas..."
docker system prune -f --volumes # Adicionado --volumes para limpar volumes anônimos

echo "Deploy concluído. Verifique o status dos serviços com 'docker compose ps' ou no Portainer."
