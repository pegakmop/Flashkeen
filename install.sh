#!/bin/sh
set -e

OPKG_BIN="$(command -v opkg || true)"
if [ -z "$OPKG_BIN" ]; then
  echo "opkg не найден. Запустите установку в среде Entware."
  exit 1
fi

# Ставим curl только если его нет
if ! command -v curl >/dev/null 2>&1; then
  "$OPKG_BIN" update || true
  "$OPKG_BIN" install curl || {
    echo "Не удалось установить curl."
    exit 1
  }
fi

mkdir -p /opt/bin

REPO="miha75vu-bit/Flashkeen"
LATEST_API_URL="https://api.github.com/repos/$REPO/releases/latest"
RELEASES_API_URL="https://api.github.com/repos/$REPO/releases?per_page=10"
DEFAULT_ASSET_URL="https://github.com/$REPO/releases/latest/download/flashkeen"

chosen_url="$DEFAULT_ASSET_URL"
chosen_label="latest release"

echo "Проверяю последнюю версию Flashkeen..."
latest_json="$(curl -fsL --connect-timeout 2 --max-time 8 "$LATEST_API_URL" 2>/dev/null || true)"
latest_tag="$(printf "%s\n" "$latest_json" | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | awk 'NR==1{print; exit}')"
latest_name="$(printf "%s\n" "$latest_json" | sed -n 's/.*"name":[[:space:]]*"\([^"]*\)".*/\1/p' | awk 'NR==1{print; exit}')"
[ -n "$latest_name" ] || latest_name="$latest_tag"

latest_lc="$(printf "%s %s" "$latest_tag" "$latest_name" | tr '[:upper:]' '[:lower:]')"
case "$latest_lc" in
  *test*)
    prev_tag=""
    prev_name=""
    rel_json="$(curl -fsL --connect-timeout 2 --max-time 8 "$RELEASES_API_URL" 2>/dev/null || true)"
    if [ -n "$rel_json" ]; then
      prev_line="$(printf "%s" "$rel_json" | tr '\n' ' ' | sed 's/},{/\
/g' | awk '
        {
          tag=""; name="";
          if (match($0, /"tag_name"[[:space:]]*:[[:space:]]*"[^"]+"/)) {
            tag=substr($0, RSTART, RLENGTH);
            sub(/^.*"/,"",tag); sub(/"$/,"",tag);
          }
          if (match($0, /"name"[[:space:]]*:[[:space:]]*"[^"]+"/)) {
            name=substr($0, RSTART, RLENGTH);
            sub(/^.*"/,"",name); sub(/"$/,"",name);
          }
          lc=tolower(tag " " name);
          if (tag != "" && index(lc, "test") == 0) {
            print tag "|" name;
            exit
          }
        }')"
      prev_tag="$(printf "%s" "$prev_line" | awk -F'|' '{print $1}')"
      prev_name="$(printf "%s" "$prev_line" | awk -F'|' '{print $2}')"
      [ -n "$prev_name" ] || prev_name="$prev_tag"
    fi

    if [ -n "$prev_tag" ] && [ -t 0 ]; then
      echo
      echo "Найдена тестовая сборка в latest:"
      echo "1) Установить test: $latest_name"
      echo "2) Установить предыдущую стабильную: $prev_name"
      echo "0) Отмена"
      echo -n "Ваш выбор (по умолчанию 2): "
      read ans
      [ "$ans" = "00" ] && exit 0
      [ -z "$ans" ] && ans="2"
      case "$ans" in
        1)
          chosen_url="https://github.com/$REPO/releases/download/$latest_tag/flashkeen"
          chosen_label="$latest_name"
          ;;
        0)
          echo "Установка отменена."
          exit 0
          ;;
        *)
          chosen_url="https://github.com/$REPO/releases/download/$prev_tag/flashkeen"
          chosen_label="$prev_name"
          ;;
      esac
    else
      # Если нет интерактива или не нашли предыдущую — ставим latest как раньше.
      chosen_url="$DEFAULT_ASSET_URL"
      chosen_label="$latest_name"
    fi
    ;;
  *)
    [ -n "$latest_tag" ] && chosen_label="$latest_name"
    ;;
esac

echo "Скачиваю Flashkeen: $chosen_label"
curl -fL -s "$chosen_url" -o /opt/bin/flashkeen

chmod +x /opt/bin/flashkeen

# Алиасы для удобного запуска
ln -sf /opt/bin/flashkeen /opt/bin/Flashkeen
ln -sf /opt/bin/flashkeen /opt/bin/flash

echo "Flashkeen установлен."
echo "Запуск: flashkeen  или  Flashkeen  или  flash"
