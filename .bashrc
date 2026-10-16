alias upgrayedd='sudo apt update && sudo apt upgrade -y && sudo apt autoremove --purge'
purgex() {
    if [ -z "$1" ]; then
        echo "Format: purgex [-s|--simulate] <package1> [package2 ...]  or  purgex <package1> [package2 ...]"
        return 1
    fi

    case "$1" in
        -s|--simulate)
            if [ -z "$2" ]; then
                echo "Error: Invalid arguments!"
                echo "Format: purgex [-s|--simulate] <package1> [package2 ...]"
                return 1
            fi
            shift
            apt purge --simulate "$@" && apt autoremove --purge --simulate
            for pkg in "$@"; do
                echo "[ $pkg ]"
                apt-cache rdepends --installed "$pkg"
            done
            ;;
        *)
            sudo apt purge -y "$@" && sudo apt autoremove --purge
            ;;
    esac
}
