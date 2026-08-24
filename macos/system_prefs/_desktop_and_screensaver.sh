# Set custom wallpaper for all desktop screens
WALLPAPER="Clouds.jpeg"
wallpaper="${PWD}/files/wallpapers/${WALLPAPER}"
osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"${wallpaper}\"" &>/dev/null
