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
            bash ./setup_ubuntu.sh
            ;;
esac


# Create symlinks -- watchout for preexisting files!
ln -s$FORCE $DOT/.zshrc $HOME/.zshrc
ln -s$FORCE $DOT/.zprofile $HOME/.zprofile
ln -s$FORCE $DOT/.compleat $HOME/.compleat
ln -s$FORCE $DOT/.gitconfig $HOME/.gitconfig
ln -s$FORCE $DOT/.gitignore $HOME/.gitignore

chsh -s /bin/zsh
