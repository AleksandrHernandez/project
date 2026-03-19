#!/bin/sh

export XDG_CURRENT_DESKTOP=wlroots
export XDG_SESSION_TYPE=wayland

slstatus -s | exec dbus-run-session dwl -s "swaybg -i $HOME/.wallpapers/wallpaper.jpeg &"
