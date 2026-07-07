# --- Source ---
[ -f ~/.commonrc ] && source ~/.commonrc
[ -f ~/.secret ] && source ~/.secret

# --- History ---
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# --- GPG ---
export GPG_TTY=$TTY

# --- Prompt ---
autoload -Uz add-zsh-hook
autoload -Uz promptinit && promptinit
prompt pure

# --- Completion ---
fpath=(
  ~/.zsh/completions
  ~/.docker/completions
  $fpath
)
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# --- Tools ---
eval "$(zoxide init zsh)"
eval "$(pyenv init - zsh)"
eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(rbenv init - --no-rehash zsh)"
eval "$(wtp shell-init zsh)"
eval "$(atuin init zsh --disable-up-arrow)"

[ -f ~/.tenv.completion.zsh ] && source ~/.tenv.completion.zsh
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# --- Plugins ---
[ -f ~/.config/zsh/zoxide.zsh ] && source ~/.config/zsh/zoxide.zsh
[ -f ~/.config/zsh/yazi.zsh ] && source ~/.config/zsh/yazi.zsh
[ -f ~/.config/zsh/wtpr.zsh ] && source ~/.config/zsh/wtpr.zsh

