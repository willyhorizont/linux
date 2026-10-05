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
