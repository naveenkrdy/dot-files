#!/usr/bin/env bash

set -euo pipefail

# ---------------------------------------
# Init
# ---------------------------------------

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "📁 Dotfiles directory: $DOTFILES_DIR"

source "$DOTFILES_DIR/misc.sh"

# ---------------------------------------
# Logging
# ---------------------------------------

log() {
  echo -e "\n👉 $1"
}

# ---------------------------------------
# Sudo keep-alive
# ---------------------------------------

start_sudo_keepalive() {
  sudo -v
  (
    while true; do
      sudo -n true
      sleep 60
    done
  ) &
  SUDO_PID=$!
}

stop_sudo_keepalive() {
  kill "$SUDO_PID" 2>/dev/null || true
}

# ---------------------------------------
# Prevent sleep
# ---------------------------------------

start_caffeinate() {
  caffeinate -dimsu &
  CAFFEINATE_PID=$!
}

stop_caffeinate() {
  kill "$CAFFEINATE_PID" 2>/dev/null || true
}

# ---------------------------------------
# Module runner
# ---------------------------------------

run_module() {
  local module=$1
  log "Running module: $module"

  if [[ -f "$DOTFILES_DIR/$module/_setup.sh" ]]; then
    bash "$DOTFILES_DIR/$module/_setup.sh"
  else
    echo "⚠️ Missing module: $module"
  fi
}

# ---------------------------------------
# Profile resolution
# personal = full setup | work = terminal-only (no GUI apps, no macOS prefs)
# Resolution order: $DOTFILES_PROFILE env var > ~/.dotfiles-profile > interactive prompt
# ---------------------------------------

PROFILE_FILE="$HOME/.dotfiles-profile"

resolve_profile() {
  if [[ -n "${DOTFILES_PROFILE:-}" ]]; then
    return
  fi

  if [[ -f "$PROFILE_FILE" ]]; then
    DOTFILES_PROFILE="$(<"$PROFILE_FILE")"
    return
  fi

  local choice
  while true; do
    echo ""
    echo "Select setup profile:"
    echo "  [1] personal - full setup (apps, macOS prefs, everything)"
    echo "  [2] work     - terminal only (CLI tools + fonts, no GUI apps)"
    read -rp "Profile [1/2]: " choice
    case "$choice" in
      1) DOTFILES_PROFILE="personal"; break ;;
      2) DOTFILES_PROFILE="work"; break ;;
      *) echo "Invalid choice." ;;
    esac
  done
  printf '%s' "$DOTFILES_PROFILE" > "$PROFILE_FILE"
  echo "Saved profile '$DOTFILES_PROFILE' to $PROFILE_FILE"
}

resolve_profile

case "$DOTFILES_PROFILE" in
  personal|work) ;;
  *)
    echo "❌ Invalid profile: '$DOTFILES_PROFILE' (expected 'personal' or 'work')"
    exit 1
    ;;
esac

export DOTFILES_PROFILE
echo "👤 Profile: $DOTFILES_PROFILE"

# ---------------------------------------
# CLI args
# ---------------------------------------

MODULES=()

if [[ $# -eq 0 ]]; then
  if [[ "$DOTFILES_PROFILE" == "work" ]]; then
    MODULES=(brew git vim zsh tmux herdr terminal)
  else
    MODULES=(brew git vim zsh tmux herdr claude macos)
  fi
else
  MODULES=("$@")
fi

# ---------------------------------------
# Execute
# ---------------------------------------

start_sudo_keepalive
start_caffeinate

for module in "${MODULES[@]}"; do
  run_module "$module"
done

stop_caffeinate
stop_sudo_keepalive

echo -e "\n✅ Setup complete!"