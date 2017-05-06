#!/bin/bash
DOT=~/dot

ln -s $DOT/.zshrc ~/.zshrc
ln -s $DOT/.zprofile ~/.zprofile
ln -s $DOT/.compleat ~/.compleat

cp $DOT/.gitconfig ~/.gitconfig

pacman -S base-devel nodejs npm haskell-parsec

sudo pip3 install -r $DOT/py3-requirements.txt
sudo pip2 install -r $DOT/py2-requirements.txt

sudo yarn global add diff-so-fancy

(cd compleat && ./Setup.lhs configure && ./Setup.lhs build && sudo ./Setup.lhs install)

git config --global commit.gpgsign true
