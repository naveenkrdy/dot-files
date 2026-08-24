# Don't automatically rearrange Spaces based on most recent use
# defaults write com.apple.dock mru-spaces -bool false

# Don't group windows by application
# defaults write com.apple.dock expose-group-by-app -bool false

# Speed up Mission Control animation
defaults write com.apple.dock expose-animation-duration -float 0.1

# Hot corners
# Possible values:
# 0: no-op
# 2: Mission Control
# 3: Show application windows
# 4: Desktop
# 5: Start screen saver
# 6: Disable screen saver
# 7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# Set Hot Corners { Bottom left screen corner: Mission Control }
defaults write com.apple.dock wvous-bl-corner -int 2
defaults write com.apple.dock wvous-bl-modifier -int 0

# Set Hot Corners { Bottom right screen corner: Desktop }
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0
