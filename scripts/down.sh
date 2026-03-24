#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

echo "Останавливаю и удаляю контейнеры..."
docker compose down

echo "Готово."
echo "Если нужно также удалить volumes:"
echo "  docker compose down -v"