#!/usr/bin/env bash

DIR=$HOME/Desktop/wallpapers
PICS=($(ls ${DIR}))

# Select a random wallpaper
RANDOMPICS=${PICS[$RANDOM % ${#PICS[@]}]}

# Notify the user about the wallpaper change
dunstify "⬅️Changed" -a "Wallpaper" -u "low" -i ${DIR}/${RANDOMPICS} -r "1234"

# Preload the selected wallpaper and set it as the wallpaper
hyprctl hyprpaper preload "${DIR}/${RANDOMPICS}"
hyprctl hyprpaper wallpaper ",${DIR}/${RANDOMPICS}"

# Play a notification sound
canberra-gtk-play -i window-attention

