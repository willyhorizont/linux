```bash
OPEN_WINS=$(wmctrl -l -x -G | awk '
{
    if ($7 == "pcmanfm.Pcmanfm" && $9 == "pcmanfm") next;
    if ($7 == "plank.Plank" && $9 == "plank") next;
    if ($7 == "tint2.Tint2") next;
    if ($7 == "xpenguins.Xpenguins") next;
    if ($7 ~ /welcome-window|idle-window/) next;
    print $0
}' 2>/dev/null)
```

```bash
#!/bin/bash

if ! command -v wmctrl &> /dev/null || ! command -v xdotool &> /dev/null; then
    notify-send "kb-tile-cur-wrkspc.sh" "Error: missing dependencies 'wmctrl xdotool'..."
    exit 1
fi

half_q_w=401
LT_R_or_LB_R_w=$((half_q_w + 1))
RT_R_or_RB_R_x=$((half_q_w * 2))

WM_DATA=$(wmctrl -d | grep '*')
WORK_AREA=$(echo "$WM_DATA" | grep -oE 'WA: [0-9]+,[0-9]+ [0-9]+x[0-9]+')
WA_W=$(echo "$WORK_AREA" | awk '{print $3}' | cut -d'x' -f1)
WA_H=$(echo "$WORK_AREA" | awk '{print $3}' | cut -d'x' -f2)
WA_X=$(echo "$WORK_AREA" | awk '{print $2}' | cut -d' ' -f1 | cut -d',' -f1)
WA_Y=$(echo "$WORK_AREA" | awk '{print $2}' | cut -d' ' -f1 | cut -d',' -f2)
h_half=$(( WA_H / 2 ))

cur_wrkspc=$(echo "$WM_DATA" | awk '{print $1}')

OPEN_WINS=$(wmctrl -l -x -G | awk -v ws="$cur_wrkspc" '$2 == ws {
    if ($7 == "pcmanfm.Pcmanfm" && $9 == "pcmanfm") next;
    if ($7 == "plank.Plank" && $9 == "plank") next;
    if ($7 == "tint2.Tint2") next;
    if ($7 == "xpenguins.Xpenguins") next;
    if ($7 ~ /welcome-window|idle-window/) next;
    print $1
}' 2>/dev/null)

WIN_ARRAY=($OPEN_WINS)
WIN_COUNT=${#WIN_ARRAY[@]}

if [ "$WIN_COUNT" -eq 0 ]; then
    exit 0
fi

tile_win() {
    local wid=$1
    local x=$2
    local y=$3
    local w=$4
    local h=$5
    wmctrl -i -r "$wid" -b remove,maximized_vert,maximized_horz
    xdotool windowsize "$wid" "$w" "$h"
    xdotool windowmove "$wid" $((x + WA_X)) $((y + WA_Y))
}
```

```csv
keybinds     ; action                                   ; x       ; y      ; w       ; h   
C-W-q        ; tile cur_actv_win to LT                  ; 2       ; 60     ; 798     ; 401 
C-W-S-q      ; tile cur_actv_win to LT_L                ; 2       ; 60     ; 398     ; 401
C-W-S-1      ; tile cur_actv_win to LT_R                ; 404     ; 60     ; 398     ; 401
C-W-a        ; tile cur_actv_win to LB                  ; 2       ; 484    ; 798     ; 401 
C-W-S-a      ; tile cur_actv_win to LB_L                ; 2       ; 484    ; 398     ; 401
C-W-S-z      ; tile cur_actv_win to LB_R                ; 404     ; 484    ; 398     ; 401
C-W-w        ; tile cur_actv_win to RT                  ; 802     ; 60     ; 798     ; 401 
C-W-S-2      ; tile cur_actv_win to RT_L                ; 804     ; 60     ; 398     ; 401
C-W-S-w      ; tile cur_actv_win to RT_R                ; 1202    ; 60     ; 398     ; 401
C-W-s        ; tile cur_actv_win to RB                  ; 802     ; 484    ; 798     ; 401 
C-W-S-x      ; tile cur_actv_win to RB_L                ; 804     ; 484    ; 398     ; 401
C-W-S-s      ; tile cur_actv_win to RB_R                ; 1202    ; 484    ; 398     ; 401
C-W-g        ; tile cur_actv_win to CG                  ; 50      ; 98     ; 1502    ; 748
C-W-Left     ; tile cur_actv_win to L                   ; 2       ; 60     ; 798     ; 825
C-W-Right    ; tile cur_actv_win to R                   ; 802     ; 60     ; 798     ; 825
C-W-Up       ; tile cur_actv_win to T                   ;         ;        ;         ;     
C-W-down     ; tile cur_actv_win to B                   ;         ;        ;         ;     
C-W-z        ; tile cur_actv_win to max                 ;         ;        ;         ;     
C-W-d        ; tile cur_actv_win to toggle_show_desktop ;         ;        ;         ;     
```

```csv
; auto tiling ; position                                ; dimension w*h,...                                                ;
; 1 win       ; CG                                      ; 94%*91%                                                          ;
; 2 win       ; L,R                                     ; 50%*100%,50%*100%                                                ;
;             ; T,B                                     ; 100%*50%,100%*50%                                                ;
; 3 win       ; L,RT,RB                                 ; 50%*100%,50%*50%,50%*50%                                         ;
;             ; R,LT,LB                                 ; 50%*100%,50%*50%,50%*50%                                         ;
; 4 win       ; LT,LB,RT,RB                             ; 50%*50%,50%*50%,50%*50%,50%*50%                                  ;
;             ; L,RT,RB_L,RB_R                          ; 50%*100%,50%*50%,25%*50%,25%*50%                                 ;
;             ; R,LT,LB_L,LB_R                          ; 50%*100%,50%*50%,25%*50%,25%*50%                                 ;
; 5 win       ; LT,LB,RT,RB_L,RB_R                      ; 50%*50%,50%*50%,50%*50%,25%*50%,25%*50%                          ;
; 6 win       ; LT,LB,RT_L,RT_R,RB_L,RB_R               ; 50%*50%,50%*50%,25%*50%,25%*50%,25%*50%,25%*50%                  ;
; 7 win       ; LT,LB_L,LB_R,RT_L,RT_R,RB_L,RB_R        ; 50%*50%,25%*50%,25%*50%,25%*50%,25%*50%,25%*50%,25%*50%          ;
; 8 win       ; LT_L,LT_R,LB_L,LB_R,RT_L,RT_R,RB_L,RB_R ; 25%*50%,25%*50%,25%*50%,25%*50%,25%*50%,25%*50%,25%*50%,25%*50%  ;
; >= 9 win    ; LT,LB,RT_S,RB_L,RB_R                    ; 50%*50%,50%*50%,50%*50%,25%*50%,25%*50%                          ;
```
