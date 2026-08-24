#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES_DIR/misc.sh"

echo "Setting up Claude Code config..."

CLAUDE_DIR="$DOTFILES_DIR/claude"
CLAUDE_DEST="$HOME/.claude"
mkdir -p "$CLAUDE_DEST"

safe_link "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DEST/CLAUDE.md"
safe_link "$CLAUDE_DIR/RTK.md" "$CLAUDE_DEST/RTK.md"
safe_link "$CLAUDE_DIR/settings.json" "$CLAUDE_DEST/settings.json"
safe_link "$CLAUDE_DIR/settings.local.json" "$CLAUDE_DEST/settings.local.json"
safe_link "$CLAUDE_DIR/statusline-command.sh" "$CLAUDE_DEST/statusline-command.sh"
safe_link "$CLAUDE_DIR/commands" "$CLAUDE_DEST/commands"
safe_link "$CLAUDE_DIR/hooks" "$CLAUDE_DEST/hooks"
safe_link "$CLAUDE_DIR/themes" "$CLAUDE_DEST/themes"

# skills/: symlink only the real (non-external-symlink) skill dirs one at a time,
# so the existing symlinks into ~/.agents/skills/ (remotion-*, find-skills) are
# never touched - a whole-directory safe_link would back up and replace the
# entire live skills/ folder, silently breaking those.
mkdir -p "$CLAUDE_DEST/skills"
for skill_dir in "$CLAUDE_DIR"/skills/*/; do
  name="$(basename "$skill_dir")"
  safe_link "$skill_dir" "$CLAUDE_DEST/skills/$name"
done

echo "Claude Code config setup complete!"
