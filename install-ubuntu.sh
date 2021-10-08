#!/bin/bash

read -p "Running ubuntu install. Continue? (Y/N) " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Most of the following requirements were initially selected according to pyenv
echo "Requiring sudo for installing apt dependencies."
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev \
    libxmlsec1-dev libffi-dev liblzma-dev \
    zsh ncdu htop thefuck

# Install default python
eval "$(pyenv init -)"
pyenv install $PYTHON_VERSION
pyenv global $PYTHON_VERSION

curl -sfL git.io/antibody | sh -s - -b /usr/local/bin

function lnifnotexists() {
  [ -L "${HOME}/$1" ] || (mkdir -p "${HOME}/$(dirname $1)" && ln -s "${DOT}/$1" "${HOME}/$1")
}

for link in \
  '.gdbinit' \
; do
  lnifnotexists $link
done
