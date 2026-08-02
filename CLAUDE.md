# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

## What this repo is

Personal macOS dotfiles — config files, shell scripts, and a symlink-based installer that materializes them into `$HOME`. Not an application: no build, no test suite, no CI.

The repo **must** live at `~/dotfiles`. `.zshenv` exports that path as `$DOTFILES`, and every `setup/*.sh` resolves paths from it.

## Commands

| Command | Notes |
| --- | --- |
| `sh setup.sh` | Full setup. Runs every `setup/*.sh`, then `setup/darwin/*.sh` on Darwin. Can block on stdin — see below. |
| `sh setup/dotfiles.sh` | Symlink pass only. Use this when iterating on symlinks. |
| `sh install.sh` | **Destructive**: `git reset --hard origin/master` before running `setup.sh`. Never run with uncommitted work in the tree. |
| `shellcheck <file>` | The only linter here (installed via `brewfiles/Brewfile`). |
| `brew bundle --file=brewfiles/Brewfile` | Install packages. `setup/darwin/homebrew.sh` also applies `Brewfile.local` if present (gitignored, machine-specific). |
| `brew-sync` / `bs` | Dump installed packages into the Brewfile. Read the Homebrew gotcha below first. |

## Verifying a change

There is no automated check, so verify by hand and show the evidence rather than asserting success:

- **Shell scripts** — `shellcheck <file>`. Everything currently passes `shellcheck -S error` except `install.sh` (SC2148, no shebang); that one is pre-existing, not a regression you introduced.
- **Symlink changes** — run `sh setup/dotfiles.sh`, then `ls -l <destination>` and confirm the link resolves into `~/dotfiles`.
- **`sh setup.sh` is not safe to run unattended.** The `claude/skills` and `claude/agents` loops call `symlink()` without going through `backup()`, so a link pointing somewhere unexpected triggers an interactive `Overwrite? [y/N]` read — it hangs forever in a non-interactive shell. Run it in the foreground, or run only the one `setup/*.sh` you touched.

## The symlink pipeline

`setup/dotfiles.sh` is the core of the repo; adding a new config file almost always means editing it.

1. **Top-level dotfiles** — every `.<name>` file at the repo root (`.zshrc`, `.gitconfig`, `.commonrc`, …) is auto-symlinked to `~/<name>`. Drop the file in the root; no script edit needed.
2. **Targeted symlinks** — explicit `add_symlink "source" "dest"` calls map paths under `config/` and `claude/` into `~/.config/*` and `~/.claude/*`. One line per target.
3. **`claude/skills/`** — each direct subdirectory is symlinked to `~/.claude/skills/<name>/`. Add a subdirectory; no script edit needed.
4. **`claude/agents/`** — each file is symlinked to `~/.claude/agents/<name>`. Same.
5. **Private overlay** — `~/dotfiles-private/setup/dotfiles.sh` runs last if it exists. Private or work-specific overrides go there, not in this repo.

Steps 1–2 and steps 3–4 behave differently, which matters whenever you change either:

- **1–2 go through `backup()`**, which moves whatever sits at the destination into `~/.dotfiles.backups` *unconditionally* — including a symlink that was already correct. Backups accumulate with numbered suffixes (`CLAUDE.md.14`) on every run. Fully non-interactive.
- **3–4 call `symlink()` directly.** An already-correct link is a no-op; a link pointing elsewhere prompts on stdin.

## Homebrew

`.zprofile` exports `HOMEBREW_BUNDLE_FILE="${DOTFILES}/brewfiles/Brewfile"`, so a bare `brew bundle dump` writes straight to the version-controlled file.

**Gotcha:** the `brew-sync` / `bs` alias in `.commonrc` runs `brew bundle dump --force` *without* `--describe`, but the committed Brewfile carries description comments. Running `bs` as-is deletes all of them. Use `brew bundle dump --force --describe` instead, and review the diff before committing.

## Directory roles

- **`bin/`** — user-facing commands, on `$PATH` via `.zprofile`. No file extension. Convention: define a shell function, then invoke it on the last line — a script that only defines the function silently does nothing. Git auto-discovers any `bin/git-<name>` as `git <name>`; their short aliases live in `.gitconfig`. Run `ls bin/` instead of relying on a list here.
- **`scripts/`** — setup helpers and one-off tasks. `.sh` extension. NOT on `$PATH`.
- **`setup/darwin/`** — macOS-only steps. `setup.sh` gates these behind `uname -s`.
- **`external-scripts.tsv`** — `url<TAB>destination` pairs fetched by `setup/external-scripts.sh` (it `eval`s the destination, so `$HOME` expands). Vendor other people's scripts here rather than copy-pasting, so the source stays traceable.

## Claude Code config lives here

`claude/CLAUDE.md`, `claude/settings.json`, and `claude/keybindings.json` are symlinked into `~/.claude/` and drive the user's global Claude Code setup.

**IMPORTANT: when asked to change Claude Code behavior globally, edit the files under `claude/` here — never through `~/.claude/`.** They are the same inode, so edits here take effect immediately; edits made via the `~/.claude/` path land in this repo unnoticed and surface later as unexplained `git status` churn.

`~/.claude/CLAUDE.md` pulls in `~/.claude/CLAUDE.local.md` via an `@` include. That file is machine-specific and deliberately not in this repo.

## Conventions

- **Shell dialect:** POSIX `sh` or `bash`, with `set -eux` (setup scripts) or `set -euo pipefail` (`bin/`). Keep the `set` line when adding a script.
- **IMPORTANT: never edit files under `~/` to make something work.** Edit the source here and re-run the relevant setup script. A stale or broken symlink is a bug in `setup/dotfiles.sh`, not something to patch in place.
- **Commits:** short imperative one-liners — `Update Brewfile`, `Add wtpr`, `Fix cmux config symlink`. No conventional-commits prefixes.
