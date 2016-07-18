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
# run COMMAND in backgrund and suppress its output.
bg() {
  echo "$@ > /dev/null 2>&1 &\n"
  $@ > /dev/null 2>&1 &
}
