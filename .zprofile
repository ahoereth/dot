#
# ~/.zprofile
#

[[ -f ~/.zshrc ]] && . ~/.zshrc

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

typeset -U path
path=(
  ~/bin
  $DOT_PATH/bin
  ~/.node_modules/bin
  ~/.gem/ruby/2.3.0/bin
  $path[@]
)
