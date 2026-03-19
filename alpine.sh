#!/bin/sh

doas setup-devd udev

doas apk add make wayland font-terminus gcc libinput wlroots libxkbcommon wayland-protocols pkgconf foot wmenu seatd htop mesa-dri-gallium linux-firmware kakoune kakoune-lsp swaybg font-fira-code-nerd
doas apk add -t .dev wayland-dev libinput-dev wlroots-dev libxkbcommon-dev pkgconf-dev musl-dev patch fcft-dev

cp -r ./.profile $HOME/.profile
mkdir -p $HOME/.config

doas addgroup $USER seat
doas rc-update add seatd
doas rc-service seatd start

cd dwl
make
doas make clean install
cd ..
cp -r dwl $HOME/.config/

mkdir -p $HOME/.wallpapers
cp -r wallpaper.jpeg $HOME/.wallpapers/
mkdir -p $HOME/.config/foot
cp -r foot.ini $HOME/.config/foot/

if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
	doas apk add tlp tlp-rdw ethtool smartmontools powertop
	doas rc-update add tlp
	doas rc-service tlp start
	doas cp -r ./tlp/tlp.conf /etc/tlp.conf
	doas cp -r ./tlp/sysctl.conf /etc/sysctl.conf
	doas cp -r ./tlp/99-pci-power.rules /etc/udev/rules.d/99-pci-power.rules
	doas cp -r ./tlp/99-slstatus-battery.rules /etc/udev/rules.d/99-slstatus-battery.rules
	doas cp -r slstatus-battery /usr/local/bin/slstatus-battery
else
	cp -r config.def.h slstatus/config.def.h
fi

cd slstatus
make
doas make clean install
cd ..
cp -r slstatus $HOME/.config/

doas apk add dbus
doas rc-update add dbus
doas rc-service dbus start

doas apk add alsa-utils pipewire wireplumber pipewire-pulse pipewire-alsa xdg-desktop-portal-wlr
rc-update -U add pipewire gui
rc-update -U add wireplumber gui
rc-update -U add pipewire-pulse gui
rc-service -U pipewire start
rc-service -U wireplumber start
rc-service -U pipewire-pulse start

doas apk add zram-init
doas cp -r ./zram/zram-init /etc/conf.d/zram-init
doas cp -r ./zram/99-zram.conf /etc/sysctl.d/99-zram.conf
doas rc-update add zram-init
doas rc-service zram-init start
