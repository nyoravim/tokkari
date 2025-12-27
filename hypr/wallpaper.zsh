#!/usr/bin/env zsh

hyprctl hyprpaper unload all > /dev/null

SCRIPT_DIR=$(realpath $(dirname $0))
WALLPAPERS=($(ls -d $SCRIPT_DIR/wallpapers/*.png))
(( WALLPAPER_INDEX = ($RANDOM % ${#WALLPAPERS[@]}) + 1 ))

CURRENT_WALLPAPER=${WALLPAPERS[$WALLPAPER_INDEX]}
echo "Setting wallpaper: $CURRENT_WALLPAPER"

hyprctl hyprpaper preload $CURRENT_WALLPAPER > /dev/null
hyprctl hyprpaper wallpaper ,$CURRENT_WALLPAPER > /dev/null
