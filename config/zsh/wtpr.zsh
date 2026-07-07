#!/usr/bin/env zsh

# Create (or jump into) a git worktree for a GitHub pull request via wtp.
# Usage: wtpr <pr-number|pr-url> [remote]   # remote defaults to origin
#
# Fetches pull/<N>/head into a local branch pr/<N>, makes a worktree for it,
# and cd's in (like the `wtp add` shell hook). Re-running just jumps to the
# existing worktree. Run from anywhere inside the target repo.
function wtpr() {
  local pr_arg="$1" remote="${2:-origin}" pr_num pr_branch dir

  if [[ -z "$pr_arg" ]]; then
    echo "usage: wtpr <pr-number|pr-url> [remote]" >&2
    return 2
  fi

  # PR number from a URL (…/pull/123[/…]) or a bare / #-prefixed number.
  pr_num=$(printf '%s\n' "$pr_arg" | sed -nE 's#.*/pull/([0-9]+).*#\1#p')
  [[ -n "$pr_num" ]] || pr_num=$(printf '%s\n' "$pr_arg" | grep -oE '[0-9]+' | head -n1)
  if [[ -z "$pr_num" ]]; then
    echo "wtpr: could not parse a PR number from '$pr_arg'" >&2
    return 1
  fi
  pr_branch="pr/${pr_num}"

  # Already have a worktree for this PR? Just jump into it.
  if dir=$(command wtp cd "$pr_branch" 2>/dev/null) && [[ -n "$dir" ]]; then
    cd "$dir"
    return
  fi

  # Fetch the PR head into a local branch, then create the worktree and cd in.
  git fetch "$remote" "+pull/${pr_num}/head:${pr_branch}" || return
  dir=$(command wtp add "$pr_branch" --quiet) || return
  [[ -n "$dir" ]] && cd "$dir"
}
