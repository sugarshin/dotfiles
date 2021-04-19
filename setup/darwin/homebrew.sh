#!/bin/sh

set -eux

DOTFILES=$(cd $(dirname $0)/../.. && pwd)
BREWFILES="${DOTFILES}/brewfiles"

[ $(command -v brew) ] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew update
brew tap Homebrew/bundle
brew bundle --file="${BREWFILES}/default"
brew bundle --file="${BREWFILES}/cask"
brew bundle --file="${BREWFILES}/mas"
