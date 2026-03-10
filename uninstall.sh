#!/bin/sh

echo "Удаляю Flashkeen из /opt/bin..."

rm -f /opt/bin/flashkeen \
      /opt/bin/Flashkeen \
      /opt/bin/flash \
      /opt/bin/flashkeen.sh \d
      /tmp/flashkeen-install.sh

echo "Готово. Если вызывали скрипт с флешки/шары — исходный файл там останется, удалите его вручную при необходимости."
