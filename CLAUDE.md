# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running setup

```bash
# Full setup (all modules for the active profile)
bash setup.sh

# Single module
bash setup.sh brew
bash setup.sh git
bash setup.sh vim
bash setup.sh zsh
bash setup.sh herdr
bash setup.sh claude
bash setup.sh macos
bash setup.sh terminal

# Non-interactive profile override
DOTFILES_PROFILE=work bash setup.sh
```

Each module's `_setup.sh` can also be run directly from its own directory.

## Profiles

Setup supports two profiles, resolved in this order: `$DOTFILES_PROFILE` env var, then `~/.dotfiles-profile`, then an interactive prompt (answer is saved to `~/.dotfiles-profile`).

| Profile | Modules | Brewfile |
|---------|---------|----------|
| `personal` | brew git vim zsh herdr claude macos | `brew/brewfile` (full: apps, casks, mas, vscode) |
| `work` | brew git vim zsh herdr terminal | `brew/brewfile.core` (CLI tools + nerd fonts, plus an explicit app allowlist) |

`brew/brewfile` is dump-managed: the `bdp` alias regenerates it from the installed set.
`brew/brewfile.core` is **auto-generated** by `brew/generate_core.sh` - never edit it by hand.
By default the generator keeps all formulae except those listed in `brew/core_exclude.txt` (tap-scoped formulae are dropped automatically), keeps nerd-font casks only, keeps only the `buo/cask-upgrade` tap, and drops all other casks, taps, mas, and vscode entries.
`brew/core_include.txt` is the escape hatch: any tap, cask, or tap-scoped formula listed there (by exact token) survives onto the work profile despite those default rules — this is how work-approved GUI apps (Slack, Postman, VS Code, etc.) and tap-scoped CLI tools (`moviebox-tui`) get onto the office machine without opening up the whole personal cask/tap set.
Both generators run automatically from the `bdp` alias (after every dump) and from `brew/_setup.sh` on work-profile installs.
To keep a tool off the office machine, add its formula name to `brew/core_exclude.txt`; to force one onto it, add its token to `brew/core_include.txt`.
Explicit module args to `setup.sh` bypass the profile module list but the exported `DOTFILES_PROFILE` still selects the brewfile.

## Architecture

This is a macOS dotfiles repo. All configs are **symlinked** into `~` rather than copied — `misc.sh` provides the `safe_link()` function that backs up existing files before creating symlinks.

**Entry point:** `setup.sh` sources `misc.sh`, resolves the profile, then calls `run_module()` for each requested module. Shared utilities live in `misc.sh` (internet check, Homebrew bootstrap, `install_brew_pkg`, `setup_zsh`, `safe_link`, `kill_procs`).

**Modules** — each has a `_setup.sh` that sources `../misc.sh`:

| Module | What it does | Symlink targets |
|--------|-------------|-----------------|
| `brew/` | Installs Homebrew, links the profile's brewfile → `~/Brewfile`, runs `brew bundle` | `~/Brewfile` |
| `git/` | Installs git, sets global defaults, writes machine-local identity | `~/.gitconfig`, `~/.gitignore` |
| `vim/` | Installs vim, links plugin dir and rc | `~/.vim`, `~/.vimrc` |
| `zsh/` | Installs zsh, sets as default shell; also installs zsh-patina and links its config + custom Tokyo Night theme | `~/.zsh` → `zsh/zsh/`, `~/.zshrc` → `zsh/zshrc`, `~/.zshenv`, `~/.config/zsh-patina/config.toml`, `~/.config/zsh-patina/tokyo-night-custom.toml` |
| `herdr/` | Installs herdr, links config and keybinding scripts, reloads a running server | `~/.config/herdr/config.toml`, `~/.config/herdr/move-pane-to-split.sh` |
| `claude/` | Personal-profile only. No install (the app is `cask "claude-code"`); links Claude Code CLI config — global instructions, RTK, settings, hooks, themes, and the 15 non-external skills | `~/.claude/CLAUDE.md`, `RTK.md`, `settings.json`, `settings.local.json`, `statusline-command.sh`, `commands/`, `hooks/`, `themes/`, `skills/<name>` (per-directory, not the whole `skills/` folder — see below) |
| `macos/` | Applies `defaults write` preferences for system and apps (personal profile only) | — |
| `terminal/` | Work-profile subset of `macos/`: runs only `macos/app_prefs/_terminal.sh` (Terminal.app defaults + `.terminal` profile import), without the rest of the macOS system/app prefs | — |

**Git identity:** `git/gitconfig` contains no `[user]` block.
Identity lives in `~/.gitconfig.local`, pulled in via `[include]`; `git/_setup.sh` prompts for name/email on first run per machine.
Note: reading it back requires `git config --includes --global user.email` — plain `--global` does not follow includes.

**Zsh config layout:** `zshrc` is the single sourced file. It directly embeds plugin management, key bindings, hooks, and aliases rather than sourcing split files. The `zsh/zsh/` directory holds `plugins.txt` (antidote's plugin list) and `fzfm.zsh` (sourced directly by `zshrc`); it no longer contains any unsourced leftover files.

**Plugin management:** Antidote is used with an mtime-based cache (`~/.zsh/cache/plugins.zsh`): `zshrc` compares `plugins.txt`'s mtime against the cache file's and only reruns `antidote bundle` when `plugins.txt` is newer. To force a rebuild: `atdreload` alias (`rm -f ~/.zsh/cache/plugins.zsh && exec zsh`).

**macOS preferences:** `macos/_setup.sh` sources each script in `system_prefs/` and `app_prefs/` which use `defaults write` to configure Dock, Finder, Safari, Terminal, energy saver, keyboard, etc. Run `kill_procs` before and after to apply changes.
`macos/app_prefs/_terminal.sh` additionally imports every `.terminal` file in `macos/files/terminalcolors/` into Terminal.app's profile list; it's idempotent (skips any profile name that already `exists`, since Terminal.app otherwise appends a numbered duplicate on re-import) and never changes the current default profile. `terminal/_setup.sh` (the work-profile module) sources this same script directly so both profiles share one implementation.

**Claude Code config (`claude/`):** only the portable subset of `~/.claude/` is tracked — never `~/.claude.json` (OAuth/session tokens, lives in `$HOME`, outside `~/.claude/`), any `*.key` file, security logs, or machine-local runtime state (`projects/`, `cache/`, `session-env/`, `shell-snapshots/`, `history.jsonl`, `daemon.*`, `plans/`, etc.). `settings.json` uses `$HOME` rather than absolute paths in its hook and `statusLine` commands, so it is portable across machines and usernames: Claude Code runs hooks in shell form (no `args` key) through `sh -c`, and runs `statusLine` commands through a shell, so both expand `$HOME`. Note the path must be double-quoted, not single-quoted — single quotes suppress expansion. `skills/` is symlinked **per-directory**, not as a whole folder: `~/.claude/skills/` holds 34 live entries, 28 of them symlinks - 15 into this repo, 13 (`remotion-*`, `find-skills`) into `~/.agents/skills/` (unmanaged by this repo) - and a whole-folder `safe_link` would back up and replace the entire live folder, breaking those.

## Key patterns

- `safe_link src dest` — idempotent symlink; backs up existing files as `<file>.backup.<timestamp>`.
- `install_brew_pkg pkg` — no-op if already installed; bootstraps Homebrew first.
- `set -euo pipefail` is used in all module scripts except `macos/_setup.sh`, which tolerates individual `defaults write`/`osascript` failures across its many system-prefs sub-scripts.
- All module `_setup.sh` scripts resolve `DOTFILES_DIR` via `${BASH_SOURCE[0]}` so they work when called from any directory.
