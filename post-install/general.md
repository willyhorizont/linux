# post-install > general

## A

1. Delete login.keyring
```
rm ~/.local/share/keyrings/login.keyring
```

2. ABDownloadManager Killer
```
echo -e "[Desktop Entry]\nVersion=1.0\nType=Application\nName=Exit ABDownloadManager\nComment=Kill ABDownloadManager Process\nExec=pkill -f ABDownloadManager\nIcon=process-stop\nCategories=Utility;\nTerminal=false\nStartupNotify=false" > ~/.local/share/applications/abdownloadmanager-killer.desktop
update-desktop-database ~/.local/share/applications && sudo update-desktop-database /usr/share/applications
```