# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal macOS dotfiles. Not an application — a collection of config files, shell scripts, and a symlink-based installer that materializes them into `$HOME`. The canonical checkout location is `~/dotfiles` (exported as `$DOTFILES` in `.zshenv`), so the repo must live there.

## Bootstrapping and updates

```sh
sh setup.sh        # full setup from a fresh clone
sh install.sh      # pulls latest (hard reset to origin/master) then runs setup.sh
```

`setup.sh` executes every `setup/*.sh` in order, then appends Darwin-only steps. Re-running is safe: the symlink helper (`setup/dotfiles.sh`) compares existing targets and backs up conflicts to `~/.dotfiles.backups` before replacing them (numbered suffixes on repeat).

## The symlink pipeline (how files reach $HOME)

`setup/dotfiles.sh` is the core of the repo. Understanding it matters because adding a new config file almost always means editing this script:

1. **Top-level dotfiles** — every `.<name>` file at the repo root (e.g. `.zshrc`, `.gitconfig`, `.commonrc`) is auto-symlinked to `~/<name>`. To add one, just drop it in the root.
2. **Targeted symlinks** — explicit `add_symlink "source" "dest"` calls map specific paths under `config/` and `claude/` into `~/.config/*` and `~/.claude/*`. Add a new line per target.
3. **`claude/skills/`** — each direct subdirectory is symlinked individually to `~/.claude/skills/<name>/`, so skills can be added by creating a new subdirectory (no script edit needed).
4. **`claude/agents/`** — each file is symlinked individually to `~/.claude/agents/<name>` (same pattern).
5. **Private overlay** — if `~/dotfiles-private/setup/dotfiles.sh` exists, it runs at the end. Keep private/work-specific overrides there, not in this repo.

When you change `setup/dotfiles.sh`, think about whether the change is additive (just a new `add_symlink`) or changes existing behavior (will re-run prompt the user about a conflict, or silently replace?).

## Homebrew management

The Brewfile lives at `brewfiles/Brewfile` and `.zprofile` exports `HOMEBREW_BUNDLE_FILE` pointing to it — this means `brew bundle dump` updates the version-controlled file directly. Two helpers exist:

- `brew-sync` / `bs` alias → `brew bundle dump --force --describe` (uses `HOMEBREW_BUNDLE_FILE`)
- `ub` in `bin/` → `cd $DOTFILES/brewfiles && brew bundle dump --describe -f`

`setup/darwin/homebrew.sh` runs `brew bundle --file=brewfiles/Brewfile` and also a `Brewfile.local` if present (gitignored, for machine-specific extras).

## `bin/` and `scripts/` directory roles

- **`bin/`** — user-facing commands on `$PATH` (added in `.zprofile`). No file extension. Git subcommands use the `git-<name>` naming convention (e.g. `bin/git-dsb` becomes `git dsb` automatically).
- **`scripts/`** — setup helpers, one-off tasks, and internal scripts. NOT on `$PATH`. `.sh` extension.

### Git subcommands in `bin/`

Git discovers any executable named `git-<name>` on `$PATH` as `git <name>`. The following git subcommands live in `bin/`:

- `git dsb` → `bin/git-dsb` (delete squashed branches; aliased as `git ds`)
- `git copr <pr>` → `bin/git-copr` (fetches `pull/<N>/head` into a local branch; aliased as `git copr`)
- `git ro <newbase> <upstream> [target]` → `bin/git-ro` (wrapper around `git rebase --onto`)
- `git dm` → `git delete-merged-branches` (defined inline in `.gitconfig`)

## External scripts

`external-scripts.tsv` is a TSV of `url<TAB>destination` pairs fetched by `setup/external-scripts.sh` (it evals `$HOME` in the destination). Use this to vendor scripts from other people's dotfiles rather than copy-pasting, so the source is traceable.

## Claude Code config lives here

`claude/CLAUDE.md` and `claude/settings.json` are symlinked into `~/.claude/` and control the user's global Claude Code setup (enabled plugins, hooks, permissions, env vars like `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`). When the user asks to change Claude Code behavior globally, edit the files here, not in `~/.claude/` — the symlink means edits here take effect immediately, but edits made directly to `~/.claude/settings.json` would silently affect the symlink target and get committed the next time the user ran `git status`.

Note: `~/.claude/CLAUDE.md` pulls in `~/.claude/CLAUDE.local.md` via `@` include. That `.local.md` file is machine-specific and not in this repo.

## Conventions

- **Shell dialect:** all setup and `bin/`/`scripts/` files use POSIX `sh` or `bash` with `set -eux` / `set -euo pipefail`. Keep the `set` directives when adding new scripts.
- **Don't edit `~/`** to make things work — edit the source file here and re-run `sh setup.sh`. If a symlink is stale or broken, that's a setup bug to fix in `setup/dotfiles.sh`.
- **macOS-only code** belongs in `setup/darwin/`. `setup.sh` gates Darwin steps with `uname -s`.
- **Git:** prefer `--force-with-lease` over `--force`; never amend published commits without explicit permission (this is already in `claude/CLAUDE.md` as the global default).
