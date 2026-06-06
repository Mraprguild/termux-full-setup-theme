#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
DIR="$HOME/.termux-welcome"
CONFIG="$DIR/config.conf"

mapfile -t themes < <(find "$DIR/themes" -maxdepth 1 -type f -name '*.theme' -printf '%f\n' | sed 's/\.theme$//' | sort)
current="$(sed -n 's/^TW_THEME="\([^"]*\)"/\1/p' "$CONFIG")"

printf '\033[1;36m\nTheme Manager\033[0m\n'
printf 'Current: \033[1;33m%s\033[0m\n\n' "$current"

for i in "${!themes[@]}"; do
  printf ' %2d) %s\n' "$((i+1))" "${themes[$i]}"
done
printf '  0) Exit\n\n'
read -r -p 'Choose theme: ' choice

[[ "$choice" =~ ^[0-9]+$ ]] || { echo "Invalid choice"; exit 1; }
(( choice == 0 )) && exit 0
(( choice >= 1 && choice <= ${#themes[@]} )) || { echo "Invalid choice"; exit 1; }

selected="${themes[$((choice-1))]}"
sed -i "s/^TW_THEME=.*/TW_THEME=\"$selected\"/" "$CONFIG"
printf '\033[1;32mTheme changed to %s\033[0m\n' "$selected"
bash "$DIR/welcome.sh"
