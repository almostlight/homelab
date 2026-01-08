#! /bin/bash

# link files
script_dir=$(dirname "$(realpath "$0")")
config_source="$script_dir/config"

if [[ ! -d "$config_source" ]]; then
    echo "Error: Configuration source directory not found: $config_source" >&2
    exit 1
fi

for item in "$config_source"/*; do
    [[ -e "$item" ]] || continue
    
    itemname=$(basename "$item")
    target="$HOME/.config/$itemname"
    
    # backup existing config
    if [[ -e "$target" || -L "$target" ]]; then
        backup_path="$target.bk"
        mv "$target" "$backup_path"
    fi
    
    # link config files
    if ln -sf "$item" "$target"; then
        echo "$itemname linked successfully"
    else
        echo "Failed to link $itemname" >&2
        exit 1
    fi
done

