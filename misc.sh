#!/usr/bin/env bash

echo "📦 Loading misc utilities..."

# ---------------------------------------
# Internet check
# ---------------------------------------

check_internet() {
  if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
    return 0
  else
    echo "❌ No internet connection"
    return 1
  fi
}

# ---------------------------------------
# Xcode CLI tools
# ---------------------------------------

setup_xcode_tools() {
  if xcode-select -p &>/dev/null; then
    return 0
  fi

  echo "🛠 Installing Xcode Command Line Tools..."
  xcode-select --install || true

  until xcode-select -p &>/dev/null; do
    sleep 5
  done
}

# ---------------------------------------
# Homebrew
# ---------------------------------------

setup_homebrew() {
  setup_xcode_tools

  if command -v brew &>/dev/null; then
    return 0
  fi

  check_internet || return 1

  echo "🍺 Installing Homebrew..."

  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# ---------------------------------------
# Brew package install
# ---------------------------------------

install_brew_pkg() {
  local pkg=$1

  setup_homebrew
  check_internet || return 1

  if brew list "$pkg" &>/dev/null; then
    echo "✔ $pkg already installed"
  else
    echo "⬇ Installing $pkg"
    brew install "$pkg"
  fi
}

# ---------------------------------------
# Zsh setup
# ---------------------------------------

setup_zsh() {
  install_brew_pkg zsh

  local brew_prefix
  brew_prefix="$(brew --prefix)"

  local zsh_path="$brew_prefix/bin/zsh"

  if ! grep -Fxq "$zsh_path" /etc/shells; then
    echo "$zsh_path" | sudo tee -a /etc/shells
  fi

  if [[ "$SHELL" != "$zsh_path" ]]; then
    echo "🐚 Setting zsh as default shell"
    chsh -s "$zsh_path"
  fi
}

# ---------------------------------------
# Safe symlink
# ---------------------------------------

safe_link() {
  local src="$1"
  local dest="$2"

  dest="${dest/#\~/$HOME}"

  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink "$dest")"

    if [[ "$current" == "$src" ]]; then
      echo "✔ Already linked: $dest"
      return 0
    else
      echo "⚠️ Updating symlink: $dest"
      ln -sfn "$src" "$dest"
    fi

  elif [[ -e "$dest" ]]; then
    echo "⚠️ Backing up existing file: $dest"
    mv "$dest" "$dest.backup.$(date +%s)"
    ln -s "$src" "$dest"

  else
    ln -s "$src" "$dest"
  fi

  echo "🔗 $dest → $src"
}

# ---------------------------------------
# Kill affected apps
# ---------------------------------------

kill_procs() {
  local apps=(
    "Activity Monitor"
    "cfprefsd"
    "Safari"
    "Dock"
    "Finder"
    "SystemUIServer"
  )

  for app in "${apps[@]}"; do
    killall "$app" &>/dev/null || true
  done
}