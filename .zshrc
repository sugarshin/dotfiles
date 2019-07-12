# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

unsetopt CORRECT

alias la='ls -a'
alias ll='ls -l'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

fpath=(path/to/zsh-completions/src $fpath)

source /usr/local/share/zsh/site-functions/_aws

export SVN_EDITOR=vim

# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

# rbenv
eval "$(rbenv init -)"

# goenv
export GOPATH=$HOME/.go
export GOENV_ROOT=$HOME/.goenv
export PATH=bin:$GOENV_ROOT/bin:$GOPATH/bin:$PATH
eval "$(goenv init -)"

# python
export PATH="/usr/local/opt/python/libexec/bin:$PATH"
export CORRECT_IGNORE='_*'
export CORRECT_IGNORE_FILE='.*'
