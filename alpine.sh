#!/bin/sh

doas setup-devd udev

doas apk add -u make wayland font-terminus gcc libinput wlroots libxkbcommon wayland-protocols pkgconf foot wmenu seatd htop mesa-dri-gallium linux-firmware kakoune kakoune-lsp swaybg font-fira-mono-nerd
doas apk add -t .dev wayland-dev libinput-dev wlroots-dev libxkbcommon-dev pkgconf-dev musl-dev patch fcft-dev

cp -r ./config/.profile $HOME/.profile
mkdir -p $HOME/.config/rc/runlevels/gui

doas addgroup $USER seat
doas rc-update add seatd
doas rc-service seatd start

cd ./config/dwl
make
doas make clean install
cd -
cp -r ./config/dwl $HOME/.config/

cp -r ./config/.wallpaper $HOME/
cp -r ./config/foot $HOME/.config/

if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
	doas apk add tlp tlp-rdw ethtool smartmontools powertop
	doas rc-update add tlp
	doas rc-service tlp start
	doas cp -r ./config/tlp/tlp.conf /etc/tlp.conf
	doas cp -r ./config/tlp/sysctl.conf /etc/sysctl.conf
	doas cp -r ./config/tlp/99-pci-power.rules /etc/udev/rules.d/99-pci-power.rules
	doas cp -r ./config/tlp/99-slstatus-battery.rules /etc/udev/rules.d/99-slstatus-battery.rules
	sed -i "s/USER=\"user\"/USER=\"$USER\"/" ./config/slstatus/slstatus-battery
	doas cp -r ./config/tlp/slstatus-battery /usr/local/bin/slstatus-battery
	cp -r ./config/slstatus/bat/config.def.h ./config/slstatus/slstatus/config.def.h
else
	cp -r ./config/slstatus/nobat/config.def.h ./config/slstatus/slstatus/config.def.h
fi

cd ./config/slstatus/slstatus
make
doas make clean install
cd -
cp -r ./config/slstatus/slstatus $HOME/.config/

doas apk add dbus
doas rc-update add dbus
doas rc-service dbus start

doas apk add alsa-utils pipewire wireplumber pipewire-pulse pipewire-alsa xdg-desktop-portal-wlr rtkit
sleep 1
rc-update -U add pipewire gui
rc-update -U add wireplumber gui
rc-update -U add pipewire-pulse gui
rc-service -U pipewire start
rc-service -U wireplumber start
rc-service -U pipewire-pulse start

doas apk add zram-init
doas cp -r ./config/zram/zram-init /etc/conf.d/zram-init
doas cp -r ./config/zram/99-zram.conf /etc/sysctl.d/99-zram.conf
doas rc-update add zram-init
doas rc-service zram-init start

doas apk add nftables
doas cp -r ./config/nftables/nftables.nft /etc/nftables.nft
doas rc-service nftables start
doas rc-update add nftables boot

doas apk add agetty
doas sed -i "s|tty1::respawn:/sbin/getty 38400 tty1|tty1::respawn:/sbin/agetty --autologin $USER tty1 linux|" /etc/inittab
doas sed -i "s|ttyS0::respawn:/sbin/getty -L 0 ttyS0 vt100|ttyS0::respawn:/sbin/agetty --autologin $USER ttyS0 vt100|" /etc/inittab

doas cp -r ./config/doas/99-power.conf /etc/doas.d/99-power.conf
doas doas -C /etc/doas.conf
