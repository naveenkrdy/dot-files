# Supress login prompt upon launch
touch ${HOME}/.hushlogin

# Only use UTF-8 in Terminal.app
defaults write com.apple.Terminal StringEncodings -array 4

# Enable Secure Keyboard Entry in Terminal.app
# See: https://security.stackexchange.com/a/47786/8918
defaults write com.apple.Terminal SecureKeyboardEntry -bool true

# Disable the annoying line marks in terminal
defaults write com.apple.Terminal ShowLineMarks -int 0

# Hide scroll bar in terminal and only show when scrolling
defaults write com.apple.Terminal AppleShowScrollBars -string WhenScrolling

# Enable focus follows mouse for Terminal
# defaults write com.apple.Terminal FocusFollowsMouse -string YES

# Import every custom Terminal.app color profile from files/terminalcolors/
# (adds each to the profile list; does not change the current default
# profile, so re-running this never clobbers whatever you've set yourself,
# and a fresh machine just keeps Terminal's own stock default). Skips
# profiles that already exist by name - Terminal.app doesn't overwrite on
# re-import, it appends a numbered duplicate, so this is what keeps the
# script idempotent across repeated setup.sh runs.
for theme_file in "${PWD}"/files/terminalcolors/*.terminal; do
  [[ -f "$theme_file" ]] || continue
  profile_name="$(basename "$theme_file" .terminal)"
  already_exists=$(osascript -e "tell application \"Terminal\" to exists settings set \"$profile_name\"" 2>/dev/null)
  [[ "$already_exists" == "true" ]] && continue

  before_ids=$(osascript -e 'tell application "Terminal" to id of every window' 2>/dev/null)
  open "$theme_file"
  sleep 1.5
  osascript -e "tell application \"Terminal\"
    set beforeIDs to {${before_ids}}
    set afterIDs to id of every window
    repeat with anID in afterIDs
      if anID is not in beforeIDs then
        try
          close (window id anID) saving no
        end try
      end if
    end repeat
  end tell" &>/dev/null
done
