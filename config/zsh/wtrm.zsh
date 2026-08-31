#!/usr/bin/env zsh

# Leave a git worktree and remove it in one step, via wtp.
# Usage: wtrm [-y] [worktree-name] [wtp remove options...]
#
# Replaces the usual `wtp cd` + `wtp remove <name> --force` pair. The common
# case is running `wtrm` with no arguments from inside the worktree you are
# done with: it names the target, asks for confirmation, cd's back to the main
# worktree (wtp remove refuses while you are inside the target) and removes it
# with --force. -y / --yes skips the prompt; other flags (e.g. --with-branch)
# pass through to `wtp remove`.
function wtrm() {
  local name="" arg main top dir branch n yes=""
  local -a opts names

  for arg in "$@"; do
    case "$arg" in
      -y|--yes) yes=1 ;;
      -*)       opts+=("$arg") ;;
      *)        if [[ -z "$name" ]]; then name="$arg"; else opts+=("$arg"); fi ;;
    esac
  done

  main=$(command wtp cd 2>/dev/null)
  if [[ -z "$main" ]]; then
    print -u2 -- "wtrm: not inside a git repository"
    return 1
  fi

  # No name given: resolve the worktree we are currently standing in.
  if [[ -z "$name" ]]; then
    top=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -z "$top" || "${top:A}" == "${main:A}" ]]; then
      print -u2 -- "wtrm: already in the main worktree; pass a worktree name"
      return 1
    fi
    names=(${(f)"$(command wtp list -q 2>/dev/null)"})
    for n in $names; do
      [[ "$n" == "@" ]] && continue   # the main worktree
      dir=$(command wtp cd "$n" 2>/dev/null)
      if [[ -n "$dir" && "${dir:A}" == "${top:A}" ]]; then
        name="$n"
        break
      fi
    done
    if [[ -z "$name" ]]; then
      print -u2 -- "wtrm: '$top' is not a wtp-managed worktree"
      return 1
    fi
  else
    dir=$(command wtp cd "$name" 2>/dev/null)
    if [[ -z "$dir" ]]; then
      print -u2 -- "wtrm: no such worktree: $name"
      return 1
    fi
  fi

  branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)

  if [[ -z "$yes" ]]; then
    print -r -- "wtrm: remove worktree '${name}'${branch:+ (branch ${branch})}"
    print -r -- "      ${dir}"
    if (( ${opts[(I)--with-branch]} )); then
      print -r -- "      the branch will be deleted too (--with-branch)"
    fi
    if [[ ! -t 0 ]]; then
      print -u2 -- "wtrm: not interactive; pass -y to skip the confirmation"
      return 1
    fi
    if ! read -q "?Proceed? [y/N] "; then
      print
      print -u2 -- "wtrm: aborted"
      return 1
    fi
    print
  fi

  cd "$main" || return
  if ! command wtp remove --force "${opts[@]}" "$name"; then
    [[ -n "$dir" && -d "$dir" ]] && cd "$dir"
    return 1
  fi
}
