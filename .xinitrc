nm-applet --sm-disable &
pasystray &
blueman-applet &
setxkbmap -layout de
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources
exec i3
