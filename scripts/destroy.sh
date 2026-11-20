#!/bin/bash


docker compose --env-file .env -f ../compose/docker-compose.yml down -v
if [ -f .env ]; then
  rm -f .env
fi
