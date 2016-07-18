#
# ~/.zshrc
#

### zsh
setopt autocd 
setopt extendedglob
bindkey -e # emacs mode

### Autocomplete
autoload -Uz compinit
compinit
setopt correctalls
setopt COMPLETE_ALIASES
zstyle ':completion:*' menu select

### History
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
