# cheatsheet > debian-apt

## Refresh metadata and upgrade all system packages
```sudo apt update && sudo apt upgrade -y && sudo apt autoremove --purge```

## Install a new package
```sudo apt install -y <package>```

## Remove a package and remove its config
```sudo apt purge -y <package> && sudo apt autoremove --purge```

## Search for a package in the repository
```apt search <package>```

## View detailed information of an app or package
```apt show <package>```

## View list of all currently installed apps
```apt list --installed```

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

## system install age
```
# via root creation date (Universal on modern filesystems: EXT4, Btrfs, XFS)
stat / | grep "Birth"

# via $HOME creation date (Universal, check specific user creation)
stat $HOME | grep "Birth"

# via logrotate status (Universal across distros)
sudo head -n 5 /var/lib/logrotate/status

# via syslog (Debian family only)
head -n 5 /var/log/installer/syslog 2>/dev/null

# via filesystem metadata (Only for EXT2/3/4 family)
sudo tune2fs -l $(findmnt -no SOURCE /) | grep "Filesystem created"
```

## apt install history log location
```
/var/log/apt/history.log
```

## apt install history log
```
# Up to 12 months (Depends on logrotate, searches active + compressed logs)
zgrep "Commandline: apt" /var/log/apt/history.log*

# Dpkg deployment log (Usually limited to around 12 weeks/rotations)
grep " install " /var/log/dpkg.log

# Current month only (Active log)
cat /var/log/apt/history.log
grep "install " /var/log/apt/history.log

# Limited by terminal command lines count ($HISTSIZE), not by time duration
history | grep "apt install"
```

## Check is any depends on
```
apt-cache rdepends --installed libunicode-linebreak-perl
apt purge --simulate libunicode-linebreak-perl && apt autoremove --purge --simulate
apt remove libunicode-linebreak-perl --simulate
```
