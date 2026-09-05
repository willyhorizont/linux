#!/bin/bash

# =====================================================================
# Linux Mjnx
## Ultra Lightweight Debian Based Linux Distro for Older Hardware
# =====================================================================

su -c "
apt update && apt install --no-install-recommends -y \
    sudo \
    xserver-xorg-core \
    xserver-xorg \
    xinit \
    jwm \
    lightdm \
    gvfs-backends \
    iwd \
    firmware-iwlwifi \
    adwaita-icon-theme \
    hicolor-icon-theme \
    git \
    firefox-esr \
    mousepad \
    lxterminal \
    pcmanfm \
    lxpanel \
    bc \
    fonts-dejavu-core \
    fonts-liberation \
    lemonbar

/usr/sbin/usermod -aG sudo $USER
"

mkdir -p ~/.jwm

cp /etc/X11/jwm/system.jwmrc ~/.jwm/.jwmrc

sed -i 's/onroot="[0-9]"//g' ~/.jwm/.jwmrc

curl -L -o ~/.jwm/SPRM.sh https://willyhorizont.github.io/linux/SPRM.sh
chmod +x ~/.jwm/SPRM.sh

cat << 'EOF' > ~/.jwm/autostart.sh
#!/bin/bash
lxpanel &
~/.jwm/SPRM.sh | lemonbar -p -B "#C2066D" -F "#FFFFFF" -g x20+0+0 -f "fixed" &
EOF
chmod +x ~/.jwm/autostart.sh

sed -i '/<\/JWM>/i \    <Startup>\n        <Tray>off</Tray>\n        <Command>~/.jwm/autostart.sh</Command>\n    </Startup>' ~/.jwm/.jwmrc

echo "====================================================================="
echo " Linux Mjnx Installation Done!"
echo " Please reboot and run this command:"
echo "   sudo systemctl enable --now iwd"
echo "   iwctl"
echo "   device list"
echo "   station wlan0 scan"
echo "   station wlan0 get-networks"
echo "   station wlan0 connect 'Your Wifi Name'"
echo "   quit"
echo "====================================================================="
