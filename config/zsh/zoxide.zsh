#!/usr/bin/env zsh

# Resolve the absolute path of git-common-dir for the given directory.
# All worktrees of the same repo share the same git-common-dir.
function _git_common_dir() {
    local dir="${1:-.}"
    local common_dir
    common_dir=$(git -C "$dir" rev-parse --git-common-dir 2>/dev/null) || return 1
    # Resolve to absolute path (git may return relative)
    (cd "$dir" && cd "$common_dir" && pwd -P)
}

# If zoxide_result is in a sibling worktree of the same repo, remap to
# the equivalent path in the current worktree and cd there.
# Returns 0 if remapped, 1 if no remapping needed.
function _remap_worktree_path() {
    local zoxide_result="$1"
    local current_toplevel current_common target_toplevel target_common

    current_toplevel=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
    current_common=$(_git_common_dir "$current_toplevel") || return 1

    [[ -d "$zoxide_result" ]] || return 1
    target_toplevel=$(git -C "$zoxide_result" rev-parse --show-toplevel 2>/dev/null) || return 1
    target_common=$(_git_common_dir "$target_toplevel") || return 1

    # Same repo, different worktree?
    [[ "$target_common" == "$current_common" && "$target_toplevel" != "$current_toplevel" ]] || return 1

    local relative_path="${zoxide_result#$target_toplevel}"
    relative_path="${relative_path#/}"

    if [[ -z "$relative_path" ]]; then
        cd "$current_toplevel"
    elif [[ -d "$current_toplevel/$relative_path" ]]; then
        cd "$current_toplevel/$relative_path"
    else
        cd "$current_toplevel"
    fi
    return 0
}

# Worktree-aware zoxide wrapper
function z() {
    local zoxide_result
    zoxide_result=$(zoxide query -- "$@" 2>/dev/null) || {
        __zoxide_z "$@"
        return
    }

    _remap_worktree_path "$zoxide_result" && return 0
    __zoxide_z "$@"
}

# Worktree-aware zoxide interactive wrapper
function zi() {
    local zoxide_result
    zoxide_result=$(zoxide query -i -- "$@" 2>/dev/null)
    local exit_code=$?
    if [[ $exit_code -ne 0 ]] || [[ -z "$zoxide_result" ]]; then
        return $exit_code
    fi

    _remap_worktree_path "$zoxide_result" && return 0
    cd "$zoxide_result"
}
