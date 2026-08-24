#Install fonts
cp -vRf ${PWD}/files/fonts/*.ttf ${PWD}/files/fonts/*.otf ${HOME}/Library/Fonts/

# Enable HiDPI display modes (requires restart)
# sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

# Use AirDrop over every interface.
# defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

# Disable the over-the-top focus ring animation
# defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

# Disable reopen on restart
# defaults write NSGlobalDomain ApplePersistence -bool false

# Disable Reopen windows when logging back in
# defaults write com.apple.loginwindow TALLogoutSavesState 0

# Restart automatically if the computer freezes
# sudo systemsetup -setrestartfreeze on

# Disable resume system-wide
# defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Disable automatic termination of inactive apps
# defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Enable reveal IP address, hostname, OS version, etc. when clicking the clock in the login window
# sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Disable the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating `.DS_Store` files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable the "Are you sure you want to open this application?" dialog
# defaults write com.apple.LaunchServices LSQuarantine -bool false

# Automatically quit the printer app once the print jobs are completed
# defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Save screenshots to the ~/Pictures folder instead
defaults write com.apple.screencapture location -string "${HOME}/Pictures/"

# Save screenshots as PNGs
defaults write com.apple.screencapture type -string "png"

# Enable Help Viewer windows to non-floating mode
# defaults write com.apple.helpviewer DevMode -bool true

# Disable disk image verification"
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Expand save panel by default
# defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Expand print panel by default
# defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# Hide the Time Machine and Volume icons from the menu bar
# for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
#     sudo defaults write "${domain}" dontAutoLoad -array \
#         "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
#         "/System/Library/CoreServices/Menu Extras/Volume.menu"
# done

# defaults write com.apple.systemuiserver menuExtras -array \
# 	"/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
#     "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
#     "/System/Library/CoreServices/Menu Extras/Battery.menu" \
#     "/System/Library/CoreServices/Menu Extras/Clock.menu"
