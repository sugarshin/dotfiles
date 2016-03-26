alias la='ls -a'
alias ll='ls -l'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

fpath=(path/to/zsh-completions/src $fpath)

eval "$(rbenv init -)"
export PATH=$HOME/.rbenv/bin:$PATH

source /usr/local/share/zsh/site-functions/_aws

export SVN_EDITOR=vim
