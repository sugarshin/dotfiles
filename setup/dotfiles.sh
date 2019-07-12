set -eux

DOTFILES=$(cd $(dirname $0)/.. && pwd)

for d in $DOTFILES/.* ; do
  /bin/sh $d
  ln -s $d $(basename $d)
done
