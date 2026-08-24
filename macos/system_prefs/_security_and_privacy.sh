# Disabe GateKeeper
# sudo spctl --master-disable

# Require password immediately after the computer went into sleep or screen saver mode
# defaults write com.apple.screensaver askForPassword -int 1
# defaults write com.apple.screensaver askForPasswordDelay -int 0

# Enable firewall
# Possible values:
# 0 = off
# 1 = on for specific services
# 2 = on for essential services
# sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1

# Enable firewall stealth mode
#sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -int 1

# Enable firewall logging
# sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -int 1
