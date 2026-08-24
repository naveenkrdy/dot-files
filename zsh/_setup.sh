#!/usr/bin/env bash

set -euo pipefail

echo "🐚 Setting up Zsh..."

# ---------------------------------------
# Ensure Zsh is installed & default
# ---------------------------------------



DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/../misc.sh"

setup_zsh

ZSH_DIR_SRC="$DOTFILES_DIR/zsh"
ZSHRC_SRC="$DOTFILES_DIR/zshrc"
ZSHENV_SRC="$DOTFILES_DIR/zshenv"
ZSH_PATINA_DIR="$DOTFILES_DIR/zsh-patina"

ZSH_DIR_DEST="$HOME/.zsh"
ZSHRC_DEST="$HOME/.zshrc"
ZSHENV_DEST="$HOME/.zshenv"
ZSH_PATINA_DEST="$HOME/.config/zsh-patina"

# ---------------------------------------
# Link main zsh directory
# ---------------------------------------

echo "🔗 Linking Zsh config directory..."
safe_link "$ZSH_DIR_SRC" "$ZSH_DIR_DEST"

# ---------------------------------------
# Link .zshrc, .zshenv
# ---------------------------------------

echo "🔗 Linking .zshrc..."
safe_link "$ZSHRC_SRC" "$ZSHRC_DEST"

echo "🔗 Linking .zshenv..."
safe_link "$ZSHENV_SRC" "$ZSHENV_DEST"

# ---------------------------------------
# zsh-patina (syntax highlighter)
# ---------------------------------------

echo "🎨 Setting up zsh-patina..."
install_brew_pkg zsh-patina

mkdir -p "$ZSH_PATINA_DEST"
safe_link "$ZSH_PATINA_DIR/config.toml" "$ZSH_PATINA_DEST/config.toml"
safe_link "$ZSH_PATINA_DIR/tokyo-night-custom.toml" "$ZSH_PATINA_DEST/tokyo-night-custom.toml"

# ---------------------------------------
# Cleanup compiled files (optional)
# ---------------------------------------

echo "🧹 Cleaning old compiled files..."
find "$ZSH_DIR_DEST" -name "*.zwc" -type f -delete 2>/dev/null || true

echo "✅ Zsh setup complete!"