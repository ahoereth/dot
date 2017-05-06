#!/bin/bash
DOT=~/dot

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
yaourt -Sy `cat arch_packages.txt`

sudo pip3 install -r $DOT/py3-requirements.txt
# sudo pip2 install -r $DOT/py2-requirements.txt  # None currently

# Install visual studio code extensions
for x in $(cat package_list.txt); do code --install-extension $x; done

sudo yarn global add diff-so-fancy

(cd compleat && ./Setup.lhs configure && ./Setup.lhs build && sudo ./Setup.lhs install)

chsh -s /bin/zsh

# Setup juniper-vpn-py virtual environment
(cd juniper-vpn-py && virtualenv2 .venv && source .venv/bin/activate && pip2 install -r requirements.txt && deactivate)
