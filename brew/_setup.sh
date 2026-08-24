#!/usr/bin/env bash

set -euo pipefail

echo "🍺 Setting up Homebrew..."

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/../misc.sh"

setup_homebrew

# Load brew into PATH
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew analytics off || true

# Ensure bundle tap
if ! brew tap | grep -q "homebrew/bundle"; then
  brew tap homebrew/bundle
fi

# ---------------------------------------
# Brewfile linking
# ---------------------------------------

# work profile installs the auto-generated CLI subset; personal (or unset) the full manifest
BREW_MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "${DOTFILES_PROFILE:-personal}" == "work" ]]; then
  bash "$BREW_MODULE_DIR/generate_core.sh"
  BREWFILE_SRC="$BREW_MODULE_DIR/brewfile.core"
else
  BREWFILE_SRC="$BREW_MODULE_DIR/brewfile"
fi
BREWFILE_DEST="$HOME/Brewfile"

echo "🔗 Setting up Brewfile..."

safe_link "$BREWFILE_SRC" "$BREWFILE_DEST"

# ---------------------------------------
# Install
# ---------------------------------------

echo "📦 Installing from Brewfile..."
brew bundle --file="$BREWFILE_DEST" --verbose

echo "⬆️ Updating..."
brew update
brew upgrade

echo "🧹 Cleaning..."
brew autoremove

echo "✅ Homebrew setup complete!"