# Enable don't send search queries to Apple in safari
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Enable press tab to highlight each item on a web page in safari
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

# Enable show the full URL in the address bar (note: this still hides the scheme)
# defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Enable prevent Safari from opening 'safe' files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Enable allow hitting the Backspace key to go to the previous page in history in safari
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

# Enable Safari's debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Enable the Develop menu and the Web Inspector in safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Enable add a context menu item for showing the Web Inspector in web views in safari
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Enable continuous spellchecking in safari
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true

# Disable auto-correct in safari
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

# Enable Auto-Update extensions automatically in safari
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true
