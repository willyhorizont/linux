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
