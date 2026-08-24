_FZFM_SRC="${(%):-%N}"

_fzfm_open() {
    local file="$1" text_editor="$2" media_opener="$3"
    local ext="${file##*.}"

    case "${ext:l}" in
        txt|md|markdown|rst|sh|bash|zsh|fish|py|js|ts|jsx|tsx|json|yaml|yml|toml|ini|cfg|conf|env|html|htm|css|scss|c|cpp|h|hpp|go|rs|rb|java|php|xml|vim|lua|nix|sql|log|diff|patch)
            "$text_editor" "$file"; clear; return ;;
        jpg|jpeg|png|gif|webp|svg|bmp|tiff|ico|mp4|mov|avi|mkv|webm|mp3|flac|wav|ogg|aac|pdf)
            if [[ -n "$media_opener" ]]; then
                "$media_opener" "$file" &>/dev/null &!
            else
                echo "No media opener available" >&2
                read -rk1 "?Press any key to continue..."
                clear
            fi
            return ;;
    esac

    local mime_type
    mime_type=$(file --mime-type -b "$file")

    case "$mime_type" in
        text/*|application/json|application/xml|application/javascript|application/x-shellscript)
            "$text_editor" "$file"; clear ;;
        image/*|video/*|audio/*|application/pdf)
            if [[ -n "$media_opener" ]]; then
                "$media_opener" "$file" &>/dev/null &!
            else
                echo "No media opener available" >&2
                read -rk1 "?Press any key to continue..."
                clear
            fi ;;
        *)
            if [[ -n "$media_opener" ]]; then
                "$media_opener" "$file" &>/dev/null || { "$text_editor" "$file"; clear; }
            else
                "$text_editor" "$file"; clear
            fi ;;
    esac
}

fzfm() {
    local media_opener="${FZFM_MEDIA_OPENER:-open}"
    local text_editor="${FZFM_TEXT_EDITOR:-vim}"
    local list_command
    local preview_command="${FZFM_PREVIEW_COMMAND:-bat}"
    local -a list_args

    if ! command -v fzf &>/dev/null; then
        echo "fzfm: fzf is required but not installed" >&2; return 1
    fi

    if command -v eza &>/dev/null; then
        list_command="eza"
        list_args=(-lA --git --no-user --time=created --time-style=long-iso --icons=always --color=always --group-directories-first)
    elif command -v lsd &>/dev/null; then
        list_command="lsd"
        list_args=(-1A --icon=always --color=always)
    else
        list_command="ls"; list_args=(-1A --color=always)
    fi

    if ! command -v "$preview_command" &>/dev/null; then
        echo "fzfm: $preview_command not found, falling back to cat" >&2
        preview_command="cat"
    fi

    if ! command -v "$text_editor" &>/dev/null; then
        if command -v nano &>/dev/null; then
            echo "fzfm: $text_editor not found, falling back to nano" >&2
            text_editor="nano"
        else
            echo "fzfm: no suitable text editor found" >&2; return 1
        fi
    fi

    if ! command -v "$media_opener" &>/dev/null; then
        if command -v xdg-open &>/dev/null; then media_opener="xdg-open"
        elif command -v open &>/dev/null; then media_opener="open"
        else media_opener=""
        fi
    fi

    local list_str="$list_command ${list_args[*]}"
    local origdir="$PWD"

    # Persistent helper scripts. mktemp'd scripts pay a macOS Gatekeeper
    # (syspolicyd) assessment on every first exec (~0.5-1s each); a stable
    # path is only assessed once, after that launches are milliseconds.
    local cache_dir="$HOME/.zsh/cache/fzfm"
    local list_script="$cache_dir/fzfm-list.zsh"
    local nav_script="$cache_dir/fzfm-nav.zsh"
    if [[ ! -x "$list_script" || ! -x "$nav_script" || "$_FZFM_SRC" -nt "$list_script" ]]; then
        mkdir -p "$cache_dir"
        cat > "$list_script" <<'EOF'
#!/bin/zsh
print '󱧰 ..'
cmd=(${(z)FZFM_LIST_CMD})
"${cmd[@]}" "$(cat "$FZFM_CURDIR")"
EOF
        cat > "$nav_script" <<'EOF'
#!/bin/zsh
file="$1"
bare="${file##* }"
current="$(cat "$FZFM_CURDIR")"
if [[ "$bare" == '..' ]]; then
    newdir="$(dirname "$current")"
elif [[ -d "$current/$bare" ]]; then
    newdir="$(cd "$current/$bare" && pwd)"
else
    print 'accept'
    exit
fi
printf '%s' "$newdir" > "$FZFM_CURDIR"
printf 'reload(%s)+change-prompt( 󱉭  %s/ > )+clear-query' "$FZFM_LIST_SCRIPT" "$newdir"
EOF
        chmod +x "$list_script" "$nav_script"
    fi

    # Per-run state files (read/written only, never executed - no Gatekeeper
    # cost). Passed to the shared helper scripts via exported env vars so
    # concurrent fzfm instances stay isolated.
    local curdir cdfile
    curdir=$(mktemp)
    cdfile=$(mktemp)
    printf '%s' "$PWD" > "$curdir"
    local -x FZFM_CURDIR="$curdir"
    local -x FZFM_LIST_CMD="$list_str"
    local -x FZFM_LIST_SCRIPT="$list_script"

    local keybindings="  enter: open  │  left: go up  │  ^D: cd here  │  ^Y: copy path  │  ^O: open in app  │  ^P: preview  "

    clear
    while true; do
        local selected
        selected=$(
            "$list_script" |
            fzf \
                --ansi \
                --reverse \
                --height 100% \
                --info right \
                --prompt " 󱉭  $(cat $curdir)/ > " \
                --pointer ">" \
                --marker "󰄲" \
                --border rounded \
                --border-label="$keybindings" \
                --border-label-pos "bottom:center" \
                --color 'fg:#c0caf5,fg+:#c0caf5,bg+:#33467c,border:#a9b1d6,pointer:#bb9af7,label:#414868,prompt:#bb9af7' \
                --bind "shift-up:preview-up" \
                --bind "shift-down:preview-down" \
                --bind "ctrl-r:reload($list_script)" \
                --bind "enter:transform($nav_script {})" \
                --bind "right:transform($nav_script {})" \
                --bind "left:transform($nav_script ..)" \
                --bind "ctrl-p:toggle-preview" \
                --bind "ctrl-d:execute-silent(cat $curdir > $cdfile)+abort" \
                --bind "ctrl-y:execute-silent(
                    file={}
                    bare=\"\${file##* }\"
                    current=\"\$(cat $curdir)\"
                    if [[ \"\$bare\" == '..' ]]; then
                        printf '%s' \"\$current\" | pbcopy
                    else
                        printf '%s' \"\$current/\$bare\" | pbcopy
                    fi
                )" \
                --bind "ctrl-o:execute-silent(
                    file={}
                    bare=\"\${file##* }\"
                    current=\"\$(cat $curdir)\"
                    if [[ \"\$bare\" == '..' ]]; then
                        open \"\$current\" &>/dev/null &
                    else
                        open \"\$current/\$bare\" &>/dev/null &
                    fi
                )" \
                --preview-window "right:65%:border-left" \
                --preview "
                    echo
                    file={}
                    bare=\"\${file##* }\"
                    current=\"\$(cat $curdir)\"
                    if [[ \"\$bare\" == '..' ]]; then
                        echo '  󱧰  Move up to parent directory'
                    elif [[ -d \"\$current/\$bare\" ]]; then
                        echo \"  󰉋 Directory: \$bare\"
                        echo
                        eza -lA --no-permissions --no-filesize --no-user --no-time --icons=always --color=always --group-directories-first \"\$current/\$bare\" 2>/dev/null | head -50 || $list_str \"\$current/\$bare\" 2>/dev/null | head -50
                    elif [[ -f \"\$current/\$bare\" ]]; then
                        echo \"  󰈙 File: \$bare\"
                        echo
                        $preview_command --style=numbers --color=always --line-range :500 \"\$current/\$bare\" 2>/dev/null || cat \"\$current/\$bare\"
                    fi
                "
        )

        if [[ -z "$selected" ]]; then
            local final_cd
            final_cd=$(cat "$cdfile" 2>/dev/null)
            if [[ -n "$final_cd" ]]; then
                cd "$final_cd"
            else
                cd "$origdir"
            fi
            break
        fi

        cd "$(cat $curdir)" || break
        local clean
        clean=$(printf '%s' "$selected" | sed $'s/\033\\[[0-9;]*m//g')
        local target="${clean##* }"
        [[ -f "$target" ]] && _fzfm_open "$target" "$text_editor" "$media_opener"
    done

    rm -f "$curdir" "$cdfile"
}

alias fm=fzfm
