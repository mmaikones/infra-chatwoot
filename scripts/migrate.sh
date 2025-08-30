#!/usr/bin/env bash
set -euo pipefail

# Define o diretório da aplicação na VPS
APP_DIR="${APP_DIR:-/srv/chatwoot}"
cd "$APP_DIR" || { echo "Erro: Diretório da aplicação ($APP_DIR) não encontrado."; exit 1; }

echo "[MIGRATE] Executando migrações do banco de dados..."
# O comando abaixo prepara o banco de dados (cria se não existir, e roda migrações)
docker compose exec -T chatwoot_app bundle exec rails db:chatwoot_prepare

echo "[MIGRATE] Migrações concluídas."
