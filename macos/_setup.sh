#!/usr/bin/env bash

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/../misc.sh"

cd "$DOTFILES_DIR" && echo "Switching to $PWD"

system_prefs_list=(
    general
    desktop_and_screensaver
    dock
    mission_control
    siri
    spotlight
    language_and_region
    user_and_groups
    accessibility
    security_and_privacy
    bluetooth
    keyboard
    mouse
    energy_saver
    date_and_time
    sharing
    time_machine
    miscellaneous
)
app_prefs_list=(
    finder
    terminal
    textedit
    activity_monitor
    safari
)

kill_procs
for pref in "${system_prefs_list[@]}"; do
    source ${PWD}/system_prefs/_${pref}.sh
done

for pref in "${app_prefs_list[@]}"; do
    source ${PWD}/app_prefs/_${pref}.sh
done
kill_procs
