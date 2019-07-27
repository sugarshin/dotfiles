set -eux

DOTFILES=$(cd $(dirname $0)/../.. && pwd)
VSCODE_FILES="${DOTFILES}/vscode"
VSCODE_SETTING_DIR=~/Library/Application\ Support/Code/User

if [ -d '/Applications/Visual Studio Code.app' ]; then
  cat "${VSCODE_FILES}/Extensions" | while read -r EXT; do
    code --install-extension $EXT
  done

  code --list-extensions > "${VSCODE_FILES}/Extensions"

  if [ -d "${HOME}/Library" ]; then
    mkdir -p "${HOME}/Library/Application Support"
    rm -rf "${HOME}/Library/Application Support/Code/User"
    ln -s "${VSCODE_FILES}/vscode/User" "${HOME}/Library/Application Support/Code/User"
  fi
else
  echo 'Visual Studio Code has not been installed.'
fi
