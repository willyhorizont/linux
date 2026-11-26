#!/bin/bash

CMD_CLICK=""
FREE_TXT=""
TOOLTIP_TXT=""

declare -A ALL_MODES
ALL_MODES=(
    ["tint2"]="tint2"
    ["xfce4-panel"]="xfce4-panel"
)

MODE="${ALL_MODES["tint2"]}"

PREF=""
SUFF=""
VAL_BG="#000000"
VAL_FG="#FF1493"
USE_PANGO=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --txt) FREE_TXT="$2";             shift 2 ;;
        --mode)
            if [[ -n "$2" && -n "${ALL_MODES["$2"]}" ]]; then
                MODE="${ALL_MODES["$2"]}"
            fi
            shift 2
            ;;
        --pref)        PREF="$2";          shift 2 ;;
        --suff)        SUFF="$2";          shift 2 ;;
        --val-bg)      VAL_BG="$2";        shift 2 ;;
        --val-fg)      VAL_FG="$2";        shift 2 ;;
        --pango)       USE_PANGO=true;     shift ;;
        *)                                 shift ;;
    esac
done

if $USE_PANGO; then
    out_txt="${out_txt}<span background='#000000' foreground='#00ADD8'>${PREF}</span>"
    out_txt="${out_txt}<span background='$VAL_BG' foreground='$VAL_FG'>${FREE_TXT}</span>"
    out_txt="${out_txt}<span background='#000000' foreground='#00ADD8'>${SUFF}</span>"
else
    out_txt="${out_txt}${PREF}"
    out_txt="${out_txt}${FREE_TXT}"
    out_txt="${out_txt}${SUFF}"
fi

if [ "$MODE" = "${ALL_MODES["xfce4-panel"]}" ]; then
    echo "<txt>${out_txt}</txt>"
    echo "<txtclick>$CMD_CLICK</txtclick>"
    echo "<tool>$TOOLTIP_TXT</tool>"
else
    echo "${out_txt}"
    printf "\e[2J%s\n" "$TOOLTIP_TXT" 1>&2
fi
