#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_PATH="$DIR/.env"
SCRIPT_PATH="$DIR/start_command.sh"

# Создаем файл .env с дефолтными значениями, если он не существует
if [ ! -f "$ENV_PATH" ]; then
    echo "Файл .env не найден. Создаю .env с дефолтными значениями..."
    cat <<EOF > "$ENV_PATH"
USERNAME=nobody
PORT_LISTEN=8888
PORT=443
SECRET=`head -c 16 /dev/urandom | xxd -ps`
TAG=`head -c 16 /dev/urandom | xxd -ps`
# Если процессор позволяет можно ставить больше 0
WORKERCOUNT=0
EOF
    echo "Файл .env создан!"
fi

chmod 766 "$SCRIPT_PATH"

echo "Запускаем инициализацию контейнера..."
if ./start_command.sh; then
    echo "Контейнер успешно инициализирован и запущен."
else
    echo "Произошла ошибка при сборке или запуске контейнера. Скрипт остановлен."
    exit 1
fi

# Проверяем, добавлена ли уже задача
if crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH"; then
    echo "Задача уже установлена в cron!"
else
    # Добавляем задачу: Запускать раз в сутки (каждую ночь в 04:00)
    # Вывод логов от cron скрипта будет писаться в ту же папку в файл cron.log
    (crontab -l 2>/dev/null; echo "0 4 * * * $SCRIPT_PATH >> $DIR/cron.log 2>&1") | crontab -
    echo "Задача успешно добавлена в cron! Скрипт ($SCRIPT_PATH) будет выполняться каждый день в 04:00."
fi
