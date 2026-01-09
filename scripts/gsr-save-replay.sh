#!/usr/bin/env bash
set -eu

dir="$HOME/Видео/gsr"
mkdir -p "$dir"

before="$(ls -t "$dir" 2>/dev/null | head -n1 || true)"

# Найдём PID(ы) gsr по полной командной строке и пошлём SIGUSR1
pids="$(pgrep -f '^gpu-screen-recorder(\s|$)' || true)"
if [ -z "$pids" ]; then
  export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
  notify-send -u critical "gpu-screen-recorder" "Не запущен (replay не активен)"
  exit 1
fi
kill -USR1 $pids

# Ждём появления НОВОГО файла (до ~3 сек)
after=""
for _ in $(seq 1 30); do
  sleep 0.1
  after="$(ls -t "$dir" 2>/dev/null | head -n1 || true)"
  if [ -n "$after" ] && [ "$after" != "$before" ]; then
    break
  fi
done

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
if [ -n "$after" ] && [ "$after" != "$before" ]; then
  notify-send "Replay saved" "$dir/$after"
else
  notify-send -u critical "Replay save failed" "Файл не появился в $dir"
fi
