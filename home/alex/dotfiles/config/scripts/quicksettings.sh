#!/usr/bin/env bash

choice=$(printf "Displays\nNetwork\nAudio\nLogout\n" | wofi --dmenu --prompt "Quick Settings")

case "$choice" in
    Displays) wdisplays ;;
    Network) nm-connection-editor ;;
    Audio) pavucontrol ;;
    Logout) wlogout ;;
esac
