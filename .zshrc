#
# ~/.zshrc
#

# zmodload zsh/zprof

export DOT_PATH=~/repos/dot

source $DOT_PATH/tools/sandboxd

setopt autocd
setopt extendedglob

# zsh plugins
ZGEN_RESET_ON_CHANGE=(${DOT_PATH}/.zshrc)
source "${DOT_PATH}/tools/zgen/zgen.zsh"
if ! zgen saved; then
  zgen oh-my-zsh

  #zgen oh-my-zsh plugins/compleat
  zgen oh-my-zsh plugins/command-not-found
  zgen oh-my-zsh plugins/docker
  zgen oh-my-zsh plugins/wd
  zgen oh-my-zsh plugins/last-working-dir
  zgen oh-my-zsh plugins/zsh-interactive-cd

  zgen load zsh-users/zsh-syntax-highlighting
  zgen load zsh-users/zsh-history-substring-search
  zgen load zsh-users/zsh-autosuggestions

  zgen save
fi

bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

### Path
typeset -U path
export GOPATH=$HOME/go
path=(
  ~/bin
  /usr/local/sbin
  $DOT_PATH/bin
  ~/.node_modules/bin
  /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin
  /Library/TeX/texbin
  $path[@]
  $HOME/repos/flutter/bin
  /usr/local/opt/ruby@2.6/bin
)


### History
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS


### SSH Agent
# Start ssh agent if not started already
#if [[ "$SSH_AGENT_PID" == "" ]]; then
#  eval $(ssh-agent) > /dev/null
#fi


# eval "$(pandoc --bash-completion)"



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
fi

### git-checkout-before DATETIME BRANCH
# Checkout specified git branch at the latest commit before DATETIME
git-checkout-before() {
  echo 'git checkout `git rev-list -n 1 --before="'$1'" '$2'`\n'
  git checkout `git rev-list -n 1 --before="$1" $2`
}


### bg COMMAND
# Run COMMAND in backgrund and suppress its output.
bg() {
  echo "$@ > /dev/null 2>&1 &\n"
  $@ > /dev/null 2>&1 &
}


### toggleservice SERVICENAME
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


### Better man
man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
      man "$@"
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


if ! type pbcopy > /dev/null; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi
alias psaux='ps aux | sort -n -r -k 3 | cut -c -$(tput cols)'
alias lx="la | awk '{k=0;for(i=0;i<=8;i++)k+=((substr(\$1,i+2,1)~/[rwx]/) \
                   *2^(8-i));if(k)printf(\"%0o \",k);print}'"
alias dev='cd $HOME/repos'
alias myip="curl -s https://api.ipify.org/"
alias cpip="myip | pbcopy"
alias find="find $1 2>/dev/null"

# . .venv/bin/activate
# eval $(thefuck --alias)

# make option - left and option - right skip words
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# Delete whole string part using alt - del
backward-kill-dir () {
  local WORDCHARS=${WORDCHARS/\/}
  zle backward-kill-word
}
zle -N backward-kill-dir
bindkey '^[^?' backward-kill-dir

export HOMEBREW_INSTALL_CLEANUP=1
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Below needs to be migrated to macos
if [ "$(uname)" = "Linux" ]; then
  # pyenv
  export PYENV_ROOT="$DOT_PATH/tools/pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
  fi

  if [ -d "/usr/local/cuda-10.1" ]; then
    export LD_LIBRARY_PATH=/usr/local/cuda-10.1/extras/CUPTI/lib64:$LD_LIBRARY_PATH
    export PATH=/usr/local/cuda-10.1/bin:$PATH
    export CUDA_INC_DIR=/usr/local/cuda/include
  fi
fi

# Show only remote hostnames.
if [ "$(hostname)" = "padua.local" ]; then
  name=
  icon=
else
  name="$(hostname) "
  icon="⛵ "
fi

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%} ✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%} ✓"

PS1='$icon%{$fg_bold[yellow]%}%2~ %{$reset_color%}$(git_prompt_info) '
RPS1='%{$fg[red]%}$name%{$fg[magenta]%}%T%{$reset_color%}'


# zprof

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


PS1=$(echo $PS1 | sed 's/(base) //')
