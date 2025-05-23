#
# ~/.zshrc
#

# zmodload zsh/zprof

export DOT_PATH=$HOME/repos/dot

source $HOME/.zprofile

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
  $HOME/.local/bin
  $HOME/.docker/bin
  $HOME/.gem/bin
  $HOME/.node_modules/bin
  /Library/TeX/texbin
  /opt/homebrew/bin
  /usr/local/bin
  $path[@]
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

source $DOT_PATH/tools/zsh-defer/zsh-defer.plugin.zsh

zstyle ':autocomplete:key-bindings' enabled no

# needs to come before antidote
autoload -Uz compinit && compinit

source $DOT_PATH/tools/antidote/antidote.zsh
md5sum --check $DOT_PATH/zsh_plugins_md5.txt --quiet
match=$?
if [ -f "$DOT_PATH/zsh_plugins.zsh" ] && [ -s "$DOT_PATH/zsh_plugins.zsh" ] && [ $match -eq 0 ]; then
  zsh-defer source $DOT_PATH/zsh_plugins.zsh
else
  # zsh_plugins.zsh does not yet exist. Create and load it.
  echo "Rebundling antidote"
  antidote bundle < $DOT_PATH/zsh_plugins.txt > $DOT_PATH/zsh_plugins.zsh
  zsh-defer source $DOT_PATH/zsh_plugins.zsh
  md5sum $DOT_PATH/zsh_plugins.txt > $DOT_PATH/zsh_plugins_md5.txt
  # source <(antidote init)
  # antidote bundle < $DOT_PATH/zsh_plugins.txt
fi
alias antidote_bundle="antidote bundle < $DOT_PATH/zsh_plugins.txt > $DOT_PATH/zsh_plugins.zsh"
alias antidote_rebundle="rm $DOT_PATH/zsh_plugins.zsh"

# Autocompletion
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=white'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

bindkey -e

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# make option - left and option - right skip words
# bindkey "^[[1;3C" forward-word
# bindkey "^[[1;3D" backward-word
# make shift - left and option - right skip words, matches vim
bindkey "^[[1;2C" forward-word
bindkey "^[[1;2D" backward-word

autoload -Uz compinit promptinit bashcompinit
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
#zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
bashcompinit
promptinit
zsh-defer prompt pure
# if type rclone &>/dev/null && [ -f "$DOT_PATH/.config/rclone/_rclone" ]
# then
#   . $DOT_PATH/.config/rclone/_rclone
# fi

# zstyle ':autocomplete:*' min-input 1
# zstyle ':autocomplete:*' list-lines 8
# zstyle ':autocomplete:history-search:*' list-lines 8
zstyle ':autocomplete:*' insert-unambiguous yes
zstyle ':autocomplete:*' fzf-completion yes
zstyle ':autocomplete:*' widget-style menu-select
# # zstyle ':autocomplete:*' widget-style menu-complete
zsh-defer -c "bindkey '^I' menu-select"
zsh-defer -c "bindkey '^I' menu-select"
zsh-defer -c "bindkey '\e^I' reverse-menu-select"
zsh-defer -c "zstyle ':autocomplete:*' insert-unambiguous yes"
zsh-defer -c "zstyle ':autocomplete:*' fzf-completion yes"
zsh-defer -c "bindkey '\t' menu-select "$terminfo[kcbt]" menu-select"
zsh-defer -c "bindkey -M menuselect '\t' menu-complete '$terminfo[kcbt]' reverse-menu-complete"

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi

eval "$(zoxide init zsh)"

#.autocomplete.recent_paths.trim() {:}

echo "bat and ripgrep rg, tig and entr"

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

  export PATH=/usr/local/opt/ccache/libexec:$PATH
fi


# ccat colorized cat
if command -v ccat &> /dev/null; then
  alias cat=ccat
  alias json='python -m json.tool | ccat'
fi


# viddy watch
alias wwatch=watch
if command -v viddy &> /dev/null; then
  alias watch=viddy
fi


### git-checkout-before DATETIME BRANCH
# Checkout specified git branch at the latest commit before DATETIME
# git-checkout-before() {
#   echo 'git checkout `git rev-list -n 1 --before="'$1'" '$2'`\n'
#   git checkout `git rev-list -n 1 --before="$1" $2`
# }


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
  local bases=("." ".." "../.." "../../..")
  local sourced=0
  for base in "${bases[@]}"; do
    file=`readlink -f "$base/$vd/bin/activate"`
    if [ -f "$file" ]; then
      echo "Sourcing $file"
      source "$file"
      python --version
      sourced=1
      break
    fi
  done
  if [ $sourced -eq 0 ]; then
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
  fi
}


function psauxkill() {
  ps aux | grep $1 | tr -s " " | cut -d " " -f2 | xargs sudo kill -9
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
    if [ -z "${TMUX}" ]; then
      set -o ignoreeof # disable exit with ctrl-d
    fi
    zsh-defer ssh-add --apple-use-keychain || ssh-add -K
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
# alias gh-commit="echo $(gh repo view --json url  --jq .url)/commit/$(git rev-parse HEAD)"

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
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# On macOS alt-c prints ç, bind that to the fzf-cd-widget which on other
# systems is triggered by alt-c.
# https://github.com/junegunn/fzf/issues/1531
# https://github.com/junegunn/fzf/issues/164#issuecomment-1324505215
bindkey 'ç' fzf-cd-widget
is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}
# https://polothy.github.io/post/2019-08-19-fzf-git-checkout/
fzf-git-branch() {
  git rev-parse HEAD > /dev/null 2>&1 || return
  git branch --color=always --all --sort=-committerdate |
    grep -v HEAD |
    sed 's#remotes/[^/]*/##' |
    fzf --height 50% --ansi --no-multi --preview-window right:65% \
        --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})' |
    sed "s/.* //"
}
fzf-git-checkout() {
  git rev-parse HEAD > /dev/null 2>&1 || return
  local branch=$(fzf-git-branch)
  if [ -z "$branch" ]; then
    echo "No branch selected."
    return
  fi
  # If branch name starts with 'remotes/' then it is a remote branch. By
  # using --track and a remote branch name, it is the same as:
  # git checkout -b branchName --track origin/branchName
  if [[ "$branch" = 'remotes/'* ]]; then
    git checkout --track $branch
  else
    git checkout $branch;
  fi
}
alias gcb=fzf-git-checkout

# ctrl r, has to come after fzf
export MCFLY_FUZZY=2
export MCFLY_DISABLE_MENU=TRUE
eval "$(mcfly init zsh)"
zle -N mcfly-history-widget
bindkey '^R' mcfly-history-widget
bindkey '®' mcfly-history-widget

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

if ! infocmp alacritty &> /dev/null; then
  export TERM=xterm-256color
fi
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1
export GEM_HOME=~/.gem
export GEM_PATH=~/.gem
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"


zsh-defer -c lwd


# Load Angular CLI autocompletion.
# source <(ng completion script)
export PIPENV_VENV_IN_PROJECT=1

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/ahoereth/.dart-cli-completion/zsh-config.zsh ]] && . /Users/ahoereth/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

function ci() {
  watch "gh workflow view container.yml | grep \"$(git branch --show-current)\" | awk -F'\t' '{print \$1, \$2, \$3, \$7}'"
}

