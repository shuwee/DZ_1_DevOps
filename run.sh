#!/usr/bin/env bash
# Стенд домашнего задания № 1: приложение + PostgreSQL на именованном томе.
# Повторный запуск пересоздаёт контейнеры, том kondratov-01-data сохраняется.
PREFIX=kondratov-01

# 1. Удалить прежние контейнеры приложения и базы (том не трогаем)
docker rm -f ${PREFIX}-web ${PREFIX}-db 2>/dev/null || true

# 2. Собрать образ приложения версии 2.0
docker build --build-arg VERSION=2.0 -t $PREFIX/probe:2.0 .

# 3. Том для данных базы (если он уже есть, команда ничего не меняет)
docker volume create ${PREFIX}-data

# 4. База на именованном томе; порт 8005 на хосте -> 5432 в контейнере
docker run -d --name ${PREFIX}-db \
  -e POSTGRES_PASSWORD=lab -e POSTGRES_DB=lab \
  -p 8005:5432 \
  -v ${PREFIX}-data:/var/lib/postgresql/data \
  postgres:16-alpine

# 5. Приложение; порт 8003 на хосте -> 5001 в контейнере, база через хост
docker run -d --name ${PREFIX}-web \
  -p 8003:5001 \
  --add-host host.docker.internal:host-gateway \
  -e DATABASE_URL=postgresql://postgres:lab@host.docker.internal:8005/lab \
  $PREFIX/probe:2.0

# 6. Ждать готовности базы (до 60 секунд) и показать заметки
SECONDS=0
until curl -sf -m 3 localhost:8003/notes > /dev/null || [ $SECONDS -ge 60 ]; do sleep 2; done
curl -s localhost:8003/notes
