#!/bin/sh
set -e

echo "[1/5] Останавливаю процессы KeenSnap..."
pkill -f "/opt/root/KeenSnap/keensnap" 2>/dev/null || true
pkill -x keensnap 2>/dev/null || true

echo "[2/5] Удаляю файлы KeenSnap..."
rm -f /opt/bin/keensnap
rm -f /opt/etc/ndm/schedule.d/99-keensnap.sh
rm -rf /opt/root/KeenSnap

echo "[3/5] Удаляю логи и временные файлы..."
rm -f /opt/var/log/keensnap.log
rm -f /tmp/keensnap.sh /tmp/keensnap-init /tmp/install.sh

echo "[4/5] Проверяю удаление..."
if command -v keensnap >/dev/null 2>&1; then
  echo "WARN: keensnap еще в PATH"
else
  echo "OK: keensnap удален из PATH"
fi

if [ -e /opt/root/KeenSnap ]; then
  echo "WARN: /opt/root/KeenSnap осталась"
else
  echo "OK: /opt/root/KeenSnap удалена"
fi

if [ -e /opt/etc/ndm/schedule.d/99-keensnap.sh ]; then
  echo "WARN: /opt/etc/ndm/schedule.d/99-keensnap.sh остался"
else
  echo "OK: schedule-хук удален"
fi

echo "[5/5] Готово."
exit 0
