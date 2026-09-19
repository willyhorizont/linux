# cheatsheet > debian-apt

## Refresh metadata and upgrade all system packages
```sudo apt update -y && sudo apt upgrade -y```

## Install a new package
```sudo apt install -y <package>```

## Remove a package and remove its config
```sudo apt purge -y <package> && sudo apt autoremove -y --purge```

## Search for a package in the repository
```apt search <package>```

## View detailed information of an app or package
```apt show <package>```

## View list of all currently installed apps
```apt list --installed```

## View apt history.log
```cat /var/log/apt/history.log```

## Clean all local repository cache
```sudo apt clean```

## Update Desktop Applications database
```update-desktop-database ~/.local/share/applications && sudo update-desktop-database /usr/share/applications```

## Stop and completely disable background updater
```sudo systemctl stop packagekit && sudo systemctl mask packagekit```

## Find distro icon
```
find /usr/share/icons/ -name "*<distro>*"
find /usr/share/icons/ -name "*distributor-logo-<distro>*"
```

## Set max audio volume
```
pactl set-sink-volume @DEFAULT_SINK@ 100%
```
