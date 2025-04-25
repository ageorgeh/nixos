#!/usr/bin/env bash

choice=$(printf "Displays\nNetwork\nAudio\nLogout\n" | wofi --dmenu --prompt "Quick Settings")
choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

case "$choice" in
  disp*) wdisplays ;;
  net*) nm-connection-editor ;;
  aud*) pavucontrol ;;
  log*) wlogout ;;
esac
