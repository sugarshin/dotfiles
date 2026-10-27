#!/usr/bin/env zsh

# Leave a git worktree and remove it in one step.
# Usage: wtrm [-y] [--with-branch [--force-branch]] [worktree-name]
#
# Replaces the usual `wtp cd` + `wtp remove <name> --force` pair. The common
# case is running `wtrm` with no arguments from inside the worktree you are
# done with: it names the target, asks for confirmation (defaults to yes, so a
# bare Enter proceeds), cd's back to the main worktree and removes it with
# --force. -y / --yes skips the prompt; --with-branch also deletes the branch
# and --force-branch deletes it even when unmerged, as with `wtp remove`.
#
# A name is resolved with `wtp cd`, but the removal goes through
# `git worktree remove <path>` instead of `wtp remove <name>`: wtp (v2.10.3)
# takes the first worktree in `git worktree list` whose branch, name or
# basename matches, so with both `chore/foo` and `foo` around, `wtp remove foo`
# can remove `chore/foo`.
function wtrm() {
  local name="" arg main dir branch yes="" reply="" with_branch="" force_branch="" flag

  for arg in "$@"; do
    case "$arg" in
      -y|--yes)       yes=1 ;;
      --with-branch)  with_branch=1 ;;
      --force-branch) force_branch=1 ;;
      -f|--force)     ;;   # removal is always forced
      -*)
        print -u2 -- "wtrm: unknown option: $arg"
        return 1
        ;;
      *)
        if [[ -n "$name" ]]; then
          print -u2 -- "wtrm: too many arguments"
          return 1
        fi
        name="$arg"
        ;;
    esac
  done
  if [[ -n "$force_branch" && -z "$with_branch" ]]; then
    print -u2 -- "wtrm: --force-branch requires --with-branch"
    return 1
  fi

  main=$(command wtp cd 2>/dev/null)
  if [[ -z "$main" ]]; then
    print -u2 -- "wtrm: not inside a git repository"
    return 1
  fi

  # No name given: the worktree we are currently standing in.
  if [[ -z "$name" ]]; then
    dir=$(git rev-parse --show-toplevel 2>/dev/null)
  else
    dir=$(command wtp cd "$name" 2>/dev/null)
    if [[ -z "$dir" ]]; then
      print -u2 -- "wtrm: no such worktree: $name"
      return 1
    fi
  fi
  if [[ -z "$dir" || "${dir:A}" == "${main:A}" ]]; then
    print -u2 -- "wtrm: refusing to remove the main worktree; pass a worktree name"
    return 1
  fi

  branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null)

  if [[ -z "$yes" ]]; then
    print -r -- "wtrm: remove worktree ${dir}"
    print -r -- "      branch: ${branch:-(detached HEAD)}"
    if [[ -n "$with_branch" && -n "$branch" ]]; then
      print -r -- "      the branch will be deleted too (--with-branch)"
    fi
    if [[ ! -t 0 ]]; then
      print -u2 -- "wtrm: not interactive; pass -y to skip the confirmation"
      return 1
    fi
    if ! read -k 1 "reply?Proceed? [Y/n] "; then
      print
      print -u2 -- "wtrm: aborted"
      return 1
    fi
    print
    if [[ "$reply" == [nN] ]]; then
      print -u2 -- "wtrm: aborted"
      return 1
    fi
  fi

  cd "$main" || return
  if ! git -C "$main" worktree remove --force "$dir"; then
    [[ -d "$dir" ]] && cd "$dir"
    return 1
  fi
  print -r -- "wtrm: removed ${dir}"

  if [[ -n "$with_branch" && -n "$branch" ]]; then
    flag=-d
    [[ -n "$force_branch" ]] && flag=-D
    git -C "$main" branch "$flag" "$branch"
  fi
}
