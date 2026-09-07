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
