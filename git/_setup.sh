#!/usr/bin/env bash

set -euo pipefail

echo "🔧 Setting up Git..."


DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/../misc.sh"

install_brew_pkg git

GITCONFIG_SRC="$DOTFILES_DIR/gitconfig"
GITIGNORE_SRC="$DOTFILES_DIR/gitignore"

# ---------------------------------------
# Link configs
# ---------------------------------------

safe_link "$GITCONFIG_SRC" "$HOME/.gitconfig"
safe_link "$GITIGNORE_SRC" "$HOME/.gitignore"

# Defaults (init.defaultBranch, pull.rebase, etc.) live directly in gitconfig,
# not applied via `git config --global` here - since ~/.gitconfig symlinks
# into the tracked file, --global writes would edit the repo in place.

# ---------------------------------------
# Machine-local identity (~/.gitconfig.local)
# Included from gitconfig so work/personal emails stay out of the repo
# ---------------------------------------

if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  if [[ -t 0 ]]; then
    echo "🪪 Git identity for this machine:"
    read -rp "  user.name: " GIT_NAME
    read -rp "  user.email: " GIT_EMAIL
    printf '[user]\n\tname = %s\n\temail = %s\n' "$GIT_NAME" "$GIT_EMAIL" > "$HOME/.gitconfig.local"
    echo "✅ Wrote ~/.gitconfig.local"
  else
    echo "⚠️ ~/.gitconfig.local missing and shell is non-interactive - create it with:"
    echo "   printf '[user]\\n\\tname = YOU\\n\\temail = YOU@example.com\\n' > ~/.gitconfig.local"
  fi
fi

# --includes is required: plain --global does not follow [include] paths
if ! git config --includes --global user.name &>/dev/null; then
  echo "⚠️ user.name not set"
fi

if ! git config --includes --global user.email &>/dev/null; then
  echo "⚠️ user.email not set"
fi

echo "✅ Git setup complete!"