#!/bin/bash

set -euo pipefail

usage() {
    cat >&2 <<EOF
usage: git wrm [options] [branch] [dir]

Remove a worktree and optionally delete the branch.

Arguments:
  branch  Branch name of the worktree to remove
  dir     Worktree directory (default: ../<branch>)

Options:
  -a, --all     Remove all worktrees with merged/squashed branches
  -f, --force   Force removal even if worktree is dirty
  -b, --branch  Also delete the local branch after removing worktree
  -n, --dry-run Show what would be removed without removing

Examples:
  git wrm feature-x           # Remove worktree only
  git wrm feature-x -b        # Remove worktree and delete branch
  git wrm feature-x -f        # Force remove dirty worktree
  git wrm feature-x -fb       # Force remove and delete branch
  git wrm -a                  # Remove all merged worktrees and branches
  git wrm -an                 # Dry run: show merged worktrees
EOF
    exit 2
}

force=false
delete_branch=false
remove_all=false
dry_run=false
branch=""
dir=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force)
            force=true
            shift
            ;;
        -b|--branch)
            delete_branch=true
            shift
            ;;
        -a|--all)
            remove_all=true
            delete_branch=true  # -a implies -b
            shift
            ;;
        -n|--dry-run)
            dry_run=true
            shift
            ;;
        -fb|-bf)
            force=true
            delete_branch=true
            shift
            ;;
        -an|-na)
            remove_all=true
            delete_branch=true
            dry_run=true
            shift
            ;;
        -af|-fa)
            remove_all=true
            delete_branch=true
            force=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage
            ;;
        *)
            if [[ -z "$branch" ]]; then
                branch="$1"
            elif [[ -z "$dir" ]]; then
                dir="$1"
            else
                echo "Too many arguments" >&2
                usage
            fi
            shift
            ;;
    esac
done

# Check if a branch is squash-merged into base
is_squash_merged() {
    local base="$1"
    local branch="$2"
    local merge_base
    merge_base=$(git merge-base "$base" "$branch" 2>/dev/null) || return 1
    local tree_commit
    tree_commit=$(git commit-tree "$(git rev-parse "${branch}^{tree}")" -p "$merge_base" -m _) || return 1
    [[ $(git cherry "$base" "$tree_commit" 2>/dev/null) == "-"* ]]
}

remove_worktree() {
    local wt_dir="$1"
    local wt_branch="$2"

    if $dry_run; then
        echo "[dry-run] Would remove worktree: $wt_dir (branch: $wt_branch)"
        return
    fi

    echo "Removing worktree: $wt_dir (branch: $wt_branch)"

    if $force; then
        git worktree remove --force "$wt_dir"
    else
        git worktree remove "$wt_dir"
    fi

    if $delete_branch; then
        if git show-ref --verify --quiet "refs/heads/$wt_branch"; then
            echo "Deleting branch: $wt_branch"
            git branch -D "$wt_branch"
        fi
    fi
}

if $remove_all; then
    # Get current branch as base for merge detection
    base=$(git branch --show-current)
    if [[ -z "$base" ]]; then
        echo "Error: Not on any branch. Cannot detect merged branches." >&2
        exit 1
    fi

    # Get the main worktree directory to exclude it
    main_worktree=$(git worktree list --porcelain | head -1 | sed 's/worktree //')

    found=false
    while IFS= read -r line; do
        # Parse worktree list output: /path/to/worktree  abc1234 [branch-name]
        wt_dir=$(echo "$line" | awk '{print $1}')
        wt_branch=$(echo "$line" | sed -n 's/.*\[\(.*\)\]/\1/p')

        # Skip main worktree and entries without branch
        [[ "$wt_dir" == "$main_worktree" ]] && continue
        [[ -z "$wt_branch" ]] && continue
        # Skip current base branch
        [[ "$wt_branch" == "$base" ]] && continue

        if is_squash_merged "$base" "$wt_branch"; then
            found=true
            remove_worktree "$wt_dir" "$wt_branch"
        fi
    done < <(git worktree list)

    if ! $found; then
        echo "No merged worktrees found."
    elif ! $dry_run; then
        echo "Done."
    fi
else
    # Single branch mode
    [[ -n "$branch" ]] || usage

    dir="${dir:-../$branch}"

    if [[ ! -d "$dir" ]]; then
        echo "Worktree directory not found: $dir" >&2
        exit 1
    fi

    remove_worktree "$dir" "$branch"

    if ! $dry_run; then
        echo "Done."
    fi
fi
