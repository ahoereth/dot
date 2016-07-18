#
# ~/.zshrc
#


setopt autocd 
setopt extendedglob
bindkey -e # emacs mode


### Autocomplete
autoload -Uz compinit
compinit
setopt correctall
setopt COMPLETE_ALIASES
zstyle ':completion:*' menu select


### History
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS


### Directory navigation
cdUndoKey() { # back/left
  popd > /dev/null
  zle reset-prompt
  echo
  ls
  echo
}

cdParentKey() { # up
  pushd .. > /dev/null
  zle reset-prompt
  echo
  ls
  echo
}

zle -N cdParentKey
zle -N cdUndoKey
bindkey '^[[1;3A' cdParentKey
bindkey '^[[1;3D' cdUndoKey


### SSH Agent Initialization
if ! pgrep -u $USER ssh-agent > /dev/null; then
  ssh-agent > ~/.ssh-agent-thing
fi
if [[ "$SSH_AGENT_PID" == "" ]]; then
  eval $(<~/.ssh-agent-thing)
fi
