#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES_DIR/misc.sh"

echo "🖥️  Setting up Terminal.app..."

# Reuses macos/app_prefs/_terminal.sh (defaults writes + profile import) as
# the single source of truth; that script resolves paths relative to $PWD,
# so run it from the macos/ directory.
kill_procs
( cd "$DOTFILES_DIR/macos" && source ./app_prefs/_terminal.sh )
kill_procs

echo "✅ Terminal.app setup complete!"
