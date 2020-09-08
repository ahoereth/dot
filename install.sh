#!/bin/bash
DOT=$HOME/repos/dot

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
    [ -L "${HOME}/$1" ] || (mkdir -p "${HOME}/$(dirname $1)" && ln -s "${DOT_PATH}/$1" "${HOME}/$1")
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
ln -s "${DOTFILES_DIR}/.gitignore" "${HOME}/.gitignore_global"


# Install yaourt and arch dependencies.
# (cd package-query && makepkg -si)
# (cd yaourt && makepkg -si)
# yaourt -Sy `cat dependencies-yaourt.txt`

# sudo pip3 install -r $DOT/dependencies-pip3.txt
# sudo pip2 install -r $DOT/py2-requirements.txt  # None currently


chsh -s /bin/zsh
