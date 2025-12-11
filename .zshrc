[ -f ~/.commonrc ] && source ~/.commonrc
[ -f ~/.secret ] && source ~/.secret

autoload -zU compinit && compinit
autoload -U add-zsh-hook
autoload -U promptinit; promptinit
prompt pure

export LANG=en_US.UTF-8
export LANG='en_US.UTF-8'
export EDITOR='vim'

### colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
else
  alias diff='diff'
fi

# bun completions
[ -s "/Users/shingosato/.bun/_bun" ] && source "/Users/shingosato/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# fnm
eval "$(fnm env --use-on-cd --shell zsh)"

# tenv
source $HOME/.tenv.completion.zsh


# Claude Code Slash Commands
export PATH="/Users/shingosato/.claude-code-slash-commands:$PATH"
alias ccsc-setup="/Users/shingosato/.claude-code-slash-commands/setup.sh"
alias ccsc-update="/Users/shingosato/.claude-code-slash-commands/utils/update.sh"
alias claude="/Users/shingosato/.claude/local/claude"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/shingosato/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# Added by Antigravity
export PATH="/Users/shingosato/.antigravity/antigravity/bin:$PATH"
