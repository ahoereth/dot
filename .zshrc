#
# ~/.zshrc
#

export DOT_PATH=~/dot

setopt autocd
setopt extendedglob
bindkey -e # emacs mode


### oh-my-zsh
export ZSH=$DOT_PATH/oh-my-zsh
export VIRTUAL_ENV_DISABLE_PROMPT=1
ZSH_CUSTOM=$DOT_PATH/shell
ZSH_THEME="theme"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
plugins=(git npm wd pip python last-working-dir compleat)
source $ZSH/oh-my-zsh.sh


### History
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS


### SSH Agent Initialization
if ! pgrep -u $USER ssh-agent > /dev/null; then
  ssh-agent > ~/.ssh-agent-thing
fi
if [[ "$SSH_AGENT_PID" == "" ]]; then
  eval $(<~/.ssh-agent-thing)
fi


### Compleat
autoload -Uz compinit bashcompinit
compinit
bashcompinit
source $(find /usr/local/share -name compleat_setup)


### The Fuck
if ! type "$thefuck" > /dev/null; then
  eval $(thefuck --alias)
  alias FUCK='fuck'
fi


### MATLAB with OpenJDK
if ! type "$matlab" > /dev/null; then
  export MATLAB_JAVA=/usr/lib/jvm/java-8-openjdk/jre
fi


### ccat colorized cat
if ! type "$ccat" > /dev/null; then
  alias cat=ccat
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


### zsh-syntax-highlighting
source $DOT_PATH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


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
