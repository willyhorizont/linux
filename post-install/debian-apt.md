# post-install > debian-apt

## A

1. change closest fastest mirror ```https://www.debian.org/mirror/list```
```
/etc/apt/sources.list
```

2. Refresh metadata and upgrade all system packages
```
sudo apt update -y && sudo apt upgrade -y
```

3. Install Github
```
sudo apt install git -y
git config --global init.defaultBranch main
```

3. Github login
```
sudo apt install gh -y
gh auth login
```

## Cool CLI apps

### startup:
* fastfetch
* figlet

### code editor:
* https://getfresh.dev/ or https://github.com/sinelaw/fresh

### task manager:
* btop

### screensaver
```sudo apt install xscreensaver xscreensaver-gl-extra xscreensaver-data-extra -y```
* https://github.com/cmatsuoka/asciiquarium/blob/master/asciiquarium
* cmatrix
* hollywood
* pipes-sh
* cbonsai
