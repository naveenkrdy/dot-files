#!/usr/bin/env bash
set -euo pipefail

current="$(herdr pane current)"
pane_id="$(echo "$current" | jq -r '.result.pane.pane_id')"
tab_id="$(echo "$current" | jq -r '.result.pane.tab_id')"
workspace_id="$(echo "$current" | jq -r '.result.pane.workspace_id')"

target="$(herdr tab list --workspace "$workspace_id" \
  | jq -r --arg cur "$tab_id" '.result.tabs[] | select(.tab_id != $cur) | "\(.tab_id)\t#\(.number) \(.label)"' \
  | fzf --with-nth=2.. --prompt="Split into tab > " \
  | cut -f1)"

[ -n "$target" ] && herdr pane move "$pane_id" --tab "$target" --split right --focus
