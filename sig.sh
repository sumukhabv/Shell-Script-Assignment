#!/bin/bash

CONFIG_FILE="sig.conf"

# Function to validate input against a list of valid options
validate_input() {
    local input=$1
    shift
    local valid_options=("$@")

    for option in "${valid_options[@]}"; do
        if [[ "$input" == "$option" ]]; then
            return 0
        fi
    done
    return 1
}

# Prompt and validate Component Name
while true; do
    read -rp "Enter Component Name [INGESTOR/JOINER/WRANGLER/VALIDATOR]: " component
    if validate_input "$component" "INGESTOR" "JOINER" "WRANGLER" "VALIDATOR"; then
        break
    else
        echo "Invalid component. Try again."
    fi
done

# Prompt and validate Scale
while true; do
    read -rp "Enter Scale [MID/HIGH/LOW]: " scale
    if validate_input "$scale" "MID" "HIGH" "LOW"; then
        break
    else
        echo "Invalid scale. Try again."
    fi
done

# Prompt and validate View
while true; do
    read -rp "Enter View [Auction/Bid]: " view
    if validate_input "$view" "Auction" "Bid"; then
        break
    else
        echo "Invalid view. Try again."
    fi
done

# Prompt and validate Count
while true; do
    read -rp "Enter Count [single digit 0-9]: " count
    if [[ "$count" =~ ^[0-9]$ ]]; then
        break
    else
        echo "Invalid count. Must be a single digit number."
    fi
done

# Determine the view string in the file
if [[ "$view" == "Auction" ]]; then
    view_str="vdopiasample"
else
    view_str="vdopiasample-bid"
fi

# Construct the search pattern
search_pattern="${view_str}; ${scale}; ${component}; ETL; vdopia-etl="

# Update the line (only one match) using `sed`
if grep -q "^${search_pattern}" "$CONFIG_FILE"; then
    sed -i "0,/^${search_pattern}.*/s//${search_pattern}${count}/" "$CONFIG_FILE"
    echo "Configuration updated successfully."
else
    echo "Matching line not found in $CONFIG_FILE."
fi

