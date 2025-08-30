#!/usr/bin/env bash
set -euo pipefail

# Define o diretório da aplicação na VPS
# Pode ser configurado via GitHub Actions secret APP_DIR, default para /srv/chatwoot
APP_DIR="${APP_DIR:-/srv/chatwoot}"
cd "$APP_DIR" || { echo "Erro: Diretório da aplicação ($APP_DIR) não encontrado."; exit 1; }

echo "[1/4] Atualizando o repositório Git..."
git fetch --all
git reset --hard origin/main # Garante que o ambiente local corresponde ao remoto

# Removida a seção de cópia de .env.example/.env.template
# O arquivo .env principal é parte do repositório Git e é lido diretamente pelo docker-compose.yml

echo "[2/4] Pull das imagens Docker mais recentes..."
docker compose pull

echo "[3/4] Subindo/atualizando os serviços Docker Swarm..."
# Este comando substituirá o docker stack deploy para usar docker compose no modo swarm
docker compose up -d

echo "[4/4] Limpeza de imagens Docker não utilizadas..."
docker system prune -f --volumes # Adicionado --volumes para limpar volumes anônimos

echo "Deploy concluído. Verifique o status dos serviços com 'docker compose ps' ou no Portainer."
