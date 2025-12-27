#!/usr/bin/env zsh

if ! command -v pacman; then
    echo "not on arch; skill issue" >&2
    exit 1
fi

if ! pacman -Q cava; then
    echo "installing cava; may prompt for password"
    sudo pacman -Sy cava
fi

cava
