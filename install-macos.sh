#!/bin/bash
DOT=~/repos/dot

cd $DOT

# Runs a command and echos an error if it was not successful.
function checked() {
  "${@:2}" 2>/dev/null
  local status=$?
  if [ $status -ne 0 ]; then
    echo $1
  fi
  return $status
}

function lnifnotexists() {
  [ -L ${HOME}/$1 ] || (mkdir -p ${HOME}/$(dirname $1) && ln -s $DOT/$1 ${HOME}/$1)
}

# Install brew if not installed.
checked 'Brew not installed. Installing...' brew --version
if [ $? -ne 0 ]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || exit 1
fi
lnifnotexists .Brewfile
brew update
brew upgrade
brew doctor
brew bundle --global

for link in \
  '.alacritty.yml' \
  '.config/Code/User/settings' \
  '.jupyter/jupyter_notebook_config.py' \
  '.jupyter/nbconfig/notebook.json' \
  '.skhdrc' \
  '.yabairc' \
; do
  lnifnotexists $link
done

mkdir -p "${HOME}/Library/Application Support/Code/User"
rm -f "${HOME}/Library/Application Support/Code/User/settings.json"
ln -s $DOT/tools/vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"

brew services start koekeishiya/formulae/skhd
brew services start koekeishiya/formulae/yabai
skhd
yabai
