#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
umask 077
touch .env

add_if_missing() {
  if ! grep -q "^$1=" .env; then
    echo "$1=$2" >> .env
    echo "Generated $1"
  fi
}

add_if_missing LITELLM_MASTER_KEY "sk-$(openssl rand -hex 32)"
add_if_missing LITELLM_SALT_KEY   "sk-$(openssl rand -hex 32)"
add_if_missing POSTGRES_PASSWORD  "$(openssl rand -hex 32)"
add_if_missing ADMIN_USER_ID   "admin"
add_if_missing ADMIN_EMAIL     "admin@local.dev"
add_if_missing ADMIN_PASSWORD "Aa!$(openssl rand -hex 16)"
add_if_missing WEBUI_SECRET_KEY  "$(openssl rand -hex 32)"
add_if_missing OPENWEBUI_LITELLM_KEY "sk-$(openssl rand -hex 24)"

DETACH="-d"
case "${1:-}" in
  -f|--foreground|--attached) DETACH="" ;;
  -d|--detach|"")             DETACH="-d" ;;
  *) echo "Usage: $0 [-d|--detach] [-f|--foreground]" >&2; exit 1 ;;
esac

docker compose --env-file .env -f ../compose/docker-compose.yml up $DETACH
