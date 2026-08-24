# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Modifier Keys:
# None            : -1
# Caps Lock       : 0
# Shift (Left)    : 1
# Control (Left)  : 2
# Option (Left)   : 3
# Command (Left)  : 4
# Keypad 0        : 5
# Help            : 6
# Shift (Right)   : 9
# Control (Right) : 10
# Option (Right)  : 11
# Command (Right) : 12
# kbid=$(ioreg -n IOHIDKeyboard -r | grep -e VendorID\" -e ProductID | tr -d "|\"[:blank:]" | cut -d\= -f2 | tr "\n" -)
# defaults -currentHost write -g "com.apple.keyboard.modifiermapping.${kbid}0" "
#   <array>
#     <dict>
#       <key>HIDKeyboardModifierMappingSrc</key><integer>2</integer>
#       <key>HIDKeyboardModifierMappingDst</key><integer>0</integer>
#     </dict>
#     <dict>
#       <key>HIDKeyboardModifierMappingSrc</key><integer>0</integer>
#       <key>HIDKeyboardModifierMappingDst</key><integer>2</integer>
#     </dict>
#   </array>
# "

# Disable correct spelling automatically
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable add period with double space
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Add Input Sources:
# defaults write com.apple.HIToolbox.plist AppleEnabledInputSources -array \
# "<dict>
#   <key>InputSourceKind</key><string>Keyboard Layout</string>
#   <key>KeyboardLayout Name</key><string>U.S.</string>
#   <key>KeyboardLayout ID</key><integer>0</integer>
# </dict>"

# Disable press-and-hold for keys in favor of key repeat
# defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a fast key repeat rate
# defaults write NSGlobalDomain KeyRepeat -int 1
# defaults write NSGlobalDomain InitialKeyRepeat -int 10