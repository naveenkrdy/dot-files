#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../misc.sh"

echo "📺 Setting up tmux..."

# ── Install tmux ─────────────────────────────────────────────────────────────
install_brew_pkg tmux

# ── Create XDG config dir ────────────────────────────────────────────────────
mkdir -p "${HOME}/.config/tmux/plugins"

# ── Clone tpm (tmux plugin manager) ─────────────────────────────────────────
TPM_DIR="${HOME}/.config/tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
  echo "✔ tpm already present"
else
  echo "⬇ Cloning tpm..."
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# ── Symlink config ────────────────────────────────────────────────────────────
safe_link "${SCRIPT_DIR}/tmux.conf" "${HOME}/.config/tmux/tmux.conf"

# ── Install declared plugins (headless) ───────────────────────────────────────
# TMUX_PLUGIN_MANAGER_PATH must be set so tpm installs to the XDG path.
export TMUX_PLUGIN_MANAGER_PATH="${HOME}/.config/tmux/plugins/"
if TMUX_PLUGIN_MANAGER_PATH="$TMUX_PLUGIN_MANAGER_PATH" \
     "${TPM_DIR}/bin/install_plugins" 2>/dev/null; then
  echo "✔ tmux plugins installed"
else
  echo "⚠️  Headless plugin install skipped — open tmux and press Ctrl-a I to fetch plugins"
fi

echo "✅ tmux setup complete"
