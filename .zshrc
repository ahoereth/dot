#
# ~/.zshrc
#


setopt autocd 
setopt extendedglob
bindkey -e # emacs mode


### oh-my-zsh
export ZSH=/home/ahoereth/.oh-my-zsh
ZSH_THEME="terminalparty"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
plugins=(gitfast npm sudo wd pip python last-working-dir)
source $ZSH/oh-my-zsh.sh


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


### The Fuck
if ! type "$thefuck" > /dev/null; then
  eval $(thefuck --alias)
  alias FUCK='fuck'
fi


