# https://superuser.com/questions/515565/how-to-create-alias-for-minus-sign
alias -- -="cd -" # make it easier to go to the previous directory
alias ..='cd ..'
alias c='clear'
alias g=git
alias gst='git status -bs'
alias ls='ls -aF --color'
alias vi=vim

alias python=/usr/bin/python
alias pip=/usr/bin/pip2

#export NODE_PATH=~/.node_modules/lib/node_modules:$NODE_PATH
#unset MANPATH
#export MANPATH="~/.node_modules/share/man:$(manpath)"

#NPMPATH=$HOME/.node_modules/bin
GEMPATH=$(ruby -rubygems -e 'puts Gem.user_dir')/bin
NODE_PATH=~/.node_modules/bin

# to allow gs / ghostscript to work
export GS_DEVICE=display

export EDITOR=vim
export PYTHON=python
export PATH=$PATH:$GEMPATH:$NODE_PATH
