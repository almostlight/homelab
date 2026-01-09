#! /bin/bash

# Script to deploy user configuration and place executables on PATH

script_dir=$(dirname "$(realpath "$0")")
config_source="$script_dir/config"
bin_source="$script_dir/bin"

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

for item in "$bin_source"/*; do
    [[ -e "$item" ]] || continue
    
    itemname=$(basename "$item")
    target="/usr/local/bin/$itemname"
    
	if chmod +x "$item"; then
		echo "$item made executable"

		if cp -f "$item" "$target"; then
			echo "$itemname copied successfully"
		fi
	fi
done

