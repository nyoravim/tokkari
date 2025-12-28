#!/usr/bin/env zsh

sleep 2

hyprctl hyprpaper unload all

SCRIPT_DIR=$(realpath $(dirname $0))
WALLPAPERS=($(ls -d $SCRIPT_DIR/wallpapers/*.png))
(( WALLPAPER_INDEX = ($RANDOM % ${#WALLPAPERS[@]}) + 1 ))

CURRENT_WALLPAPER=${WALLPAPERS[$WALLPAPER_INDEX]}
echo "Setting wallpaper: $CURRENT_WALLPAPER"

hyprctl hyprpaper preload $CURRENT_WALLPAPER
hyprctl hyprpaper wallpaper ,$CURRENT_WALLPAPER
