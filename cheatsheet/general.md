# cheatsheet > general

## Find distro icon
```
find /usr/share/icons/ -name "*<distro>*"
find /usr/share/icons/ -name "*distributor-logo-<distro>*"
```

### List any qt installed
```
dpkg -l | grep -i qt
```

### Get window class
```
xprop WM_CLASS
```

### Get window name
```
xdotool search --onlyvisible --name ".*" | while read id; do name=$(xdotool getwindowname $id 2>/dev/null); [ -n "$name" ] && echo "$id ; $name"; done
```

### Check is installed
```
dpkg -l diodon copyq parcellite rofi-greenclip clipster xclip xsel 2>/dev/null
```

### Save installed to list
```
dpkg -l > "$HOME/willyhorizont.github.io/dpkg-l.txt"
```

### Detect key symbol
```
xev | grep keysym
```

### Get Window Dimension
```
xwininfo | grep -E "Width|Height"
```

### Check if something is installed
```
dpkg -l | grep -i something
which something
```

### See command history
```
history
```

### Disable GRUB_TIMEOUT
```
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub && sudo update-grub
```

### List all categories
```
grep "Categories=" /usr/share/applications/*.desktop
```

### List all workspaces
```
wmctrl -d
xprop -root _NET_DESKTOP_NAMES
```
