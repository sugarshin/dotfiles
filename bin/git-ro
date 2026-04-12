#!/bin/bash

set -euo pipefail

usage() {
  echo "usage: git ro <newbase> <upstream> [branch]" >&2
  echo "ex:    git ro origin/main origin/main feature/login-ui" >&2
  echo "ex:    git ro origin/main origin/main   # target is current branch" >&2
  exit 2
}

newbase="${1:-}"
upstream="${2:-}"
target="${3:-}"

[[ -n "$newbase" && -n "$upstream" ]] || usage

# if target is not specified, use current branch
if [[ -z "$target" ]]; then
  target="$(git rev-parse --abbrev-ref HEAD)"
fi

# show progress
echo "+ git rebase --onto $newbase $upstream $target"

git rebase --onto "$newbase" "$upstream" "$target"
