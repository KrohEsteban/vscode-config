#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS_SRC="$REPO_DIR/vscode/settings.json"
EXTENSIONS_SRC="$REPO_DIR/vscode/extensions.json"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

print_header() { echo -e "\n${BOLD}${CYAN}$1${RESET}"; }
print_ok()     { echo -e "  ${GREEN}✔${RESET} $1"; }
print_warn()   { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
print_err()    { echo -e "  ${RED}✘${RESET} $1"; }

# --- step 1: choose editor ---------------------------------------------------
print_header "Step 1 — Editor"
echo "  1) VSCode   (code)"
echo "  2) Cursor   (cursor)"
echo ""
read -rp "  Choice [1-2]: " editor_choice

case "$editor_choice" in
    1)
        CLI="code"
        SETTINGS_DIR="$HOME/.config/Code/User"
        ;;
    2)
        CLI="cursor"
        SETTINGS_DIR="$HOME/.config/Cursor/User"
        ;;
    *)
        print_err "Invalid choice."
        exit 1
        ;;
esac

if ! command -v "$CLI" &>/dev/null; then
    print_err "'$CLI' command not found — make sure the editor is installed and in PATH."
    exit 1
fi

print_ok "Editor: $CLI → $SETTINGS_DIR"

# --- step 2: install settings ------------------------------------------------
print_header "Step 2 — User settings"

mkdir -p "$SETTINGS_DIR"

if [[ -f "$SETTINGS_DIR/settings.json" ]]; then
    BACKUP="$SETTINGS_DIR/settings.json.bak"
    cp "$SETTINGS_DIR/settings.json" "$BACKUP"
    print_warn "Existing settings backed up to: $BACKUP"
fi

cp "$SETTINGS_SRC" "$SETTINGS_DIR/settings.json"
print_ok "Settings installed: $SETTINGS_DIR/settings.json"

# --- step 3: install extensions ----------------------------------------------
print_header "Step 3 — Extensions"

# Parse extension IDs from extensions.json (lines with quoted strings before //)
EXTENSIONS=$(grep -oP '"[a-zA-Z0-9._-]+\.[a-zA-Z0-9._-]+"' "$EXTENSIONS_SRC" | tr -d '"')

for ext in $EXTENSIONS; do
    echo -n "  Installing $ext ... "
    if $CLI --install-extension "$ext" --force &>/dev/null; then
        echo -e "${GREEN}✔${RESET}"
    else
        echo -e "${YELLOW}⚠ failed (may already be installed or unavailable)${RESET}"
    fi
done

print_header "Done"
echo -e "  ${GREEN}Settings and extensions installed for $CLI${RESET}"
echo ""
