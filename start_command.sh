#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR" || exit 1

# Прописываем PATH, в пустом окружении cron команда docker может быть не найдена
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

docker rm -f mtproxy 2>/dev/null

docker rmi mtproto:latest 2>/dev/null

docker build --pull --rm -f .Dockerfile -t mtproto:latest . && \
docker run -d --name mtproxy --env-file .env -p 443:443 -p 8888:8888 mtproto:latest
STATUS=$?

docker image prune -f

exit $STATUS