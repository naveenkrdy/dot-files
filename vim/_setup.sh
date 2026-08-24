#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../misc.sh"

echo "📝 Setting up Vim..."

# ---------------------------------------
# Install Vim via Homebrew
# ---------------------------------------
install_brew_pkg vim

# ---------------------------------------
# Symlinks
# ---------------------------------------
safe_link "${SCRIPT_DIR}" "${HOME}/.vim"
safe_link "${SCRIPT_DIR}/vimrc" "${HOME}/.vimrc"

echo "✅ Vim setup complete"