#!/bin/sh

rm -rf ~/.icons/tuxcursor3/
mkdir -p ~/.icons/tuxcursor3/cursors
cp -r ~/.icons/tuxcursor/cursors/* ~/.icons/tuxcursor3/cursors/
cd ~/.icons/tuxcursor3/cursors

## Text Mode (I)

rm -f xterm
ln -s left_ptr xterm



## Horizontal Resize (<->)

rm -f h_double_arrow
rm -f sb_h_double_arrow
ln -s right_side h_double_arrow
ln -s left_side sb_h_double_arrow



## Vertical Resize (<->)

rm -f v_double_arrow
rm -f sb_v_double_arrow
ln -s top_side v_double_arrow
ln -s bottom_side sb_v_double_arrow



## Maybe Symlinks == Move (+)

#; 00008160000006810000408080010102 #; v_double_arrow  #; top_side        
#; 028006030e0e7ebffc7f7070c0600140 #; h_double_arrow  #; right_side      
#; 03b6e0fcb3499374a867c041f52298f0 #; crossed_circle  #; crossed_circle  
#; 08e8e1c95fe2fc01f976f1e063a24ccd #; left_ptr_watch  #; left_ptr_watch  
#; 4498f0e0c1937ffe01fd06f973665830 #; left_ptr        #; left_ptr        
#; 640fb0e74195791501fd1ed57b41487f #; hand2           #; right_side      
#; 9d800788f1b08800ae810202380a0822 #; hand            #; right_side      
#; arrow                            #; right_ptr       #; right_ptr       
#; c7088f0f3e6c8088236ef8e1e3e70000 #; bd_double_arrow #; bd_double_arrow 
#; crosshair                        #; cross           #; cross           
#; cross_reverse                    #; cross           #; cross           
#; d9ce0ab605698f320427677b458ad60b #; question_arrow  #; question_arrow  
#; draft_large                      #; right_ptr       #; right_ptr       
#; draft_small                      #; right_ptr       #; right_ptr       
#; e29285e634086352946a0e7090d73106 #; hand2           #; right_side      
#; fcf1c3c7cd4491d801f1e1c78f100000 #; fd_double_arrow #; fd_double_arrow 
#; plus                             #; cross           #; cross           
#; tcross                           #; cross           #; cross           
#; top_left_arrow                   #; left_ptr        #; left_ptr        

rm -f 00008160000006810000408080010102 #; v_double_arrow  #; top_side        
rm -f 028006030e0e7ebffc7f7070c0600140 #; h_double_arrow  #; right_side      
# rm -f 03b6e0fcb3499374a867c041f52298f0 #; crossed_circle  #; crossed_circle  
# rm -f 08e8e1c95fe2fc01f976f1e063a24ccd #; left_ptr_watch  #; left_ptr_watch  
# rm -f 4498f0e0c1937ffe01fd06f973665830 #; left_ptr        #; left_ptr        
rm -f 640fb0e74195791501fd1ed57b41487f #; hand2           #; right_side      
rm -f 9d800788f1b08800ae810202380a0822 #; hand            #; right_side      
# rm -f arrow                            #; right_ptr       #; right_ptr       
# rm -f c7088f0f3e6c8088236ef8e1e3e70000 #; bd_double_arrow #; bd_double_arrow 
# rm -f crosshair                        #; cross           #; cross           
# # rm -f cross_reverse                    #; cross           #; cross           
# rm -f d9ce0ab605698f320427677b458ad60b #; question_arrow  #; question_arrow  
# # rm -f draft_large                      #; right_ptr       #; right_ptr       
# # rm -f draft_small                      #; right_ptr       #; right_ptr       
rm -f e29285e634086352946a0e7090d73106 #; hand2           #; right_side      
# rm -f fcf1c3c7cd4491d801f1e1c78f100000 #; fd_double_arrow #; fd_double_arrow 
# # rm -f plus                             #; cross           #; cross           
# # rm -f tcross                           #; cross           #; cross           
# # rm -f top_left_arrow                   #; left_ptr        #; left_ptr        

ln -s top_side 00008160000006810000408080010102
ln -s right_side 028006030e0e7ebffc7f7070c0600140
ln -s right_side 640fb0e74195791501fd1ed57b41487f
ln -s right_side 9d800788f1b08800ae810202380a0822
ln -s right_side e29285e634086352946a0e7090d73106



## Maybe the rest == Move (+)

# rm -f bd_double_arrow
# rm -f bottom_left_corner
# rm -f bottom_right_corner
# rm -f cross
# rm -f crossed_circle
# rm -f diamond_cross
# rm -f fd_double_arrow
rm -f hand
rm -f hand2
# rm -f left_ptr_watch
# rm -f question_arrow
# rm -f top_left_corner
# rm -f top_right_corner
# rm -f watch
# rm -f right_ptr
# rm -f bottom_tee
# rm -f left_tee
# rm -f ll_angle
# rm -f sb_right_arrow
# rm -f based_arrow_up
# rm -f right_tee
# rm -f dot
# rm -f dotbox
# rm -f draped_box
# rm -f pirate
# rm -f based_arrow_down
# rm -f center_ptr
# rm -f circle
# rm -f double_arrow
# rm -f left_ptr_old
# rm -f sb_up_arrow
# rm -f top_tee
# rm -f X_cursor
rm -f fleur
# rm -f pencil
# rm -f shuttle
# rm -f gumby

# ln -s right_side bd_double_arrow
# ln -s right_side bottom_left_corner
# ln -s right_side bottom_right_corner
# ln -s right_side cross
# ln -s right_side crossed_circle
# ln -s right_side diamond_cross
# ln -s right_side fd_double_arrow
ln -s right_side hand
ln -s right_side hand2
# ln -s right_side left_ptr_watch
# ln -s right_side question_arrow
# ln -s right_side top_left_corner
# ln -s right_side top_right_corner
# ln -s right_side watch
# ln -s right_side right_ptr
# ln -s right_side bottom_tee
# ln -s right_side left_tee
# ln -s right_side ll_angle
# ln -s right_side sb_right_arrow
# ln -s right_side based_arrow_up
# ln -s right_side right_tee
# ln -s right_side dot
# ln -s right_side dotbox
# ln -s right_side draped_box
# ln -s right_side pirate
# ln -s right_side based_arrow_down
# ln -s right_side center_ptr
# ln -s right_side circle
# ln -s right_side double_arrow
# ln -s right_side left_ptr_old
# ln -s right_side sb_up_arrow
# ln -s right_side top_tee
# ln -s right_side X_cursor
ln -s right_side fleur
# ln -s right_side pencil
# ln -s right_side shuttle
# ln -s right_side gumby



echo -e "[Icon Theme]\nInherits=tuxcursor3" > ~/.icons/default/index.theme
# touch ~/.Xresources && (grep -q "^Xcursor.theme:" ~/.Xresources && sed -i 's/^Xcursor.theme:.*/Xcursor.theme: tuxcursor3/' ~/.Xresources || echo "Xcursor.theme: tuxcursor3" >> ~/.Xresources) && xrdb -merge ~/.Xresources
# touch ~/.gtkrc-2.0 && (grep -q "^gtk-cursor-theme-name=" ~/.gtkrc-2.0 && sed -i 's/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name="tuxcursor3"/' ~/.gtkrc-2.0 || echo 'gtk-cursor-theme-name="tuxcursor3"' >> ~/.gtkrc-2.0)
# if [ ! -f ~/.config/gtk-2.0/settings.ini ] || ! grep -q "^\[Settings\]" ~/.config/gtk-2.0/settings.ini; then mkdir -p ~/.config/gtk-2.0 && echo -e "[Settings]\ngtk-cursor-theme-name=tuxcursor3" > ~/.config/gtk-2.0/settings.ini; else grep -q "^gtk-cursor-theme-name=" ~/.config/gtk-2.0/settings.ini && sed -i 's/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=tuxcursor3/' ~/.config/gtk-2.0/settings.ini || sed -i '/^\[Settings\]/a gtk-cursor-theme-name=tuxcursor3' ~/.config/gtk-2.0/settings.ini; fi
# if [ ! -f ~/.config/gtk-3.0/settings.ini ] || ! grep -q "^\[Settings\]" ~/.config/gtk-3.0/settings.ini; then mkdir -p ~/.config/gtk-3.0 && echo -e "[Settings]\ngtk-cursor-theme-name=tuxcursor3" > ~/.config/gtk-3.0/settings.ini; else grep -q "^gtk-cursor-theme-name=" ~/.config/gtk-3.0/settings.ini && sed -i 's/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=tuxcursor3/' ~/.config/gtk-3.0/settings.ini || sed -i '/^\[Settings\]/a gtk-cursor-theme-name=tuxcursor3' ~/.config/gtk-3.0/settings.ini; fi
# if [ ! -f ~/.config/gtk-4.0/settings.ini ] || ! grep -q "^\[Settings\]" ~/.config/gtk-4.0/settings.ini; then mkdir -p ~/.config/gtk-4.0 && echo -e "[Settings]\ngtk-cursor-theme-name=tuxcursor3" > ~/.config/gtk-4.0/settings.ini; else grep -q "^gtk-cursor-theme-name=" ~/.config/gtk-4.0/settings.ini && sed -i 's/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=tuxcursor3/' ~/.config/gtk-4.0/settings.ini || sed -i '/^\[Settings\]/a gtk-cursor-theme-name=tuxcursor3' ~/.config/gtk-4.0/settings.ini; fi
