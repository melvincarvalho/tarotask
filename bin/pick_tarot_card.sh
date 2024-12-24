#!/usr/bin/env bash

set -euo pipefail

# Safely resolve the actual location of this script
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

# The data directory is one level up from bin/
DATA_DIR="${SCRIPT_DIR}/../data"

# Function to display usage
show_usage() {
    echo "Usage: $(basename "$0") [hour|day]"
    echo "  hour: Pick an hourly tarot card"
    echo "  day:  Pick a daily tarot card (default)"
    exit 1
}

# Validate data directory
validate_data_dir() {
    if [[ ! -d "$DATA_DIR" ]]; then
        echo "Error: Data directory not found at $DATA_DIR"
        exit 1
    fi
    
    if [[ -z "$(find "$DATA_DIR" -name "*.json" -type f 2>/dev/null)" ]]; then
        echo "Error: No JSON files found in $DATA_DIR"
        exit 1
    fi
}

# Default to "day" if no argument
CARD_TYPE="day"
if [[ $# -gt 0 ]]; then
    case "$1" in
        hour|day) CARD_TYPE="$1" ;;
        *) show_usage ;;
    esac
fi

validate_data_dir

# Gather files
mapfile -t FILES < <(find "$DATA_DIR" -type f -name "${CARD_TYPE}_*.json")

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "Error: No files matching '${CARD_TYPE}_*.json' in $DATA_DIR"
    exit 1
fi

# Pick random file
RANDOM_FILE="${FILES[RANDOM % ${#FILES[@]}]}"

echo "Selected card from: $(basename "$RANDOM_FILE")"
cat "$RANDOM_FILE"
