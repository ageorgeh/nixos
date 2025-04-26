#!/usr/bin/env bash

# launch everything
# code --ozone-platform=x11 &
# firefox-devedition &
# firefox &
# thunar &
# keepassxc &
# tidal-hifi &

# give windows time to spawn 
# sleep 2

# hyprctl clients


hyprctl dispatch focusmonitor 1

hyprctl dispatch hy3:changegroup untab
hyprctl dispatch hy3:movefocus r, visible, nowrap

hyprctl dispatch hy3:changegroup untab
hyprctl dispatch hy3:movefocus r, visible, nowrap

hyprctl dispatch hy3:changegroup untab
hyprctl dispatch hy3:movefocus r, visible, nowrap

# # Put them in the correct order
# hyprctl dispatch togglefloating class:^firefox-devedition$
# hyprctl dispatch togglefloating class:^firefox$
# hyprctl dispatch togglefloating class:^kitty$
# hyprctl dispatch togglefloating class:^thunar$


# hyprctl dispatch togglefloating class:^firefox-devedition$
# hyprctl dispatch togglefloating class:^firefox$

# hyprctl dispatch togglefloating class:^kitty$
# hyprctl dispatch focuswindow class:^kitty$
# hyprctl dispatch hy3:makegroup tab, toggle

# hyprctl dispatch togglefloating class:^thunar$

# hyprctl dispatch focuswindow class:^Code$


# # Get the sizing correct
# hyprctl dispatch resizewindowpixel exact 80% 100%, class:^firefox-devedition$
# hyprctl dispatch resizewindowpixel exact 60% 100%, class:^firefox$



