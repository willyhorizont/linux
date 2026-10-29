# keybinds

## keyboard layouts
```csv
general     ; Windows                             ; Mac                   ; other
control     ; control                             ; ^                     ; ^, C-
super       ; Windows logo                        ; command, ⌘            ; D-, Super-, Mod4
meta        ; Alt                                 ; option, ⌥             ; M-, Alt-, Mod1
shift       ; Shift, ⇧                            ; shift, ⇧              ; S-, Shift-
escape      ; Escape                              ; esc                   ; ESC, Esc, Escape
return      ; Enter, ↩                            ; return, ↩             ; RET, CR, Return, Enter
backspace   ; Backspace, ⌫                        ; delete, ⌫             ; BS, BackSpace
delete      ; Delete, ⌦                           ; fn + delete           ; DEL, Del, Delete
tab         ; Tab, ⇥                              ; tab, ⇥                ; TAB, Tab
insert      ; Insert, Ins                         ; fn + return           ; INS, Insert
home        ; Home                                ; fn + ⬅, ↖             ; HOME, Home
end         ; End                                 ; fn + ➡, ↘             ; END, End
pageup      ; Page Up, PgUp                       ; fn + ⬆, ⇞             ; PRIOR, PGUP, PageUp
pagedown    ; Page Down, PgDn                     ; fn + ⬇, ⇟             ; NEXT, PGDN, PageDown
fn          ; Fn                                  ; fn, 🌐                ; Fn
printscreen ; Print Screen, PrtSc                 ; command + shift + 3   ; Print
capslock    ; Caps Lock, ⇪                        ; caps lock             ; Caps, Caps_Lock
```

## Order
```
Windows = $control ➡️ $super ➡️ $meta
Mac     = $control ➡️ $meta  ➡️ $super
```

## open Windows File Explorer / Mac Finder / Linux Thunar or PCManFM
```
# Linux
# Windows
$super+e
# Mac
```

## open Windows Start menu / Mac Launchpad / Linux xfce4-popup-whiskermenu or jgmenu or dmenu or rofi
```
# Linux
$meta+F1
$super+a
$control+$escape
# Windows
$super
# Mac
F4
```

## open Windows Run / Mac Spotlight / Linux dmenu or rofi
```
# Linux
$super+d
# Windows
$super+r
# Mac
$meta+$space
```

## open terminal
```
# Linux
$super+$return
$control+$meta+t
# Windows
# Mac
```

## open Windows Task Manager / Mac Activity Monitor / Linux btop
```
# Linux
# Windows
$control+$shift+$escape
# Mac
$super+$meta+$escape
```

## kill focused window
```
# Windows
$meta+F4
# Mac
$super+q
# Linux
$super+$shift+q
```
