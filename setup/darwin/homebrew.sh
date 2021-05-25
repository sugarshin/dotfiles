#!/bin/sh

set -eux

DOTFILES=$(cd $(dirname $0)/../.. && pwd)
BREWFILES="${DOTFILES}/brewfiles"

[ $(command -v brew) ] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew update
brew bundle --file="${BREWFILES}/Brewfile"
if [ -f "${BREWFILES}/Brewfile.local" ]; then
  brew bundle --file="${BREWFILES}/Brewfile.local"
fi
