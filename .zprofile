if type brew &>/dev/null
then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export DOT_PATH=$HOME/repos/dot

# pyenv
# export PYENV_ROOT="$DOT_PATH/tools/pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# if command -v pyenv 1>/dev/null 2>&1; then
#     eval "$(pyenv init --path)"
# fi
