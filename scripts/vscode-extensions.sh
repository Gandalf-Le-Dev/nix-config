#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/vscode-extensions.txt"

# Check if VS Code is installed
if ! command -v code &> /dev/null; then
    echo "VS Code (code command) not found in PATH. Skipping extension sync."
    exit 0
fi

# Check if extensions file exists
if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "Extensions file not found: $EXTENSIONS_FILE"
    exit 1
fi

echo "Syncing VS Code extensions..."

# Read desired extensions (compatible with older bash)
DESIRED_EXTENSIONS=()
while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    DESIRED_EXTENSIONS+=("$line")
done < "$EXTENSIONS_FILE"

# Get currently installed extensions
INSTALLED_EXTENSIONS=()
while IFS= read -r line; do
    INSTALLED_EXTENSIONS+=("$line")
done < <(code --list-extensions 2>/dev/null || true)

# Install missing extensions
for ext in "${DESIRED_EXTENSIONS[@]}"; do
    if [[ ! " ${INSTALLED_EXTENSIONS[*]} " =~ " ${ext} " ]]; then
        echo "Installing: $ext"
        code --install-extension "$ext" --force
    fi
done

# Prune unlisted extensions (only if --prune flag is passed)
if [[ "${1:-}" == "--prune" ]]; then
    echo "Pruning unlisted extensions..."
    for ext in "${INSTALLED_EXTENSIONS[@]}"; do
        if [[ ! " ${DESIRED_EXTENSIONS[*]} " =~ " ${ext} " ]]; then
            echo "Uninstalling: $ext"
            code --uninstall-extension "$ext"
        fi
    done
fi

echo "VS Code extension sync complete!"
