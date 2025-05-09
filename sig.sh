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

# Create the new line for the config file
new_line="$view_str ; $scale ; $component ; ETL ; vdopia-etl=$count"

# Check if sig.conf exists
if [ ! -f "sig.conf" ]; then
    echo "Creating new sig.conf file"
    echo "$new_line" > sig.conf
    echo "Configuration added successfully!"
    exit 0
fi

# Check if component exists in file
if grep -q " $component " "sig.conf"; then
    # Replace existing line
    sed -i "s/.*; $component ;.*/$new_line/" sig.conf
    echo "Updated configuration for $component in sig.conf"
else
    # Add new line
    echo "$new_line" >> sig.conf
    echo "Added new configuration for $component to sig.conf"
fi

echo "Configuration set to: $new_line"

