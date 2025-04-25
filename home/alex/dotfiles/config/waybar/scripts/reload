#!/usr/bin/env bash

CSS_FILE="$HOME/.config/waybar/style.css"

# Run this for dev
ln -sf /home/alex/nixos-config/home/alex/dotfiles/config/waybar/style.css ~/.config/waybar/style.css

# Ensure inotifywait is installed
if ! command -v inotifywait &>/dev/null; then
  echo "❌ inotifywait (from inotify-tools) is not installed."
  exit 1
fi

echo "👀 Watching $CSS_FILE for changes..."

# Infinite loop to watch for changes
while inotifywait -e close_write "$CSS_FILE"; do
  PID=$(pidof waybar)
  if [ -n "$PID" ]; then
    kill -SIGUSR2 "$PID"
    echo "🔁 Waybar CSS reloaded!"
  else
    echo "❌ Waybar is not running."
  fi
done
