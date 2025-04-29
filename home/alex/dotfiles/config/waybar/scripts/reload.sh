#!/usr/bin/env bash
# filepath: /home/alex/nixos-config/home/alex/dotfiles/config/waybar/scripts/reload.sh
CSS_FILE="$HOME/.config/waybar/style.css"
CONFIG_FILE="$HOME/.config/waybar/config"

# Run this for dev
ln -sf /home/alex/nixos-config/home/alex/dotfiles/config/waybar/style.css ~/.config/waybar/style.css
ln -sf /home/alex/nixos-config/home/alex/dotfiles/config/waybar/config ~/.config/waybar/config

# Ensure inotifywait is installed
if ! command -v inotifywait &>/dev/null; then
  echo "❌ inotifywait (from inotify-tools) is not installed."
  exit 1
fi

echo "👀 Watching $CSS_FILE and $CONFIG_FILE for changes..."

# Infinite loop to watch for changes in either CSS or config file
while inotifywait -e close_write "$CSS_FILE" "$CONFIG_FILE"; do
  PID=$(pidof waybar)
  if [ -n "$PID" ]; then
    kill -SIGUSR2 "$PID"
    echo "🔁 Waybar CSS/Config reloaded!"
  else
    echo "❌ Waybar is not running."
  fi
done