#!/bin/bash

set -euo pipefail

usage() {
    cat >&2 <<EOF
usage: git wad <branch> [base] [dir]

Create a new worktree for the given branch.

Arguments:
  branch  Branch name to create or checkout
  base    Base branch/commit for new branch (e.g., origin/main)
  dir     Worktree directory (default: ../<branch>)

Behavior:
  - If 'base' is specified: create new branch from base (original behavior)
  - If local branch exists: use existing local branch
  - If origin/<branch> exists: create tracking branch from remote
  - Otherwise: create new branch from origin/<default-branch>

Examples:
  git wad feature-x                  # New branch from origin/main
  git wad feature-x origin/develop   # New branch from origin/develop
  git wad pr-branch                  # Checkout existing remote PR branch
EOF
    exit 2
}

b="${1:-}"; [[ -n "$b" ]] || usage
base_input="${2:-}"
dir="${3:-../$b}"

head_branch="$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}')"
base="${base_input:-origin/${head_branch:-main}}"

git fetch origin

if [[ -n "$base_input" ]]; then
    # base explicitly specified → original behavior (create new branch)
    git worktree add "$dir" -b "$b" "$base"
elif git show-ref --verify --quiet "refs/heads/$b"; then
    # local branch exists → use it
    git worktree add "$dir" "$b"
elif git show-ref --verify --quiet "refs/remotes/origin/$b"; then
    # remote branch exists → create tracking branch
    git worktree add "$dir" -b "$b" "origin/$b"
else
    # neither exists → create new branch from default base
    git worktree add "$dir" -b "$b" "$base"
fi
