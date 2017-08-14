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

# Install brew if not installed.
checked 'Brew not installed. Installing...' brew --version
if [ $? -ne 0 ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" || exit 1
    brew update
    brew upgrade
    brew doctor
    # tap bundle to be able to install bundles
    brew tap Homebrew/bundle
fi

function lnifnotexists() {
    [ -L ${HOME}/$1 ] || (mkdir -p ${HOME}/$(dirname $1) && ln -s $DOT/$1 ${HOME}/$1)
}

for link in \
    '.antigenrc' \
    '.Brewfile' \
    '.jupyter/nbconfig/notebook.json' \
    '.jupyter/jupyter_notebook_config.py' \
    '.zshrc' \
    '.gitconfig' \
    '.gitignore' \
    '.config/Code/User/settings' \
    '.antigenrc' \
    ; do
    lnifnotexists $link
done

mkdir -p ${HOME}/Library/Application\ Support/Code/User
rm ${HOME}/Library/Application\ Support/Code/User/settings.json
ln -s $DOT/.config/Code/User/settings.json ${HOME}/Library/Application\ Support/Code/User/settings.json

brew install python3
brew bundle --global

pip3 install -r $DOT/dependencies-pip3.txt
