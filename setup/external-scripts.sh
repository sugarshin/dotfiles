#!/bin/sh

set -eux

DOTFILES=$(cd $(dirname $0)/.. && pwd)
MANIFEST="${DOTFILES}/external-scripts.tsv"

while IFS=$(printf '\t') read -r url dest; do
  case "$url" in \#*|"") continue ;; esac
  dest=$(eval echo "$dest")
  mkdir -p "$(dirname "$dest")"
  echo "Downloading: $url -> $dest"
  curl -fsSL "$url" -o "$dest"
done < "$MANIFEST"
