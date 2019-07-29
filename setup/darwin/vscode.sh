#!/bin/sh

set -eux

DOTFILES=$(cd $(dirname $0)/../.. && pwd)
VSCODE_FILES="${DOTFILES}/vscode"
VSCODE_SETTING_DIR="${HOME}/Library/Application Support/Code/User"
BACKUP_DIR="${HOME}/.dotfiles.backups/vscode"

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
  ln -s "${ORG}" "${DST}"
}

if [ -d '/Applications/Visual Studio Code.app' ]; then
  cat "${VSCODE_FILES}/Extensions" | while read -r EXT; do
    code --install-extension $EXT
  done

  code --list-extensions > "${VSCODE_FILES}/Extensions"

  if [ -d "${HOME}/Library" ]; then
    for f in ${VSCODE_FILES}/User/* ; do
      BASENAME=$(basename $f)
      backup "${VSCODE_SETTING_DIR}/${BASENAME}"
      symlink $f "${VSCODE_SETTING_DIR}/${BASENAME}"
    done
  fi
else
  echo 'Visual Studio Code has not been installed.'
fi
