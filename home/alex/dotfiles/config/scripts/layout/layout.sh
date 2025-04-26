#!/usr/bin/env bash

#  hyprctl clients

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Function to check if a process is running
is_running() {
  pgrep -f "$1" > /dev/null
  return $?
}


hyprctl dispatch focusmonitor 1

# Variable to track if anything was launched
new_launch=false

# Launch applications only if not already running
if ! is_running "code"; then
  code --ozone-platform=x11 &
  new_launch=true
fi

if ! is_running "firefox-devedition"; then
  firefox-devedition &
  new_launch=true
fi

if ! is_running "firefox"; then
  firefox &
  new_launch=true
fi

if ! is_running "thunar"; then
  thunar &
  new_launch=true
fi

if ! is_running "keepassxc"; then
  keepassxc &
  new_launch=true
fi

if ! is_running "tidal-hifi"; then
  tidal-hifi &
  new_launch=true
fi

# Give windows time to spawn only if something was launched
if $new_launch; then
  echo "New applications launched, waiting for them to spawn..."
  sleep 2
else
  echo "All applications already running, proceeding immediately."
fi


# Ungroup all windows on monitor 1
"$SCRIPT_DIR/allWindows.sh" 'hy3:changegroup untab' 1

# sleep 1

# Float them all
"$SCRIPT_DIR/allWindows.sh" --address 'togglefloating' 1

# sleep 1

# Unfloat them all in correct order
"$SCRIPT_DIR/allWindows.sh" --address --class-order "firefox-dev firefox thunar KeePassXC tidal-hifi" 'togglefloating' 1

# sleep 1

# Make the ending group
hyprctl dispatch focuswindow class:^thunar$
hyprctl dispatch hy3:makegroup tab, toggle

# sleep 1

# Move things into the group
"$SCRIPT_DIR/allWindows.sh" --after thunar 'hy3:movewindow l' 1

# sleep 1

# # Get the sizing correct
hyprctl dispatch focusmonitor 0 # This is required for some reason
hyprctl dispatch resizewindowpixel exact 80% 100%, class:^firefox-dev$
hyprctl dispatch resizewindowpixel exact 60% 100%, class:^firefox$

# Focus back on code
hyprctl dispatch focusmonitor 0



