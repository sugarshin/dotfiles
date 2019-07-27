set -eux

DOTFILES=$(cd $(dirname $0)/.. && pwd)
BACKUP_DIR="${HOME}/.dotfiles.backups"

backup() {
  if [[ -e $1 ]]; then
    BASENAME=$(basename $1)
    BACKUP_COUNT=$(find $BACKUP_DIR/$BASENAME* -maxdepth 0 2> /dev/null | wc -l | sed 's/ //g')

    if [[ $dotfile_count -ne '0' ]]; then
      mv $1 $BACKUPDIR/$BASENAME.$BACKUP_COUNT
    else
      mv $1 $BACKUPDIR/$BASENAME
    fi
  fi
}

symlink() {
  ORG=$1
  DST=$2
  echo "Symlinking: ${ORG} -> ${DST}"
  ln -s $ORG $DST
}

for f in $(find ${DOTFILES} -maxdepth 1 -type f -name .\*) ; do
  BASENAME=$(basename $f)
  backup "${HOME}/.${BASENAME}"
  symlink $f "${HOME}/.${BASENAME}"
done
