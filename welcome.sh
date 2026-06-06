#!/data/data/com.termux/files/usr/bin/bash
# shellcheck shell=bash

[[ $- == *i* ]] || return 0 2>/dev/null || exit 0

TW_HOME="$HOME/.termux-welcome"
TW_CONFIG="$TW_HOME/config.conf"

# Defaults
TW_ENABLED=true
TW_THEME="cyber"
TW_TITLE="MRAPRGUILD"
TW_SUBTITLE="FULL TERMUX DEVELOPMENT ENVIRONMENT"
TW_CLEAR_SCREEN=true
TW_SHOW_LOGO=true
TW_SHOW_GREETING=true
TW_SHOW_USER=true
TW_SHOW_DEVICE=true
TW_SHOW_ANDROID=true
TW_SHOW_KERNEL=true
TW_SHOW_ARCH=true
TW_SHOW_SHELL=true
TW_SHOW_PACKAGES=true
TW_SHOW_UPTIME=true
TW_SHOW_STORAGE=true
TW_SHOW_MEMORY=true
TW_SHOW_BATTERY=true
TW_SHOW_NETWORK=false
TW_SHOW_DATE=true
TW_SHOW_TIME=true
TW_SHOW_TIP=true
TW_RANDOM_TIP=true
TW_PROMPT_ENABLED=true
TW_PROMPT_SHOW_EXIT=true
TW_PROMPT_SHOW_TIME=false
TW_PROMPT_SYMBOL="❯"
TW_DIVIDER_WIDTH=64

[ -r "$TW_CONFIG" ] && . "$TW_CONFIG"
[ "$TW_ENABLED" = true ] || return 0

THEME="$TW_HOME/themes/${TW_THEME}.theme"
[ -r "$THEME" ] && . "$THEME"

RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

has() { command -v "$1" >/dev/null 2>&1; }

cols() {
  local n
  n="$(tput cols 2>/dev/null || printf 80)"
  (( n > 100 )) && n=100
  (( n < 36 )) && n=36
  printf '%s' "$n"
}

divider() {
  local max="$TW_DIVIDER_WIDTH" current
  current="$(cols)"
  (( max > current - 2 )) && max=$((current - 2))
  printf '%*s' "$max" '' | tr ' ' "${TW_DIVIDER_CHAR:--}"
}

getprop_safe() { getprop "$1" 2>/dev/null | tr -d '\r'; }

device_name() {
  local brand model
  brand="$(getprop_safe ro.product.manufacturer)"
  model="$(getprop_safe ro.product.model)"
  printf '%s %s' "$brand" "$model" | awk '{$1=$1};1'
}

package_count() {
  dpkg-query -W -f='${binary:Package}\n' 2>/dev/null | wc -l | tr -d ' '
}

storage_info() {
  df -h "$HOME" 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " used " $5}'
}

memory_info() {
  free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2}'
}

battery_info() {
  if has termux-battery-status; then
    local json pct status temp
    json="$(timeout 2 termux-battery-status 2>/dev/null || true)"
    pct="$(printf '%s' "$json" | jq -r '.percentage // empty' 2>/dev/null)"
    status="$(printf '%s' "$json" | jq -r '.status // empty' 2>/dev/null)"
    temp="$(printf '%s' "$json" | jq -r '.temperature // empty' 2>/dev/null)"
    if [ -n "$pct" ]; then
      printf '%s%% %s' "$pct" "$status"
      [ -n "$temp" ] && printf ' • %s°C' "$temp"
    else
      printf 'API unavailable'
    fi
  else
    printf 'Install Termux:API'
  fi
}

network_info() {
  ip -o -4 addr show scope global 2>/dev/null |
    awk 'NR==1 {split($4,a,"/"); print a[1]}'
}

greeting() {
  local h
  h="$(date +%H)"
  if ((10#$h < 12)); then printf 'Good morning'
  elif ((10#$h < 17)); then printf 'Good afternoon'
  elif ((10#$h < 21)); then printf 'Good evening'
  else printf 'Good night'
  fi
}

row() {
  printf "${TW_ACCENT}%s${RESET} ${TW_LABEL}%-11s${RESET} ${TW_TEXT}%s${RESET}\n" \
    "$1" "$2" "${3:-N/A}"
}

logo() {
  if [ "$TW_SHOW_LOGO" = true ] && has figlet && (( $(cols) >= 48 )); then
    printf "${TW_PRIMARY}${BOLD}"
    figlet -f "${TW_FONT:-small}" "$TW_TITLE" 2>/dev/null || printf '%s\n' "$TW_TITLE"
    printf "${RESET}"
  else
    printf "${TW_PRIMARY}${BOLD}%s${RESET}\n" "$TW_TITLE"
  fi
  printf "${TW_SECONDARY}${BOLD}%s${RESET}\n" "$TW_SUBTITLE"
}

tips=(
  "Use pkg search NAME to find packages."
  "Use pkg upgrade to update installed packages."
  "Run termux-setup-storage before using shared storage."
  "Use Ctrl+L to clear the terminal."
  "Run tw to open the setup manager."
  "Run tw theme to switch the color preset."
  "Use ssh-keygen to create an SSH key."
  "Use command-not-found to identify missing commands."
)

render() {
  [ "$TW_CLEAR_SCREEN" = true ] && clear
  logo
  printf "${TW_BORDER}%s${RESET}\n" "$(divider)"
  [ "$TW_SHOW_GREETING" = true ] && row "◆" "Welcome" "$(greeting), ${USER:-user}"
  [ "$TW_SHOW_USER" = true ]     && row "●" "User" "${USER:-$(whoami)}"
  [ "$TW_SHOW_DEVICE" = true ]   && row "◆" "Device" "$(device_name)"
  [ "$TW_SHOW_ANDROID" = true ]  && row "◆" "Android" "$(getprop_safe ro.build.version.release)"
  [ "$TW_SHOW_KERNEL" = true ]   && row "◆" "Kernel" "$(uname -r)"
  [ "$TW_SHOW_ARCH" = true ]     && row "◆" "Arch" "$(uname -m)"
  [ "$TW_SHOW_SHELL" = true ]    && row "◆" "Shell" "${SHELL##*/}"
  [ "$TW_SHOW_PACKAGES" = true ] && row "◆" "Packages" "$(package_count)"
  [ "$TW_SHOW_UPTIME" = true ]   && row "◆" "Uptime" "$(uptime -p 2>/dev/null | sed 's/^up //')"
  [ "$TW_SHOW_STORAGE" = true ]  && row "◆" "Storage" "$(storage_info)"
  [ "$TW_SHOW_MEMORY" = true ]   && row "◆" "Memory" "$(memory_info)"
  [ "$TW_SHOW_BATTERY" = true ]  && row "◆" "Battery" "$(battery_info)"
  [ "$TW_SHOW_NETWORK" = true ]  && row "◆" "Local IP" "$(network_info)"
  [ "$TW_SHOW_DATE" = true ]     && row "◆" "Date" "$(date '+%A, %d %B %Y')"
  [ "$TW_SHOW_TIME" = true ]     && row "◆" "Time" "$(date '+%I:%M:%S %p')"
  printf "${TW_BORDER}%s${RESET}\n" "$(divider)"

  if [ "$TW_SHOW_TIP" = true ]; then
    local i=0
    [ "$TW_RANDOM_TIP" = true ] && i=$((RANDOM % ${#tips[@]}))
    printf "\n${TW_ACCENT}${BOLD}TIP${RESET} ${TW_TEXT}%s${RESET}\n" "${tips[$i]}"
  fi
  printf '\n'
}

prompt_command_tw() {
  TW_LAST_STATUS=$?
}
PROMPT_COMMAND="prompt_command_tw${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

build_prompt() {
  local status_segment="" time_segment=""
  [ "$TW_PROMPT_SHOW_EXIT" = true ] &&
    status_segment="\[${TW_ACCENT}\][${TW_LAST_STATUS:-0}]\[${RESET}\] "
  [ "$TW_PROMPT_SHOW_TIME" = true ] &&
    time_segment="\[${TW_SECONDARY}\]\A \[${RESET}\]"
  PS1="${status_segment}${time_segment}\[${TW_PRIMARY}\]\u\[${TW_TEXT}\]@\[${TW_SECONDARY}\]\h \[${TW_ACCENT}\]\w\n\[${TW_PRIMARY}\]${TW_PROMPT_SYMBOL} \[${RESET}\]"
}

render
[ "$TW_PROMPT_ENABLED" = true ] && build_prompt

alias welcome='bash "$HOME/.termux-welcome/welcome.sh"'
alias theme-manager='bash "$HOME/.termux-welcome/theme-manager.sh"'
