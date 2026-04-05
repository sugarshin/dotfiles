# --- Homebrew (must be first - sets PATH, HOMEBREW_PREFIX, etc.) ---
eval "$(/opt/homebrew/bin/brew shellenv)"

# --- Environment ---
export LANG="en_US.UTF-8"
export EDITOR="nvim"

# --- Tool Roots ---
export PYENV_ROOT="$HOME/.pyenv"
export BUN_INSTALL="$HOME/.bun"
export ANDROID_HOME="$HOME/Library/Android/sdk"

# --- PATH ---
typeset -U path
path=(
  $HOME/.local/bin
  $HOME/.antigravity/antigravity/bin
  $BUN_INSTALL/bin
  $PYENV_ROOT/bin
  /opt/homebrew/opt/postgresql@17/bin
  $ANDROID_HOME/emulator
  $ANDROID_HOME/platform-tools
  $HOME/bin
  $DOTFILES/bin
  $HOME/.claude/local
  $path
)
