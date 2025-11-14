#!/bin/bash

set -euo pipefail

usage() { echo "usage: git wad <branch> [base] [dir]" >&2; exit 2; }

b="${1:-}"; [[ -n "$b" ]] || usage
base_input="${2:-}"
dir="${3:-../$b}"

head_branch="$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}')"
base="${base_input:-origin/${head_branch:-main}}"

git fetch origin
git worktree add "$dir" -b "$b" "$base"
