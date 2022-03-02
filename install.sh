#!/bin/bash
error() {
  printf '\E[31m'; echo "$@"; printf '\E[0m'
}

if [[ $EUID -eq 0 ]]; then
  error "Do not run this as the root user"
  exit 1
fi

while [ "$1" != "" ]; do
  case $1 in
    # --keyword)
    #   VALUE="$2"
    #   shift
    #   shift
    #   ;;
    --pyenv)
      PYENV=1
      shift
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

DOT=$HOME/repos/dot
cd $DOT


# Update all submodules first.
git submodule update --init --recursive --remote

export PYENV_ROOT="$DOT/tools/pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

export PYTHON_VERSION=3.10.2

# Maybe run OS specific installations.
os=$(uname)
case $os in
  Darwin )  echo "System: macOS"
            ./install-macos.sh
            ;;
  Linux )   echo "System: ubuntu"
            PYENV=$PYENV ./install-ubuntu.sh
            ;;
esac


# Link dotfiles shared over all operating systems to their proper locations.
function lnifnotexists() {
  [ -L "${HOME}/$1" ] || (mkdir -p "${HOME}/$(dirname $1)" && ln -s "${DOT}/$1" "${HOME}/$1")
}

for link in \
  '.profile' \
  '.zprofile' \
  '.zshrc' \
  '.gitconfig' \
  '.gitignore' \
; do
  lnifnotexists $link
done

rm -f "${HOME}/.gitignore_global"
ln -s "${DOT}/.gitignore" "${HOME}/.gitignore_global"

# fzf
$DOT/tools/fzf/install

# Make zsh the default shell
echo "Need sudo to make zsh the default shell."
chsh -s /bin/zsh || true
usermod -s /bin/zsh $(whoami) || true


# Install .ssh/config
read -p "Install the shared .ssh/config? (Y/N) " confirm &&
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
  mkdir -p $HOME/.ssh
  mv "${HOME}/.ssh/config" "${HOME}/.ssh/config.bak" || true
  ln -s "${DOT}/dot-extras/.ssh/config" "${HOME}/.ssh/config"
fi


echo "You probably want to restart your terminal now..."
