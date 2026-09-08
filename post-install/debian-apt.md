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

3. Github login
```
sudo apt install gh git -y
git config --global init.defaultBranch main
gh auth login
```
