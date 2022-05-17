#
# ~/.zshrc
#

# zmodload zsh/zprof

export DOT_PATH=$HOME/repos/dot

source .zprofile

source $DOT_PATH/tools/sandboxd

# your default editor
export EDITOR='vim'
export VEDITOR='code'

setopt autocd
setopt extendedglob

export FZF_BASE=$DOT_PATH/tools/fzf

### Path
typeset -U path
export GOPATH=$HOME/go
path=(
  $DOT_PATH/bin
  $HOME/.bin
  $HOME/.node_modules/bin
  /Library/TeX/texbin
  $path[@]
  /usr/local/bin
)

JAVA_HOME="/usr/local/opt/openjdk"

## History
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N edit-command-line

export ZSH_CACHE_DIR="$HOME/.cache"

if [ -f "$DOT_PATH/zsh_plugins.sh" ] && [ -s diff.txt ]; then
  source $DOT_PATH/zsh_plugins.sh
else
  # zsh_plugins.sh does not yet exist. Create and load it.
  echo "Rebundling antigen"
  antibody bundle < $DOT_PATH/zsh_plugins.txt > $DOT_PATH/zsh_plugins.sh
  source $DOT_PATH/zsh_plugins.sh
  # source <(antibody init)
  # antibody bundle < $DOT_PATH/zsh_plugins.txt
fi
alias antibody_bundle="antibody bundle < $DOT_PATH/zsh_plugins.txt > $DOT_PATH/zsh_plugins.sh"
alias antibody_rebundle="rm $DOT_PATH/zsh_plugins.sh"


# bindkey '^[[A' history-substring-search-up
# bindkey '^[[B' history-substring-search-down

# make option - left and option - right skip words
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

autoload -Uz compinit promptinit bashcompinit
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
#zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
compinit
bashcompinit
promptinit
prompt pure
if type rclone &>/dev/null
then
  zsh $DOT_PATH/_rclone
fi

zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:*' list-lines 8
zstyle ':autocomplete:history-search:*' list-lines 8
zstyle ':autocomplete:*' insert-unambiguous yes
zstyle ':autocomplete:*' fzf-completion yes
#zstyle ':autocomplete:*' widget-style menu-select
# zstyle ':autocomplete:*' widget-style menu-complete

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi

.autocomplete.recent_paths.trim() {:}

echo "bat and ripgrep rg"

typeset -gA FAST_HIGHLIGHT
FAST_HIGHLIGHT[chroma-make]=0
FAST_HIGHLIGHT[make_chroma_type]=0
FAST_HIGHLIGHT[use_brackets]=1
#HISTORY_SUBSTRING_SEARCH_FUZZY=1
#HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# eval "$(pandoc --bash-completion)"
if command -v kubectl 1>/dev/null 2>&1; then
  alias k=kubectl
  source <(kubectl completion zsh)
  complete -F __start_kubectl k
fi

#PS1='$icon%{$fg_bold[yellow]%}%2~ %{$reset_color%}$ '
RPS1='%{$fg[red]%}$name%{$fg[magenta]%}%T%{$reset_color%}'
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  RPS1="⛵ $RPS1"
fi

# By default, zsh considers many characters part of a word (e.g., _ and -).
# Narrow that down to allow easier skipping through words via M-f and M-b.
export WORDCHARS='*?[]~&;!$%^<>'

if [ "$(uname)" = "Darwin" ]; then
  ### MATLAB with OpenJDK
  if ! type "$matlab" > /dev/null; then
    export MATLAB_JAVA=/usr/lib/jvm/java-8-openjdk/jre
  fi

  ### ccat colorized cat
  if ! type "$ccat" > /dev/null; then
    alias cat=ccat
    alias json='python -m json.tool | ccat'
  fi

  export PATH=/usr/local/opt/ccache/libexec:$PATH
fi

### git-checkout-before DATETIME BRANCH
# Checkout specified git branch at the latest commit before DATETIME
git-checkout-before() {
  echo 'git checkout `git rev-list -n 1 --before="'$1'" '$2'`\n'
  git checkout `git rev-list -n 1 --before="$1" $2`
}


## bg COMMAND
# Run COMMAND in backgrund and suppress its output.
bg() {
  echo "$@ > /dev/null 2>&1 &\n"
  $@ > /dev/null 2>&1 &
}


## toggleservice SERVICENAME
# Toggles (starts/stops) the specified systemctl service.
toggleservice() {
  if [ "`systemctl is-active $1`" != "active" ]; then
    echo "systemctl start $1\n"
    systemctl start $1
  else
    echo "systemctl stop $1\n"
    systemctl stop $1
  fi
}


function venv() {
  local py="python3"
  local vd=${1:-.venv}
  if [ ! -d ./$vd ]; then
    echo "creating virtual environment in ./$vd ..."
    if ! $py -m venv $vd --prompt=$(basename $PWD) --without-pip; then
      echo "ERROR: Failed creating venv" >&2
      return 1
    else
      local whl=$($py -c "import pathlib, ensurepip; [whl] = pathlib.Path(ensurepip.__path__[0]).glob('_bundled/pip*.whl'); print(whl)")
      echo "boostrapping pip using $whl"
      $vd/bin/python $whl/pip install --upgrade pip setuptools wheel
      source $vd/bin/activate
    fi
  else
    source $vd/bin/activate
  fi
}


extract () {
 if [ -f "$1" ] ; then
   case "$1" in
     *.tar.bz2)   tar xvjf $1    ;;
     *.tar.gz)    tar xvzf $1    ;;
     *.bz2)       bunzip2 $1     ;;
     *.rar)       unrar x $1     ;;
     *.gz)        gunzip $1      ;;
     *.gzip)      gunzip --suffix ".gzip" $1 ;;
     *.tar)       tar xvf $1     ;;
     *.tbz2)      tar xvjf $1    ;;
     *.tgz)       tar xvzf $1    ;;
     *.zip)       unzip $1       ;;
     *.Z)         uncompress $1  ;;
     *.7z)        7z x $1        ;;
     *.tar.xz)    tar xvfJ $1    ;;
     *)           echo "don't know how to extract '$1'..." ;;
   esac
 else
   echo "'$1' is not a valid file!"
 fi
}


max7z () {
  7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on $1
}


targz () {
  local dst=$1
  local inp=("${@:2}")
  tar cvf - $inp | gzip --best - > $dst
}


# Convert a video to a reasonable mp4.
#   Argument 1: Filepath
#   Argument 2: Fraction of 24fps to retain per second (optional)
reason () {
  if [ -f "$1" ] ; then
    local filter=
    if [ -n "$2" ] ; then
      local filter="-filter:v setpts=$2*PTS"
    fi
    set -x
    ffmpeg -i "$1" -vcodec libx264 -r 24 -crf 28 $filter "${1%.*}-reasonable.mp4"
    # ffmpeg -i "$1" -vcodec vp9 -filter "scale=1280:-1,fps=30" "${1%.*}-reasonable.webm"
    # ffmpeg -i "$1" -vcodec libx264 -r 24 -crf 28 -filter:v "crop=out_w:out_h:x:y" "${1%.*}-reasonable.mp4"
  else
    echo "'$1' is not a valid file!"
  fi
}


mfind () {
  find -L $@ 2>/dev/null
}


case "$OSTYPE" in
  darwin*)
    # source ~/.macrc
    set -o ignoreeof # disable exit with ctrl-d
    ssh-add --apple-use-keychain || ssh-add -K
    alias folders='du -hd1 | sort -hr'
    if ! type pbcopy > /dev/null; then
      alias pbcopy='xclip -selection clipboard'
      alias pbpaste='xclip -selection clipboard -o'
    fi
    ;;
  linux*)
    # source ~/.ubunturc
    ;;
  bsd*)     echo "BSD" ;;
  msys*)    echo "WINDOWS" ;;
  *)        echo "unknown: $OSTYPE" ;;
esac


alias psaux='ps aux | sort -n -r -k 3 | cut -c -$(tput cols)'
alias la="ls -lavh"
alias lx="la | awk '{k=0;for(i=0;i<=8;i++)k+=((substr(\$1,i+2,1)~/[rwx]/) \
                   *2^(8-i));if(k)printf(\"%0o \",k);print}'"
alias dev='cd $HOME/repos'
alias myip="curl -s https://api.ipify.org/"
alias cpip="myip | pbcopy"

# . .venv/bin/activate
#eval $(thefuck --alias) || echo "Couldn't find thef***"

# Delete whole string part using alt - del
backward-kill-dir () {
  local WORDCHARS=${WORDCHARS/\/}
  zle backward-kill-word
}
zle -N backward-kill-dir
bindkey '^[^?' backward-kill-dir

export HOMEBREW_INSTALL_CLEANUP=1

export LANG=en_US.UTF-8
export LANGUAGE=en_US
export LC_CTYPE="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_PAPER="en_US.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_ADDRESS="en_US.UTF-8"
export LC_TELEPHONE="en_US.UTF-8"
export LC_MEASUREMENT="en_US.UTF-8"
export LC_IDENTIFICATION="en_US.UTF-8"
export LC_ALL=

# Node version management
if command -v fnm 1>/dev/null 2>&1; then
  eval "$(fnm env)"
fi

# fuzzy matching fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# pyenv
# if command -v pyenv 1>/dev/null 2>&1; then
#   eval "$(pyenv init -)"
# fi

# Cuda exports.
if [ "$(uname)" = "Linux" ]; then
  if [ -d "/usr/local/cuda" ]; then
    export LD_LIBRARY_PATH=/usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH%:} # strip trailing :
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH#:} # strip leading :
    export PATH=/usr/local/cuda/bin:$PATH
    export CUDA_INC_DIR=/usr/local/cuda/include
    export CPATH=${CPATH%:} # strip trailing :
    export CPATH=${CPATH#:} # strip leading :
  fi
fi


# zprof
goconda () {
  export PATH=/usr/local/miniconda3/bin:$PATH

  # >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  __conda_setup="$('/Users/ahoereth/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "/Users/ahoereth/miniconda3/etc/profile.d/conda.sh" ]; then
          . "/Users/ahoereth/miniconda3/etc/profile.d/conda.sh"
      else
          export PATH="/Users/ahoereth/miniconda3/bin:$PATH"
      fi
  fi
  unset __conda_setup
  # <<< conda initialize <<<
}

# Ensure that tmux sessions have the same environment as the shell one is
# attaching from.
function update_environment_from_tmux() {
  if [ -n "${TMUX}" ]; then
    eval "$(tmux show-environment -s)"
  fi
}

add-zsh-hook precmd update_environment_from_tmux


PS1=$(echo $PS1 | sed 's/(base) //')
# export PATH="/usr/local/opt/ncurses/bin:$PATH"
# export LDFLAGS="-L/usr/local/opt/ncurses/lib"
# export CPPFLAGS="-I/usr/local/opt/ncurses/include"

export GPG_TTY=$(tty)

# Automatically source venv if .venv exists.
# if [[ -d .venv ]]; then
#   venv .venv
# fi
