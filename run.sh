#!/bin/bash

PUBLIC_IP=$(curl -s --connect-timeout 2 ifconfig.me || echo "ВНЕШНИЙ_IP_АДРЕС")

INTERNAL_IP=$(hostname -i | awk '{print $1}')

echo "=================================================================="
echo "Ссылки для подключения к вашему MTProto Proxy:"
echo "👉 Обычное: tg://proxy?server=${PUBLIC_IP}&port=${PORT}&secret=${SECRET}"
echo "👉 Со скрытием (dd): tg://proxy?server=${PUBLIC_IP}&port=${PORT}&secret=dd${SECRET}"
echo "=================================================================="
echo "NAT Инфо: Внутренний IP ($INTERNAL_IP) проброшен на внешний ($PUBLIC_IP)"

# Скачиваем свежие конфигурации серверов Telegram (они периодически меняются)
echo "Downloading latest proxy-secret and proxy-multi.conf..."
curl -s https://core.telegram.org/getProxySecret -o proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf

set -x

./mtproto-proxy -u $USERNAME -p $PORT_LISTEN --http-stats -H $PORT -S $SECRET -P $TAG --nat-info $INTERNAL_IP:$PUBLIC_IP --aes-pwd proxy-secret proxy-multi.conf -M $WORKERCOUNT

set +x

echo "Running complete. Keeping container alive..."

tail -f /dev/null

