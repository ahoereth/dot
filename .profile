export DOT_PATH=$HOME/repos/dot

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
  PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
  PATH="$HOME/.local/bin:$PATH"
fi

# pyenv
#export PYENV_ROOT="$DOT_PATH/tools/pyenv"
#export PATH="$PYENV_ROOT/bin:$PATH"
#if command -v pyenv 1>/dev/null 2>&1; then
#    eval "$(pyenv init --path)"
#fi
. "$HOME/.cargo/env"
