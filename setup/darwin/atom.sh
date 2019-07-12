#!/bin/sh

DOTFILES=$(cd $(dirname $0)/../.. && pwd)

apm install --packages-file "${DOTFILES}/Atomfile"
apm upgrade --confirm=false
apm list -bi > "${DOTFILES}/Atomfile"
