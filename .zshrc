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
  zgen oh-my-zsh plugins/aws
  zgen oh-my-zsh plugins/compleat
  zgen oh-my-zsh plugins/command-not-found
  zgen oh-my-zsh plugins/docker
  zgen oh-my-zsh plugins/docker-compose
  zgen oh-my-zsh plugins/git
  zgen oh-my-zsh plugins/history
  zgen oh-my-zsh plugins/pip
  zgen oh-my-zsh plugins/pylint
  zgen oh-my-zsh plugins/python
  zgen oh-my-zsh plugins/terraform
  zgen oh-my-zsh plugins/thefuck
  zgen oh-my-zsh plugins/wd
  zgen oh-my-zsh plugins/autopep8
  zgen oh-my-zsh plugins/last-working-dir

  zgen load zsh-users/zsh-completions
  zgen load zsh-users/zsh-history-substring-search
  zgen load zsh-users/zsh-autosuggestions

  zgen load shoeffner/dotfiles fae.zsh-theme

  zgen save
fi


### Path
typeset -U path
export GOPATH=$HOME/go
path=(
  $GOPATH/bin
  ~/bin
  $DOT_PATH/bin
  ~/.node_modules/bin
  ~/.gem/ruby/2.3.0/bin
  /usr/local/miniconda3/bin
  /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin
  /Library/TeX/texbin
  $path[@]
  $HOME/repos/flutter/bin
)

# export JAVA_HOME=$(/usr/libexec/java_home)
alias skim="open -a skim"

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

# zprof

zgen load zsh-users/zsh-syntax-highlighting
