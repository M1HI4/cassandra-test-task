#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

if [[ ! -f .env ]]; then
  echo "Файл .env не найден."
  echo "Скопируйте .env.example в .env и при необходимости поправьте значения:"
  echo "  cp .env.example .env"
  exit 1
fi

echo "[1/4] Проверка Docker..."
docker version >/dev/null
docker compose version >/dev/null

echo "[2/4] Сборка образа..."
docker compose build --pull

echo "[3/4] Запуск кластера..."
docker compose up -d

echo "[4/4] Состояние контейнеров:"
docker compose ps

echo
echo "Кластер запущен."
echo "Проверка логов:"
echo "  docker logs -f cassandra-1"
echo
echo "Проверка статуса кластера:"
echo "  docker exec -it cassandra-1 nodetool status"