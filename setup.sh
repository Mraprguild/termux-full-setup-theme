#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

APP_NAME="Mraprguild Termux Full Setup"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.termux-welcome"
BIN_DIR="$HOME/.local/bin"
TERMUX_DIR="$HOME/.termux"
BASHRC="$HOME/.bashrc"
PROFILE="$HOME/.profile"
START="# >>> MRAPRGUILD TERMUX SETUP >>>"
END="# <<< MRAPRGUILD TERMUX SETUP <<<"

C_RESET='\033[0m'
C_CYAN='\033[1;36m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[1;31m'

log()  { printf "${C_CYAN}[•]${C_RESET} %s\n" "$*"; }
ok()   { printf "${C_GREEN}[✓]${C_RESET} %s\n" "$*"; }
warn() { printf "${C_YELLOW}[!]${C_RESET} %s\n" "$*"; }
die()  { printf "${C_RED}[✗]${C_RESET} %s\n" "$*" >&2; exit 1; }

command -v pkg >/dev/null 2>&1 || die "Run this installer inside Termux."

backup_file() {
  local file="$1"
  [ -e "$file" ] || return 0
  cp -a "$file" "${file}.mraprguild-backup.$(date +%Y%m%d-%H%M%S)"
}

remove_block() {
  local file="$1"
  [ -f "$file" ] || return 0
  awk -v start="$START" -v end="$END" '
    $0 == start {skip=1; next}
    $0 == end {skip=0; next}
    !skip {print}
  ' "$file" > "${file}.tmp"
  mv "${file}.tmp" "$file"
}

printf "\n${C_CYAN}╔══════════════════════════════════════════╗\n"
printf "║       MRAPRGUILD TERMUX FULL SETUP       ║\n"
printf "╚══════════════════════════════════════════╝${C_RESET}\n\n"

log "Updating package metadata"
pkg update -y

log "Installing required packages"
pkg install -y bash coreutils procps util-linux grep sed gawk findutils \
  figlet toilet git curl wget nano vim zip unzip tar jq ncurses-utils \
  openssh command-not-found termux-api 2>/dev/null || {
    warn "Some optional packages were unavailable; installing the required core."
    pkg install -y bash coreutils procps util-linux grep sed gawk findutils figlet git curl nano jq
  }

mkdir -p "$INSTALL_DIR/themes" "$BIN_DIR" "$TERMUX_DIR"

log "Backing up existing configuration"
backup_file "$BASHRC"
backup_file "$PROFILE"
backup_file "$TERMUX_DIR/termux.properties"
backup_file "$TERMUX_DIR/colors.properties"

cp "$SOURCE_DIR/welcome.sh" "$INSTALL_DIR/"
cp "$SOURCE_DIR/config.conf" "$INSTALL_DIR/"
cp "$SOURCE_DIR/theme-manager.sh" "$INSTALL_DIR/"
cp "$SOURCE_DIR/setup-manager.sh" "$INSTALL_DIR/"
cp "$SOURCE_DIR/uninstall.sh" "$INSTALL_DIR/"
cp "$SOURCE_DIR/themes/"*.theme "$INSTALL_DIR/themes/"
chmod +x "$INSTALL_DIR/"*.sh

cp "$SOURCE_DIR/bin/tw" "$BIN_DIR/tw"
chmod +x "$BIN_DIR/tw"

# UI configuration is copied as a regular file because Termux configuration
# files should not depend on symlink behavior.
cp "$SOURCE_DIR/termux-ui/termux.properties" "$TERMUX_DIR/termux.properties"
cp "$SOURCE_DIR/termux-ui/colors.properties" "$TERMUX_DIR/colors.properties"

touch "$BASHRC" "$PROFILE"
remove_block "$BASHRC"
cat >> "$BASHRC" <<'EOF'

# >>> MRAPRGUILD TERMUX SETUP >>>
export PATH="$HOME/.local/bin:$PATH"
if [ -r "$HOME/.termux-welcome/welcome.sh" ]; then
  . "$HOME/.termux-welcome/welcome.sh"
fi
# <<< MRAPRGUILD TERMUX SETUP <<<
EOF

# Make ~/.local/bin available to login shells too.
if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$PROFILE"; then
  printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$PROFILE"
fi

if command -v termux-reload-settings >/dev/null 2>&1; then
  termux-reload-settings || true
fi

ok "Full setup installed"
printf "\nCommands:\n"
printf "  ${C_YELLOW}tw${C_RESET}                 Open setup manager\n"
printf "  ${C_YELLOW}tw theme${C_RESET}           Change welcome theme\n"
printf "  ${C_YELLOW}tw config${C_RESET}          Edit configuration\n"
printf "  ${C_YELLOW}tw preview${C_RESET}         Preview welcome screen\n"
printf "  ${C_YELLOW}source ~/.bashrc${C_RESET}   Activate now\n\n"
