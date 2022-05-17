#!/bin/bash

read -p "Running macOS install. Continue? (Y/N) " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1


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

# Setup git-lfs -- maybe also do this on ubuntu?
echo "Need sudo to install git lfs on system level."
sudo git-lfs install --system

# brew software
checked 'Brew not installed. Installing...' brew --version
if [ $? -ne 0 ]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || exit 1
fi
lnifnotexists .Brewfile
brew update
brew upgrade
brew doctor
brew bundle --global


# symlinks
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


# vscode
mkdir -p "${HOME}/Library/Application Support/Code/User"
rm -f "${HOME}/Library/Application Support/Code/User/settings.json"
ln -s $DOT/tools/vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"
rm -f "${HOME}/Library/Application Support/Code/User/keybindings.json"
ln -s $DOT/tools/vscode/keybindings.json "$HOME/Library/Application Support/Code/User/keybindings.json"
for ext in \
  'waderyan.gitblame' \
  'xaver.clang-format' \
  'ms-vscode.cpptools' \
  'esbenp.prettier-vscode' \
  'ms-python.python' \
; do
  code --install-extension $ext
done


# window management
brew services start koekeishiya/formulae/skhd
brew services start koekeishiya/formulae/yabai
#skhd
#yabai
