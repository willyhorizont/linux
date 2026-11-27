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
xdotool search --onlyvisible --class ".*" | while read id; do name=$(xdotool getwindowname $id 2>/dev/null); [ -n "$name" ] && echo "$id ; $name"; done
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
```sh
wmctrl -d # not consistent in all wms
xprop -root _NET_DESKTOP_NAMES
WS_NMS=$(xprop -root _NET_DESKTOP_NAMES 2>/dev/null | awk -F'"' '{for(i=2; i<=NF; i+=2) {gsub(/[^0-9]/, "", $i); print ($i != "" ? $i : "404")}}')
CUR_WS_I=$(xdotool get_desktop 2>/dev/null)
CUR_WS_NM=$(echo "$WS_NMS" | awk -v ws_i="$CUR_WS_I" 'NR == ws_i + 1 {print $0}')
# _NET_DESKTOP_NAMES(UTF8_STRING) = "Web1 - Desktop 1", "Web2 - Desktop 2", "File Manager - Desktop 3", "TextEditor1 - Desktop 4", "TextEditor2 - Desktop 5"
# WS_NMS 11 22 3 14 25
```

### List all pid program command
```
ps -eo pid,comm,args ww >> "$HOME/Codes/linux-debian-lxde/dev/cmd-out-$(date +%Y-%m-%d-%H%M%S-%3N).txt"
pgrep -af "." >> "$HOME/Codes/linux-debian-lxde/dev/cmd-out-$(date +%Y-%m-%d-%H%M%S-%3N).txt"
pstree -ap >> "$HOME/Codes/linux-debian-lxde/dev/cmd-out-$(date +%Y-%m-%d-%H%M%S-%3N).txt"
procs --only pid,name,command >> "$HOME/Codes/linux-debian-lxde/dev/cmd-out-$(date +%Y-%m-%d-%H%M%S-%3N).txt"
```

### Get pid from window id (_NET_WM_PID)
```sh
PID=$(xdotool getwindowpid "$WID" 2>/dev/null)
PID=$(xprop -id "$WID" _NET_WM_PID 2>/dev/null | awk '{print $3}')
PID=$(wmctrl -l -x -p -G | awk -v wid="$WID" '$1 == wid {print $3}')
```

### Kill by pid
```sh
# Graceful Terminate (SIGTERM)
[ -n "$PID" ] && [ "$PID" -gt 0 ] && kill -15 "$PID"

# Hard Kill (SIGKILL)
[ -n "$PID" ] && [ "$PID" -gt 0 ] && kill -9 "$PID"
```

### Kill by window id
```sh
# Graceful Close (EWMH _NET_CLOSE_WINDOW)
wmctrl -i -c "$WID"
xdotool windowclose "$WID"
i3-msg "[id=$WID] kill"

# Hard Kill (X11 XKillClient)
xdotool windowkill "$WID"
xkill -id "$WID"
```
