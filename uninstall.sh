#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
BASHRC="$HOME/.bashrc"
START="# >>> MRAPRGUILD TERMUX SETUP >>>"
END="# <<< MRAPRGUILD TERMUX SETUP <<<"

if [ -f "$BASHRC" ]; then
  awk -v start="$START" -v end="$END" '
    $0 == start {skip=1; next}
    $0 == end {skip=0; next}
    !skip {print}
  ' "$BASHRC" > "$BASHRC.tmp"
  mv "$BASHRC.tmp" "$BASHRC"
fi

rm -rf "$HOME/.termux-welcome"
rm -f "$HOME/.local/bin/tw"
printf '\033[1;32mMRAPRGUILD Termux setup removed.\033[0m\n'
printf 'Your timestamped backup files were preserved.\n'
