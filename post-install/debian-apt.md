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
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

3. Github login
```
sudo apt install gh -y
gh auth login
```

## Cool CLI apps
* https://github.com/agarrharr/awesome-cli-apps
* https://terminaltrove.com/
* https://www.reddit.com/r/linux/comments/1iy47hq/i_want_some_different_terminal_based_programs_to/
* https://www.linux.org/threads/what-are-your-top-command-line-apps.27649/

### startup:
* fastfetch
* figlet

### code editor:
* https://getfresh.dev/ or https://github.com/sinelaw/fresh

### task manager:
* btop
* https://github.com/clementtsang/bottom

### screensaver
```sudo apt install xscreensaver xscreensaver-gl-extra xscreensaver-data-extra -y```
* https://github.com/cmatsuoka/asciiquarium/blob/master/asciiquarium
* cmatrix
* hollywood
* pipes-sh
* cbonsai
