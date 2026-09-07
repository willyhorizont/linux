# cheatsheet > debian-apt

## Refresh metadata and upgrade all system packages
```sudo apt update && sudo apt upgrade```

## Install a new package
```sudo apt install <package>```

## Remove a package and remove its config
```sudo apt purge <package> && sudo apt autoremove```

## Remove a package and keeping its config
```sudo apt remove <package> && sudo apt autoremove```

## Remove orphaned or unused dependencies
```sudo apt autoremove```

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
