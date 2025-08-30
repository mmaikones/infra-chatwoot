#!/usr/bin/env bash
set -euo pipefail

# Define o diretório da aplicação na VPS
# Pode ser configurado via GitHub Actions secret APP_DIR, default para /srv/chatwoot
APP_DIR="${APP_DIR:-/srv/chatwoot}"
cd "$APP_DIR" || { echo "Erro: Diretório da aplicação ($APP_DIR) não encontrado."; exit 1; }

echo "[1/4] Atualizando o repositório Git..."
git fetch --all
git reset --hard origin/main # Garante que o ambiente local corresponde ao remoto

echo "[2/4] Pull das imagens Docker mais recentes..."
docker compose pull # Ainda usamos compose pull para baixar as imagens

echo "[3/4] Subindo/atualizando os serviços Docker Swarm (com docker stack deploy)..."
# USAMOS 'docker stack deploy' para gerenciar serviços em um Docker Swarm
# 'chatwoot' é o nome da sua stack no Swarm
docker stack deploy -c docker-compose.yml chatwoot

echo "[4/4] Limpeza de imagens Docker não utilizadas..."
docker system prune -f --volumes # Adicionado --volumes para limpar volumes anônimos

echo "Deploy concluído. Verifique o status dos serviços com 'docker service ls' ou no Portainer."
