#!/bin/bash
DOT=$HOME/repos/dot

error() {
  printf '\E[31m'; echo "$@"; printf '\E[0m'
}

if [[ $EUID -eq 0 ]]; then
  error "Do not run this as the root user"
  exit 1
fi

cd $DOT

# Pull all submodules first.
git submodule update --init --recursive --remote


os=$(uname)
case $os in
  Darwin )  echo "System: macOS"
            echo "continue?"
            read
            bash ./install-macos.sh
            ;;
  Linux )   echo "System: ubuntu"
            echo "continue?"
            read
            bash ./install-ubuntu.sh
            ;;
esac


# Link dotfiles to their proper locations.
function lnifnotexists() {
  [ -L "${HOME}/$1" ] || (mkdir -p "${HOME}/$(dirname $1)" && ln -s "${DOT}/$1" "${HOME}/$1")
}

for link in \
  '.zshrc' \
  '.gitconfig' \
  '.gitignore' \
; do
  lnifnotexists $link
done

rm -f "${HOME}/.gitignore_global"
ln -s "${DOT}/.gitignore" "${HOME}/.gitignore_global"

pyenv init
pyenv install 3.8.6
pyenv global 3.8.6

sudo chsh -s /bin/zsh || true
sudo usermod -s /bin/zsh $(whoami) || true

echo "You probably want to restart your terminal now..."
