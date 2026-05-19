#!/bin/bash
set -euo pipefail

COLORS_FILE="$HOME/.config/Code/User/colors.json"
SETTINGS_FILE="$HOME/.config/Code/User/settings.json"

if [[ ! -f "$COLORS_FILE" ]]; then
    echo "Colors file not found: $COLORS_FILE" >&2
    exit 1
fi

if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo '{}' > "$SETTINGS_FILE"
fi

jq --slurpfile colors "$COLORS_FILE" '
    . * {"material-code.colors": $colors[0]["material-code.colors"]}
' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"

echo "VSCode colors updated"