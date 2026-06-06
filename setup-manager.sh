#!/data/data/com.termux/files/usr/bin/bash
set -u
DIR="$HOME/.termux-welcome"
CONFIG="$DIR/config.conf"

pause() { printf '\nPress Enter to continue...'; read -r _; }

while true; do
  clear
  printf '\033[1;36m╔══════════════════════════════════╗\n'
  printf '║   MRAPRGUILD TERMUX MANAGER      ║\n'
  printf '╚══════════════════════════════════╝\033[0m\n\n'
  printf ' 1) Preview welcome screen\n'
  printf ' 2) Change theme\n'
  printf ' 3) Edit full configuration\n'
  printf ' 4) Change title\n'
  printf ' 5) Change subtitle\n'
  printf ' 6) Toggle battery information\n'
  printf ' 7) Toggle network information\n'
  printf ' 8) Toggle custom prompt\n'
  printf ' 9) Reload Termux settings\n'
  printf '10) Show configuration path\n'
  printf '11) Uninstall\n'
  printf ' 0) Exit\n\n'
  read -r -p 'Select: ' choice

  case "$choice" in
    1) bash "$DIR/welcome.sh"; pause ;;
    2) bash "$DIR/theme-manager.sh"; pause ;;
    3) "${EDITOR:-nano}" "$CONFIG" ;;
    4)
      read -r -p 'New title: ' value
      sed -i "s|^TW_TITLE=.*|TW_TITLE=\"$value\"|" "$CONFIG"
      ;;
    5)
      read -r -p 'New subtitle: ' value
      sed -i "s|^TW_SUBTITLE=.*|TW_SUBTITLE=\"$value\"|" "$CONFIG"
      ;;
    6) bash "$0" --toggle TW_SHOW_BATTERY; pause ;;
    7) bash "$0" --toggle TW_SHOW_NETWORK; pause ;;
    8) bash "$0" --toggle TW_PROMPT_ENABLED; pause ;;
    9)
      termux-reload-settings 2>/dev/null && echo "Settings reloaded." || echo "Restart Termux."
      pause
      ;;
    10) printf '\n%s\n' "$CONFIG"; pause ;;
    11) bash "$DIR/uninstall.sh"; exit ;;
    0) exit ;;
    --toggle)
      key="${2:-}"
      current="$(sed -n "s/^${key}=//p" "$CONFIG")"
      [ "$current" = true ] && next=false || next=true
      sed -i "s/^${key}=.*/${key}=${next}/" "$CONFIG"
      echo "$key changed to $next"
      exit
      ;;
    *) echo "Invalid selection"; sleep 1 ;;
  esac
done
