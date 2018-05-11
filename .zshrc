#
# ~/.zshrc
#

export DOT_PATH=~/repos/dot


setopt autocd
setopt extendedglob


# ANTIGEN
source /usr/local/opt/antigen/share/antigen/antigen.zsh
antigen init ${HOME}/.antigenrc


### Path
typeset -U path
path=(
  ~/bin
  $DOT_PATH/bin
  ~/.node_modules/bin
  ~/.gem/ruby/2.3.0/bin
  /usr/local/miniconda3/bin
  /Library/TeX/texbin
  $path[@]
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
if [[ "$SSH_AGENT_PID" == "" ]]; then
  eval $(ssh-agent) > /dev/null
fi


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
