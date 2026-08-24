#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../misc.sh"

echo "🐑 Setting up herdr..."

# ── Install herdr ─────────────────────────────────────────────────────────────
install_brew_pkg herdr

# ── Create XDG config dir ────────────────────────────────────────────────────
mkdir -p "${HOME}/.config/herdr"

# ── Symlink config ────────────────────────────────────────────────────────────
safe_link "${SCRIPT_DIR}/config.toml" "${HOME}/.config/herdr/config.toml"

# ── Reload a running server, if any ──────────────────────────────────────────
if herdr status &>/dev/null; then
  if herdr server reload-config &>/dev/null; then
    echo "✔ herdr server config reloaded"
  else
    echo "⚠️  herdr server reload-config failed — restart herdr to pick up changes"
  fi
fi

echo "✅ herdr setup complete"
