#!/bin/bash
DOT=~/dot

cd $DOT

# Pull all submodules first.
git submodule update --recursive --remote

# Create symlinks -- watchout for preexisting files!
ln -s $DOT/.zshrc ~/.zshrc
ln -s $DOT/.zprofile ~/.zprofile
ln -s $DOT/.compleat ~/.compleat
ln -s $DOT/.gitconfig ~/.gitconfig
ln -s $DOT/.gitignore ~/.gitignore

mkdir -p ~/.config/Code/User
ln -s $DOT/.config/Code/User/settings.json ~/.config/Code/User/settings.json

# Install yaourt and arch dependencies.
(cd package-query && makepkg -si)
(cd yaourt && makepkg -si)
yaourt -Sy `cat dependencies-yaourt.txt`

sudo pip3 install -r $DOT/dependencies-pip3.txt
# sudo pip2 install -r $DOT/py2-requirements.txt  # None currently

# Install visual studio code extensions
for x in $(cat dependencies-vsc.txt); do code --install-extension $x; done

yarn global add diff-so-fancy flow tldr

(cd compleat && ./Setup.lhs configure && ./Setup.lhs build && sudo ./Setup.lhs install)

chsh -s /bin/zsh

# Setup juniper-vpn-py virtual environment
(cd juniper-vpn-py && virtualenv2 .venv && source .venv/bin/activate && pip2 install -r requirements.txt && deactivate)
