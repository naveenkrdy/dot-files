#!/bin/sh
# Claude Code status line -- Nerd Font simple style

input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
dir=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name // ""')
effort=$(echo "$input" | jq -r '.effort.level // ""')

git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
cost=$(echo "$input" | jq -r '.total_cost_usd // .cost.total_cost_usd // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Truecolor palette matched to terminal/prompt scheme
c_dir='\033[38;2;118;228;247m'    # #76e4f7  suggestion/IDE blue
c_git='\033[38;2;127;176;105m'    # #7FB069  _PC_GIT_CLEAN green
c_model='\033[38;2;0;212;170m'    # #00d4aa  Claude teal
c_ok='\033[38;2;72;187;120m'      # #48bb78  success green
c_warn='\033[38;2;246;173;85m'    # #f6ad55  warning orange
c_err='\033[38;2;252;129;129m'    # #fc8181  error red
c_cost='\033[38;2;229;192;123m'   # #E5C07B  _PC_BUSY gold
reset='\033[0m'

# Nerd Font icons via UTF-8 hex bytes
ICO_DIR=$(printf '\xEF\x81\xBC')  # U+F07C  fa-folder-open
ICO_GIT=$(printf '\xEE\x82\xA0')  # U+E0A0  powerline branch
ICO_BOT=$(printf '\xEF\x80\x93')  # U+F013  fa-cog (FA4, universal)
ICO_USD=$(printf '\xEF\x83\x96')  # U+F0D6  fa-money (banknote/cash, FA4)
ICO_ZAP=$(printf '\xEF\x83\xA7')  # U+F0E7  fa-bolt
ICO_CAL=$(printf '\xEF\x81\xB3')  # U+F073  fa-calendar

SEP="  "
parts=""

# Directory
parts="${parts}$(printf "${c_dir}${ICO_DIR} %s${reset}" "$dir")"

# Git branch
if [ -n "$git_branch" ]; then
  parts="${parts}${SEP}$(printf "${c_git}${ICO_GIT} %s${reset}" "$git_branch")"
fi

# Model + effort
if [ -n "$model" ]; then
  model_label="$model"
  [ -n "$effort" ] && model_label="$model ($effort)"
  parts="${parts}${SEP}$(printf "${c_model}${ICO_BOT} %s${reset}" "$model_label")"
fi

# Context bar + % + tokens
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")

  bar_total=10
  filled=$(( used_int * bar_total / 100 ))
  [ "$filled" -gt "$bar_total" ] && filled=$bar_total
  [ "$filled" -lt 0 ]            && filled=0
  empty=$(( bar_total - filled ))

  bar=""
  i=0; while [ "$i" -lt "$filled" ]; do bar="${bar}█"; i=$(( i + 1 )); done
  i=0; while [ "$i" -lt "$empty"  ]; do bar="${bar}░"; i=$(( i + 1 )); done

  if   [ "$used_int" -ge 80 ]; then bar_color="$c_err"
  elif [ "$used_int" -ge 50 ]; then bar_color="$c_warn"
  else                               bar_color="$c_ok"
  fi

  token_str=""
  if [ -n "$total_input" ] && [ -n "$ctx_size" ]; then
    token_str=$(awk -v used="$total_input" -v max="$ctx_size" '
      function fmt(n,   s) {
        if      (n >= 1000000) { s = sprintf("%.1f", n/1000000); sub(/\.?0+$/, "", s); return s "M" }
        else if (n >= 1000)    { s = sprintf("%.2f", n/1000);    sub(/\.?0+$/, "", s); return s "k" }
        else                   { return int(n) }
      }
      BEGIN { print fmt(used) "/" fmt(max) }
    ')
  fi

  ctx_part="$(printf "${bar_color}%s${reset} %s%%" "$bar" "$used_int")"
  [ -n "$token_str" ] && ctx_part="${ctx_part}$(printf " (%s)" "$token_str")"
  parts="${parts}${SEP}${ctx_part}"
fi

# Session cost
if [ -n "$cost" ]; then
  cost_fmt=$(awk -v c="$cost" 'BEGIN { printf "$%.2f", c }')
  parts="${parts}${SEP}$(printf "${c_cost}${ICO_USD} %s${reset}" "$cost_fmt")"
fi

# 5-hour rate limit
if [ -n "$five_pct" ]; then
  five_int=$(printf "%.0f" "$five_pct")
  if   [ "$five_int" -ge 80 ]; then rl_color="$c_err"
  elif [ "$five_int" -ge 50 ]; then rl_color="$c_warn"
  else                               rl_color="$c_ok"
  fi
  five_reset_str=""
  if [ -n "$five_reset" ]; then
    five_reset_str=$(date -r "$five_reset" "+%I:%M %p" 2>/dev/null \
                  || date -d "@$five_reset" "+%I:%M %p" 2>/dev/null)
    [ -n "$five_reset_str" ] && five_reset_str=" ($five_reset_str)"
  fi
  parts="${parts}${SEP}$(printf "${rl_color}${ICO_ZAP} 5h:%s%%%s${reset}" "$five_int" "$five_reset_str")"
fi

# 7-day rate limit
if [ -n "$week_pct" ]; then
  week_int=$(printf "%.0f" "$week_pct")
  if   [ "$week_int" -ge 80 ]; then rl_color="$c_err"
  elif [ "$week_int" -ge 50 ]; then rl_color="$c_warn"
  else                               rl_color="$c_ok"
  fi
  week_reset_str=""
  if [ -n "$week_reset" ]; then
    week_reset_str=$(date -r "$week_reset" "+%a %I:%M %p" 2>/dev/null \
                  || date -d "@$week_reset" "+%a %I:%M %p" 2>/dev/null)
    [ -n "$week_reset_str" ] && week_reset_str=" ($week_reset_str)"
  fi
  parts="${parts}${SEP}$(printf "${rl_color}${ICO_CAL} 7d:%s%%%s${reset}" "$week_int" "$week_reset_str")"
fi

printf "%b" "$parts"
