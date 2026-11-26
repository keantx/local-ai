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
# add_if_missing SECOND_BRAIN_PATH "/mnt/c/Users/sample-user/example2/Documents/second-brain" #adjust to your obsidian vault

for k in OPENROUTER_API_KEY CONTEXT7_API_KEY PLACEHOLDER2_API_KEY; do # if u want, add the variable to compose to so litellm config can see it
  add_if_missing "$k" ""
  if [ -z "$(grep "^$k=" .env | cut -d= -f2-)" ]; then
    echo "Note: $k is empty in .env" >&2
  fi
done

usage() {
  echo "Usage: $0 [-d|--detach] [-f|--foreground] [-r|--recreate]" >&2
  echo "  default: foreground; -r force-recreates the litellm container" >&2
}

DETACH=""
RECREATE=0
while [ $# -gt 0 ]; do
  case "$1" in
    -d|--detach)                DETACH="-d" ;;
    -f|--foreground|--attached) DETACH="" ;;
    -r|--recreate)              RECREATE=1 ;;
    -h|--help)                  usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
  shift
done

ARGS=(up)
[ -n "$DETACH" ] && ARGS+=("$DETACH")
[ "$RECREATE" -eq 1 ] && ARGS+=(--force-recreate litellm open-webui)

docker compose --env-file .env -f ../compose/docker-compose.yml "${ARGS[@]}"
