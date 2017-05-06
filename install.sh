#!/bin/bash
DOT=~/dot

ln -s $DOT/.zshrc ~/.zshrc
ln -s $DOT/.zprofile ~/.zprofile
ln -s $DOT/.compleat ~/.compleat
ln -s $DOT/.gitconfig ~/.gitconfig

mkdir -p ~/.config/Code/User
ln -s $DOT/.config/Code/User/settings.json ~/.config/Code/User/settings.json

sudo pacman -S `cat arch_packages.txt`

sudo pip3 install -r $DOT/py3-requirements.txt
sudo pip2 install -r $DOT/py2-requirements.txt

sudo yarn global add diff-so-fancy

(cd compleat && ./Setup.lhs configure && ./Setup.lhs build && sudo ./Setup.lhs install)

chsh -s /bin/zsh
