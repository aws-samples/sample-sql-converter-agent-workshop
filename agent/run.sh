#!/bin/bash

# Handle Ctrl+C
trap 'echo "\nInterrupted. Exiting..."; exit 1' INT

# Parse options
SYSTEM_PROMPT_OPT=""
CONFIG_FILE="object_list.ini"
while [[ $# -gt 0 ]]; do
    case $1 in
        --system-prompt)
            SYSTEM_PROMPT_OPT="--system-prompt $2"
            shift 2
            ;;
        -f|--file)
            CONFIG_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

temp_file=$(mktemp)
cp "$CONFIG_FILE" "$temp_file"

while IFS= read -r line; do
    # Skip empty lines and comments
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    
    echo "Processing: $line"
    if uv run main.py --prompt "$line" $SYSTEM_PROMPT_OPT; then
        # Comment out the processed line (macOS compatible)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS (BSD sed)
            sed -i '' "s/^$(echo "$line" | sed 's/[[\/.^$(){}*+?|]/\\&/g')/# &/" "$CONFIG_FILE"
        else
            # Linux (GNU sed)
            sed -i "s/^$(echo "$line" | sed 's/[[\/.^$(){}*+?|]/\\&/g')/# &/" "$CONFIG_FILE"
        fi
    fi
done < "$temp_file"

rm "$temp_file"
echo "All objects processed."