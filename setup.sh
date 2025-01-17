#!/bin/sh

set -eux

DOTFILES=$(cd $(dirname $0) && pwd)

setup() {
  pattern=$1
  for f in $pattern ; do
    /bin/sh "$f"
  done
}

setup "$DOTFILES"/setup/*.sh

# if [ "$(uname -s)" = 'Darwin' ]; then
#   setup "$DOTFILES/setup/darwin/*.sh"
#   setup "$DOTFILES/setup/darwin/post/*.sh"
# fi
