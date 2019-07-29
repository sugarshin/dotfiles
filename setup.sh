#!/bin/sh

set -eux

DOTFILES=$(cd $(dirname $0) && pwd)

for f in $DOTFILES/setup/*.sh ; do
  /bin/sh $f
done

if [ $(uname -s) = 'Darwin' ]; then
  for f in $DOTFILES/setup/darwin/*.sh ; do
    /bin/sh $f
  done
fi
