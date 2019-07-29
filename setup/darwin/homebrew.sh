#!/bin/sh

set -eux

DOTFILES=$(cd $(dirname $0)/../.. && pwd)
BREWFILES="${DOTFILES}/brewfiles"

[ $(command -v brew) ] || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew update
brew tap Homebrew/bundle
brew bundle --file="${BREWFILES}/default"
brew bundle --file="${BREWFILES}/fonts"
brew bundle --file="${BREWFILES}/casks"
brew bundle --file="${BREWFILES}/mas"
