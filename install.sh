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
  Darwin )  echo "macOS"
            ;;
  Linux )   echo "ubuntu"
            bash ./install-ubuntu.sh
            ;;
esac


### SYMLINKS
# Link dotfiles to their proper locations.
function lnifnotexists() {
    [ -L "${HOME}/$1" ] || (mkdir -p "${HOME}/$(dirname $1)" && ln -s "${DOT}/$1" "${HOME}/$1")
}

for link in \
  '.zshrc' \
  '.zprofile' \
  '.compleat' \
  '.gitconfig' \
  '.gitignore' \
  '.yabairc' \
  '.skhdrc' \
  '.alacritty.yml' \
; do
  lnifnotexists $link
done
ln -s "${DOT}/.gitignore" "${HOME}/.gitignore_global"


# Install yaourt and arch dependencies.
# (cd package-query && makepkg -si)
# (cd yaourt && makepkg -si)
# yaourt -Sy `cat dependencies-yaourt.txt`

# sudo pip3 install -r $DOT/dependencies-pip3.txt
# sudo pip2 install -r $DOT/py2-requirements.txt  # None currently


# sudo chsh -s /bin/zsh
sudo usermod -s /bin/zsh ahoereth
