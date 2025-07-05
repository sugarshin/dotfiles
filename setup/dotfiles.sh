#!/bin/sh

set -eux

DOTFILES=$(cd $(dirname $0)/.. && pwd)
BACKUP_DIR="${HOME}/.dotfiles.backups"

backup() {
  if [ -e $1 ]; then
    BASENAME=$(basename $1)
    BACKUP_COUNT=$(find $BACKUP_DIR/$BASENAME* -maxdepth 0 2> /dev/null | wc -l | sed 's/ //g')

    mkdir -p "${BACKUP_DIR}"

    if [ $BACKUP_COUNT -ne '0' ]; then
      mv $1 $BACKUP_DIR/$BASENAME.$BACKUP_COUNT
    else
      mv $1 $BACKUP_DIR/$BASENAME
    fi
  fi
}

symlink() {
  ORG=$1
  DST=$2
  echo "Symlinking: ${ORG} -> ${DST}"
  ln -sf "$ORG" "$DST"
}

# Symlink dotfiles (existing functionality)
echo "Setting up dotfiles..."
for f in $(find ${DOTFILES} -maxdepth 1 -type f -name .\*) ; do
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
add_symlink "claude/settings.json" "${HOME}/.claude/settings.json"
add_symlink "claude/scripts/deny-check.sh" "${HOME}/.claude/scripts/deny-check.sh"

echo "Dotfiles setup complete!"
