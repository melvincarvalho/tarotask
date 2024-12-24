#!/bin/bash

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

# Set the base directory relative to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$BASE_DIR/data"

# Function to display usage
show_usage() {
    echo "Usage: $(basename "$0") [hour|day]"
    echo "  hour: Pick an hourly tarot card"
    echo "  day:  Pick a daily tarot card (default)"
    exit 1
}

# Function to validate data directory
validate_data_dir() {
    if [[ ! -d "$DATA_DIR" ]]; then
        echo "Error: Data directory not found at $DATA_DIR"
        exit 1
    fi
    
    if [[ -z "$(find "$DATA_DIR" -name "*.json" -type f)" ]]; then
        echo "Error: No JSON files found in $DATA_DIR"
        echo "Please add tarot card data files to the data directory"
        exit 1
    fi
}

# Set card type based on argument
CARD_TYPE="day"  # default value
if [[ $# -gt 0 ]]; then
    case "$1" in
        "hour"|"day") CARD_TYPE="$1" ;;
        *) show_usage ;;
    esac
fi

# Validate data directory
validate_data_dir

# Find all matching files for the card type
mapfile -t FILES < <(find "$DATA_DIR" -name "${CARD_TYPE}_*.json" -type f)

# Check if we found any matching files
if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "Error: No files found matching pattern '${CARD_TYPE}_*.json' in $DATA_DIR"
    exit 1
fi

# Pick a random file
RANDOM_FILE="${FILES[RANDOM % ${#FILES[@]}]}"

# Verify file exists and is readable
if [[ ! -r "$RANDOM_FILE" ]]; then
    echo "Error: Selected file '$RANDOM_FILE' is not readable"
    exit 1
fi

# Print the file name and contents
echo "Selected card from: $(basename "$RANDOM_FILE")"
cat "$RANDOM_FILE"

