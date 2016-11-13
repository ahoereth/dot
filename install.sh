#!/bin/bash
DOT=~/dot

ln -s $DOT/.zshrc ~/.zshrc
ln -s $DOT/.zprofile ~/.zprofile
ln -s $DOT/.compleat ~/.compleat

cp $DOT/.gitconfig ~/.gitconfig

pacman -S base-devel nodejs npm haskell-parsec

pip install -r $DOT/requirements.txt

yarn global add diff-so-fancy

(cd compleat && ./Setup.lhs configure && ./Setup.lhs build && sudo ./Setup.lhs install)
