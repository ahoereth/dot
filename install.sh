#!/bin/bash
DOT=$HOME/repos/dot

cd $DOT

# Pull all submodules first.
git submodule update --recursive --remote

# Create symlinks -- watchout for preexisting files!
ln -s $DOT/.zshrc $HOME/.zshrc
ln -s $DOT/.zprofile $HOME/.zprofile
ln -s $DOT/.compleat $HOME/.compleat
ln -s $DOT/.gitconfig $HOME/.gitconfig
ln -s $DOT/.gitignore $HOME/.gitignore
ln -s $DOT/.yabairc $HOME/.yabairc
ln -s $DOT/.skhdrc $HOME/.skhdrc
ln -s $DOT/.alacritty.yml $HOME/.alacritty.yml

ln -s $DOT/vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"

# Install yaourt and arch dependencies.
# (cd package-query && makepkg -si)
# (cd yaourt && makepkg -si)
# yaourt -Sy `cat dependencies-yaourt.txt`

# sudo pip3 install -r $DOT/dependencies-pip3.txt
# sudo pip2 install -r $DOT/py2-requirements.txt  # None currently

# Setup jupyter configuration
mkdir -p ~/.jupyter/nbconfig
ln -s $DOT/.jupyter/jupyter_notebook_config.py ~/.jupyter/jupyter_notebook_config.py
ln -s $DOT/.jupyter/nbconfig/notebook.json ~/.jupyter/nbconfig/notebook.json

# Install visual studio code extensions
for x in $(cat dependencies-vsc.txt); do code --install-extension $x; done

#yarn global add diff-so-fancy flow tldr

#(cd compleat && ./Setup.lhs configure && ./Setup.lhs build && sudo ./Setup.lhs install)

chsh -s /bin/zsh
