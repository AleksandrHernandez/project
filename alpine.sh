#!/bin/sh
doas setup-devd udev

doas apk add make wayland font-terminus gcc libinput wlroots libxkbcommon wayland-protocols pkgconf foot wmenu seatd htop mesa-dri-gallium linux-firmware kakoune kakoune-lsp
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
mv -i dwl $HOME/.config/

mkdir -p $HOME/.config/foot
cp -r /etc/xdg/foot/foot.ini $HOME/.config/foot/

if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
	doas apk add tlp tlp-rdw ethtool smartmontools powertop
	doas rc-update add tlp
	doas rc-service tlp start
	doas cp -r ./tlp/tlp.conf /etc/tlp.conf
	doas cp -r ./tlp/sysctl.conf /etc/sysctl.conf
	doas cp -r ./tlp/99-pci-power.rules /etc/udev/rules.d/99-pci-power.rules
	doas cp -r ./tlp/99-slstatus-battery.rules /etc/udev/rules.d/99-slstatus-battery.rules
	doas cp -r slstatus-battery /usr/local/bin/slstatus-battery
fi

cd slstatus
make
doas make clean install
cd ..
mv -i slstatus $HOME/.config/
