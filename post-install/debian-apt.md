# post-install > debian-apt

## A

1. Change password
```
sudo -i
passwd
exit
passwd "$USER"
exit
```

2. change closest faster mirror
```
/etc/apt/sources.list
```

3. Refresh metadata and upgrade all system packages
```
sudo apt update && sudo apt upgrade
```

4. Github login
```
sudo apt install gh git
git config --global init.defaultBranch main
gh auth login
```

## B

1. Install Cursor theme
```
sudo apt install dmz-cursor-theme -y
sudo apt install breeze-cursor-theme -y
```

2. Install Icon theme
```
sudo apt install papirus-icon-theme
```

3. Install Widget Style theme
```
sudo apt install yaru-theme-gtk
```

4. Install Window Border theme
```
sudo apt install greybird-gtk-theme -y
```
