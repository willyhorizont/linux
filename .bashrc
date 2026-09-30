fastfetch
alias upgrayedd='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y --purge'
purgex() {
    if [ -z "$1" ]; then
        echo "Format: purgex <package>"
        return 1
    fi
    sudo apt purge -y "$1" && sudo apt autoremove -y --purge
}
