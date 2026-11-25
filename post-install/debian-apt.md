# post-install > debian-apt

## A

1. change closest fastest mirror ```https://www.debian.org/mirror/list```
```
/etc/apt/sources.list
```

2. Refresh metadata and upgrade all system packages
```
sudo apt update && sudo apt upgrade -y && sudo apt autoremove --purge
```

3. Install Github
```
sudo apt install -y --no-install-recommends git
git config --global init.defaultBranch main
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

3. Github login
```
sudo apt install -y --no-install-recommends gh
gh auth login
```
