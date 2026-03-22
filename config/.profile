# Creating XDG_RUNTIME_DIR
if [ -z "$XDG_RUNTIME_DIR" ]; then
	XDG_RUNTIME_DIR="/tmp/$(id -u)-runtime-dir"

	mkdir -pm 0700 "$XDG_RUNTIME_DIR"
	export XDG_RUNTIME_DIR
fi

# Starting dwl session
if [ "$(tty)" = "/dev/tty1" ]; then  
	export XDG_CURRENT_DESKTOP=wlroots
	export XDG_SESSION_TYPE=wayland
	slstatus -s | exec dbus-run-session dwl -s "swaybg -i $HOME/.wallpaper/wallpaper.jpeg &"
fi
