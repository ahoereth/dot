#!/bin/bash
DOT=$HOME/repos/dot

cd $DOT

# Pull all submodules first.
git submodule update --recursive --remote

os=$(uname)
case $os in
  Darwin )  echo "macOS"
            ;;
  Linux )   echo "ubuntu"
            bash ./setup_ubuntu.sh
            ;;
esac

# Create symlinks -- watchout for preexisting files!
ln -s $DOT/.zshrc $HOME/.zshrc
ln -s $DOT/.zprofile $HOME/.zprofile
ln -s $DOT/.compleat $HOME/.compleat
ln -s $DOT/.gitconfig $HOME/.gitconfig
ln -s $DOT/.gitignore $HOME/.gitignore

chsh -s /bin/zsh
