#!/bin/bash

# Handle Ctrl+C
trap 'echo "\nInterrupted. Exiting..."; exit 1' INT

temp_file=$(mktemp)
cp object_list.ini "$temp_file"

while IFS= read -r line; do
    # Skip empty lines and comments
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    
    echo "Processing: $line"
    if uv run main.py --prompt "$line"; then
        # Comment out the processed line (macOS compatible)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS (BSD sed)
            sed -i '' "s/^$(echo "$line" | sed 's/[[\/.^$(){}*+?|]/\\&/g')/# &/" object_list.ini
        else
            # Linux (GNU sed)
            sed -i "s/^$(echo "$line" | sed 's/[[\/.^$(){}*+?|]/\\&/g')/# &/" object_list.ini
        fi
    fi
done < "$temp_file"

rm "$temp_file"
echo "All objects processed."