### Fedora 44 KDE ➡️ Fedora 45 KDE
```
sudo dnf upgrade --refresh -y
sudo reboot
```
```
sudo dnf install dnf-plugin-system-upgrade -y
sudo dnf system-upgrade download --releasever=45 --allowerasing -y
sudo dnf system-upgrade reboot
```

### LMDE 7 Cinnamon ➡️ LMDE 8 Cinnamon
```
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y --no-install-recommends mintupgrade
sudo mintupgrade
```

### Debian 13 Xfce ➡️ Debian 14 Xfce
```
sudo apt update && sudo apt full-upgrade -y
sudo apt autoremove -y
TARGET="/etc/apt/sources.list"
sudo cp "$TARGET" "${TARGET}.bak" && sudo sed -i 's/trixie/forky/g' "$TARGET"
sudo apt update
sudo apt upgrade --without-new-pkgs -y
sudo apt full-upgrade -y
sudo reboot
```
