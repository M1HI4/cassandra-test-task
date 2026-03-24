#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

if [[ ! -f .env ]]; then
  echo "Файл .env не найден."
  echo "Скопируйте .env.example в .env:"
  echo "  cp .env.example .env"
  exit 1
fi

set -a
source .env
set +a

PARENT_IFACE="${PARENT_IFACE:-enp0s3}"
HOST_MACVLAN_IP="${HOST_MACVLAN_IP:-192.168.1.199}"
ROUTE_CIDR="192.168.1.200/29"
SHIM_NAME="macvlan-shim"

usage() {
  echo "Использование:"
  echo "  $0 up     - создать host-side macvlan интерфейс"
  echo "  $0 down   - удалить host-side macvlan интерфейс"
  echo "  $0 status - показать состояние"
}

cmd_up() {
  if ip link show "$SHIM_NAME" >/dev/null 2>&1; then
    echo "Интерфейс $SHIM_NAME уже существует."
  else
    sudo ip link add "$SHIM_NAME" link "$PARENT_IFACE" type macvlan mode bridge
    sudo ip addr add "${HOST_MACVLAN_IP}/32" dev "$SHIM_NAME"
    sudo ip link set "$SHIM_NAME" up
    sudo ip route add "$ROUTE_CIDR" dev "$SHIM_NAME"
    echo "Интерфейс $SHIM_NAME создан."
  fi

  echo
  ip addr show "$SHIM_NAME"
  echo
  ip route | grep "$ROUTE_CIDR" || true
  echo
  echo "Проверка связи:"
  ping -c 2 192.168.1.200 || true
}

cmd_down() {
  if ip route | grep -q "$ROUTE_CIDR"; then
    sudo ip route del "$ROUTE_CIDR" dev "$SHIM_NAME" || true
  fi

  if ip link show "$SHIM_NAME" >/dev/null 2>&1; then
    sudo ip link delete "$SHIM_NAME"
    echo "Интерфейс $SHIM_NAME удален."
  else
    echo "Интерфейс $SHIM_NAME не существует."
  fi
}

cmd_status() {
  ip link show "$SHIM_NAME" || true
  echo
  ip addr show "$SHIM_NAME" || true
  echo
  ip route | grep "$ROUTE_CIDR" || true
}

case "${1:-}" in
  up) cmd_up ;;
  down) cmd_down ;;
  status) cmd_status ;;
  *) usage; exit 1 ;;
esac