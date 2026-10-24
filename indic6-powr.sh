#!/bin/bash

IC_INIT="⏳"
BAT_ON_HI="🔋"
BAT_ON_LO="🪫"
BAT_ON="🔋"
BAT_NONE="❌"
AC_ON="🔌"
AC_NONE="❌️"

HAS_BAT_HI=false
HAS_BAT_LO=false
HAS_BAT_ON=false

# FACTOR_FILE="/etc/sys_load_mult_factor.txt"
FACTOR_FILE="$HOME/willyhorizont.github.io/.config/sys_load_mult_factor.txt"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --ic-init)    IC_INIT="$2";    shift 2 ;;
        --bat-on-hi)  BAT_ON_HI="$2";  HAS_BAT_HI=true; shift 2 ;;
        --bat-on-lo)  BAT_ON_LO="$2";  HAS_BAT_LO=true; shift 2 ;;
        --bat-on)     BAT_ON="$2";     HAS_BAT_ON=true; shift 2 ;;
        --bat-none)   BAT_NONE="$2";   shift 2 ;;
        --ac-on)      AC_ON="$2";      shift 2 ;;
        --ac-none)     AC_NONE="$2";    shift 2 ;;
        *) shift ;;
    esac
done

TOOLTIP_TXT=$(cat << EOF
\`                                 
        💡 indic6-powr.sh          
                                   
    --ic-init    ; ${IC_INIT}      
    --bat-on-hi  ; ${BAT_ON_HI}    
    --bat-on-lo  ; ${BAT_ON_LO}    
    --bat-on     ; ${BAT_ON}       
    --bat-none   ; ${BAT_NONE}     
    --ac-on      ; ${AC_ON}        
    --ac-none    ; ${AC_NONE}      
                                   
      click to open tui6-powr.sh   
                                  .
EOF
)

get_kwh_val() {
    local MULTIPLIER=1.8
    if [ -f "$FACTOR_FILE" ]; then
        local DYN_VAL=$(cat "$FACTOR_FILE")
        if [[ "$DYN_VAL" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            MULTIPLIER="$DYN_VAL"
        fi
    fi

    local RAPL_PATH=""
    for rapl_dir in /sys/class/powercap/intel-rapl/intel-rapl:*; do
        if [ -f "$rapl_dir/name" ] && [ "$(cat "$rapl_dir/name" 2>/dev/null)" = "package-0" ]; then
            RAPL_PATH="$rapl_dir/energy_uj"
            break
        fi
    done

    if [ -z "$RAPL_PATH" ] && [ -f "/sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj" ]; then
        RAPL_PATH="/sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj"
    fi

    local ENERGY_UJ=$(cat "$RAPL_PATH" 2>/dev/null)
    if [ -z "$ENERGY_UJ" ]; then
        printf "%9.5f" 0
    else
        awk -v uj="$ENERGY_UJ" -v m="$MULTIPLIER" 'BEGIN {
            kwh = (uj / 3600000000000) * m;
            if (kwh > 999.99999) {
                kwh = 999.99999;
            }
            printf "%9.5f", kwh
        }'
    fi
}

if [ ! -d /sys/class/power_supply ] || [ -z "$(ls /sys/class/power_supply/ | grep -E '^BAT|^battery')" ]; then
    KWH_VAL=$(get_kwh_val)
    echo "BAT=${BAT_NONE}   0% | AC=${AC_ON} | KWH=${KWH_VAL} |"
    printf "%s" "$TOOLTIP_TXT" 1>&2
    exit 0
fi

TOT_CHARGE=0
TOT_FULL=0

for bat in /sys/class/power_supply/BAT*; do
    if [ -f "$bat/energy_now" ] && [ -f "$bat/energy_full" ]; then
        NOW=$(cat "$bat/energy_now")
        FULL=$(cat "$bat/energy_full")
        TOT_CHARGE=$((TOT_CHARGE + NOW))
        TOT_FULL=$((TOT_FULL + FULL))
    elif [ -f "$bat/charge_now" ] && [ -f "$bat/charge_full" ]; then
        NOW=$(cat "$bat/charge_now")
        FULL=$(cat "$bat/charge_full")
        TOT_CHARGE=$((TOT_CHARGE + NOW))
        TOT_FULL=$((TOT_FULL + FULL))
    fi
done

if [ "$TOT_FULL" -gt 0 ]; then
    CAP=$(( TOT_CHARGE * 100 / TOT_FULL ))
else
    CAP=0
fi

CAP_PAD=$(printf "%3d" "$CAP")

ACPI_OUT=$(acpi -b 2>/dev/null)

get_bat_icon() {
    if $HAS_BAT_HI && $HAS_BAT_LO; then
        if [ "$CAP" -ge 50 ]; then echo "$BAT_ON_HI"; else echo "$BAT_ON_LO"; fi
    elif $HAS_BAT_ON; then
        echo "$BAT_ON"
    else
        if [ "$CAP" -ge 50 ]; then echo "$BAT_ON_HI"; else echo "$BAT_ON_LO"; fi
    fi
}

if [[ "$ACPI_OUT" =~ "Charging" ]] || [[ "$ACPI_OUT" =~ "Full" ]] || [[ "$ACPI_OUT" =~ "Not charging" ]]; then
    # SEL_BAT_ON=$(get_bat_icon)
    KWH_VAL=$(get_kwh_val)
    # echo "BAT=${SEL_BAT_ON} ${CAP_PAD}% | AC=${AC_ON} | KWH=${KWH_VAL} |"
    echo "BAT=${BAT_ON} ${CAP_PAD}% | AC=${AC_ON} | KWH=${KWH_VAL} |"
    printf "%s" "$TOOLTIP_TXT" 1>&2
else
    if [ -f /sys/class/power_supply/AC/online ] && [ "$(cat /sys/class/power_supply/AC/online)" = "0" ]; then
        SEL_BAT_ON=$(get_bat_icon)
        if [ "$CAP" -lt 40 ]; then
            notify-send "⚠️ Low BAT"
        fi
        SYS_PWR_IN_MICRO_WATT=$(cat /sys/class/power_supply/BAT0/power_now 2>/dev/null)
        RAPL_PATH=""
        for rapl_dir in /sys/class/powercap/intel-rapl/intel-rapl:*; do
            if [ -f "$rapl_dir/name" ] && [ "$(cat "$rapl_dir/name" 2>/dev/null)" = "package-0" ]; then
                RAPL_PATH="$rapl_dir/energy_uj"
                break
            fi
        done
        if [ -z "$RAPL_PATH" ] && [ -f "/sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj" ]; then
            RAPL_PATH="/sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj"
        fi
        if [ ! -z "$SYS_PWR_IN_MICRO_WATT" ] && [ "$SYS_PWR_IN_MICRO_WATT" -gt 0 ] && [ -f "$RAPL_PATH" ]; then
            E_START=$(cat "$RAPL_PATH")
            sleep 0.5
            E_END=$(cat "$RAPL_PATH")
            awk -v p_sys="$SYS_PWR_IN_MICRO_WATT" -v e_s="$E_START" -v e_e="$E_END" -v f_file="$FACTOR_FILE.tmp" 'BEGIN {
                delta_uj = e_e - e_s;
                if (delta_uj > 0) {
                    p_cpu = (delta_uj * 2) / 1000000;
                    w_sys = p_sys / 1000000;
                    if (p_cpu > 0) {
                        mult = w_sys / p_cpu;
                        printf "%.2f", mult > f_file;
                    }
                }
            }' 2>/dev/null
            if [ -s "$FACTOR_FILE.tmp" ]; then
                mv "$FACTOR_FILE.tmp" "$FACTOR_FILE"
            fi
        fi
        KWH_VAL=$(get_kwh_val)
        echo "BAT=${SEL_BAT_ON} ${CAP_PAD}% | AC=${AC_NONE} | KWH=${KWH_VAL} |"
        printf "%s" "$TOOLTIP_TXT" 1>&2
    else
        KWH_VAL=$(get_kwh_val)
        echo "BAT=${IC_INIT} ${CAP_PAD}% | AC=${IC_INIT} | KWH=${KWH_VAL} |"
        printf "%s" "$TOOLTIP_TXT" 1>&2
    fi
fi
