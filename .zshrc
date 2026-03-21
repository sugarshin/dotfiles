# --- Source ---
[ -f ~/.commonrc ] && source ~/.commonrc
[ -f ~/.secret ] && source ~/.secret

# --- Environment ---
export LANG='en_US.UTF-8'
export EDITOR='vim'

# --- Completion ---
fpath=(~/.zsh/completions $fpath)
fpath=(/Users/shingosato/.docker/completions $fpath)
autoload -zU compinit && compinit

# --- Prompt ---
autoload -U add-zsh-hook
autoload -U promptinit; promptinit
prompt pure

# --- Tools ---
# zoxide
eval "$(zoxide init zsh)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# fnm
eval "$(fnm env --use-on-cd --shell zsh)"

# tenv
source $HOME/.tenv.completion.zsh

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/Users/shingosato/.bun/_bun" ] && source "/Users/shingosato/.bun/_bun"

# --- Plugins ---
[ -f ~/.config/zsh/zoxide.zsh ] && source ~/.config/zsh/zoxide.zsh
[ -f ~/.config/zsh/workspace.zsh ] && source ~/.config/zsh/workspace.zsh

# --- Integrations ---
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
export PATH="/Users/shingosato/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
