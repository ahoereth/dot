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
  zgen oh-my-zsh plugins/thefuck
  zgen oh-my-zsh plugins/wd
  zgen oh-my-zsh plugins/last-working-dir

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
  $GOPATH/bin
  ~/bin
  /usr/local/sbin
  $DOT_PATH/bin
  ~/.node_modules/bin
  /usr/local/miniconda3/bin
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


### MATLAB with OpenJDK
if ! type "$matlab" > /dev/null; then
  export MATLAB_JAVA=/usr/lib/jvm/java-8-openjdk/jre
fi


### ccat colorized cat
if ! type "$ccat" > /dev/null; then
  alias cat=ccat
  alias json='python -m json.tool | ccat'
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

#export FBFONT=/usr/share/kbd/consolefonts/ter-216n.psf.gz

if ! type pbcopy > /dev/null; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
fi
alias psaux='ps aux | sort -n -r -k 3 | cut -c -$(tput cols)'
alias lx="la | awk '{k=0;for(i=0;i<=8;i++)k+=((substr(\$1,i+2,1)~/[rwx]/) \
                   *2^(8-i));if(k)printf(\"%0o \",k);print}'"
alias venv='source .venv/bin/activate'
alias dev='cd $HOME/repos'
alias myip="curl -s https://api.ipify.org/"
alias cpip="myip | pbcopy"

# make option - left and option - right skip words
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

export HOMEBREW_INSTALL_CLEANUP=1
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8


PS1='%{$fg_bold[yellow]%}%c%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[magenta]%}%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[magenta]%} %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[magenta]%} %{$fg[green]%}✓"

RPS1='%{$fg[magenta]%}%T%{$reset_color%}'


# zprof
