#!/bin/sh

set -eux

DOTFILES=$(cd $(dirname $0)/.. && pwd)
BACKUP_DIR="${HOME}/.dotfiles.backups"

backup() {
  if [ -e $1 ]; then
    BASENAME=$(basename $1)
    BACKUP_COUNT=$(find $BACKUP_DIR/$BASENAME* -maxdepth 0 2>/dev/null | wc -l | sed 's/ //g')

    mkdir -p "${BACKUP_DIR}"

    if [ $BACKUP_COUNT -ne '0' ]; then
      mv $1 $BACKUP_DIR/$BASENAME.$BACKUP_COUNT
    else
      mv $1 $BACKUP_DIR/$BASENAME
    fi
  fi
}

symlink() {
  local src="$1"
  local dst="$2"
  if [ -L "$dst" ]; then
    local current=$(readlink "$dst")
    if [ "$current" = "$src" ]; then
      return
    fi
    printf "Conflict: %s -> %s (new: %s). Overwrite? [y/N] " "$dst" "$current" "$src"
    read answer
    if [ "$answer" != "y" ]; then
      echo "Skipping $dst"
      return
    fi
  fi
  echo "Symlinking: ${src} -> ${dst}"
  ln -sfn "$src" "$dst"
}

# Symlink dotfiles (existing functionality)
echo "Setting up dotfiles..."
for f in $(find ${DOTFILES} -maxdepth 1 -type f -name .\*); do
  BASENAME=$(basename "$f")
  backup "${HOME}/${BASENAME}"
  symlink "$f" "${HOME}/${BASENAME}"
done

# Symlink specific directories and files
echo "Setting up specific file symlinks..."

# Function to add specific symlinks
# Usage: add_symlink "source_path" "destination_path"
add_symlink() {
  local source_path="$1"
  local dest_path="$2"
  local full_source="${DOTFILES}/${source_path}"

  # Check if source exists
  if [ -e "$full_source" ]; then
    # Create destination directory if it doesn't exist
    local dest_dir=$(dirname "$dest_path")
    mkdir -p "$dest_dir"

    # Backup existing file/link
    backup "$dest_path"

    # Create symlink
    symlink "$full_source" "$dest_path"
  else
    echo "Warning: Source file $full_source does not exist, skipping..."
  fi
}

# Define all specific symlinks here
# Just add a new line with: add_symlink "source_path" "destination_path"
add_symlink "claude/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"
add_symlink "claude/settings.json" "${HOME}/.claude/settings.json"
add_symlink "config/ccstatusline" "${HOME}/.config/ccstatusline"
add_symlink "config/nvim" "${HOME}/.config/nvim"
add_symlink "config/karabiner" "${HOME}/.config/karabiner"
add_symlink "config/gh-dash" "${HOME}/.config/gh-dash"
add_symlink "config/lazygit" "${HOME}/.config/lazygit"
add_symlink "config/zsh" "${HOME}/.config/zsh"
add_symlink "config/yazi/yazi.toml" "${HOME}/.config/yazi/yazi.toml"
add_symlink "config/yazi/package.toml" "${HOME}/.config/yazi/package.toml"
add_symlink "config/yazi/init.lua" "${HOME}/.config/yazi/init.lua"
add_symlink "config/yazi/keymap.toml" "${HOME}/.config/yazi/keymap.toml"

# claude/skills (per-directory symlinks)
if [ -d "${DOTFILES}/claude/skills" ]; then
  mkdir -p "${HOME}/.claude/skills"
  for d in "${DOTFILES}"/claude/skills/*/; do
    [ -d "$d" ] || continue
    BASENAME=$(basename "$d")
    symlink "$d" "${HOME}/.claude/skills/${BASENAME}"
  done
fi

# claude/agents (per-file symlinks)
if [ -d "${DOTFILES}/claude/agents" ]; then
  mkdir -p "${HOME}/.claude/agents"
  for f in "${DOTFILES}"/claude/agents/*; do
    [ -e "$f" ] || continue
    BASENAME=$(basename "$f")
    symlink "$f" "${HOME}/.claude/agents/${BASENAME}"
  done
fi

echo "Dotfiles setup complete!"

# Private dotfiles
PRIVATE_DOTFILES="${HOME}/dotfiles-private"
if [ -d "$PRIVATE_DOTFILES" ] && [ -f "$PRIVATE_DOTFILES/setup/dotfiles.sh" ]; then
  echo "Setting up private dotfiles..."
  /bin/sh "$PRIVATE_DOTFILES/setup/dotfiles.sh"
fi
