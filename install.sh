#!/bin/bash
error() {
  printf '\E[31m'; echo "$@"; printf '\E[0m'
}

if [[ $EUID -eq 0 ]]; then
  error "Do not run this as the root user"
  exit 1
fi


DOT=$HOME/repos/dot
cd $DOT


# Update all submodules first.
git submodule update --init --recursive --remote


# Maybe run OS specific installations.
os=$(uname)
case $os in
  Darwin )  echo "System: macOS"
            bash ./install-macos.sh
            ;;
  Linux )   echo "System: ubuntu"
            bash ./install-ubuntu.sh
            ;;
esac


# Link dotfiles shared over all operating systems to their proper locations.
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


# Install default python
pyenv init
pyenv install 3.8.6
pyenv global 3.8.6


# Make zsh the default shell
echo "Need sudo to make zsh the default shell."
sudo chsh -s /bin/zsh || true
sudo usermod -s /bin/zsh $(whoami) || true


# Install .ssh/config
read -p "Install the shared .ssh/config? (Y/N) " confirm &&
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
  mv "${HOME}/.ssh/config" "${HOME}/.ssh/config.bak" || true
  ln -s "${DOT}/dot-extras/.ssh/config" "${HOME}/.ssh/config"
fi


echo "You probably want to restart your terminal now..."
