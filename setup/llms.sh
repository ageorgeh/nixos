#!/bin/bash

# Script to generate a markdown file with the content of all tracked files in the nixos-config

# Set variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$SCRIPT_DIR/nixos-config-context.md"

# Create or truncate the output file
echo "# NixOS Configuration Context for LLMs" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "Generated on $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Function to add a file's content to the markdown
add_file_to_md() {
    local file_path="$1"
    local rel_path="$(realpath --relative-to="$ROOT_DIR" "$file_path")"
    
    # Skip binary files and very large files
    if [[ -f "$file_path" && "$(file --mime-type -b "$file_path")" != binary* ]]; then
        file_size=$(wc -c < "$file_path")
        if [[ $file_size -gt 500000 ]]; then
            echo "Skipping large file: $rel_path ($file_size bytes)"
            echo "## File: $rel_path" >> "$OUTPUT_FILE"
            echo "**Note**: File too large to include ($file_size bytes)" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            return
        fi
        
        echo "## File: $rel_path" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        cat "$file_path" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
}

# Add overall repository structure
echo "## Repository Structure" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
cd "$ROOT_DIR" && find . -type f -not -path "*/\.git/*" | sort >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Get list of all git tracked files
echo "Collecting tracked files..."
cd "$ROOT_DIR" || exit 1
tracked_files=$(git ls-files)

# Add a section for the flake files
echo "## NixOS Configuration Files" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Process each tracked file
total_files=$(echo "$tracked_files" | wc -l)
current=0
echo "Processing $total_files files..."

for file in $tracked_files; do
    # Skip flake.lock file
    if [[ "$file" == "flake.lock" ]]; then
        echo "Skipping flake.lock file"
        continue
    fi
    
    current=$((current + 1))
    if [[ $((current % 10)) -eq 0 ]]; then
        echo "Progress: $current/$total_files files"
    fi
    
    full_path="$ROOT_DIR/$file"
    if [[ -f "$full_path" ]]; then
        add_file_to_md "$full_path"
    fi
done

echo "## System Overview" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "This NixOS configuration manages the system setup for user 'alex', including:" >> "$OUTPUT_FILE"
echo "- System configurations in 'hosts/'" >> "$OUTPUT_FILE"
echo "- Home-manager configurations in 'home/alex/'" >> "$OUTPUT_FILE"
echo "- Various dotfiles in 'home/alex/dotfiles/'" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Add info about the overall structure
cat >> "$OUTPUT_FILE" << 'EOF'
## Key Components

1. **flake.nix**: The entry point for the NixOS configuration
2. **hosts/**: System-wide configurations
3. **home/alex/**: User-specific configurations managed by home-manager
4. **setup/**: Scripts for system setup and maintenance
EOF

echo "Done! Context file generated at $OUTPUT_FILE"
echo "File size: $(du -h "$OUTPUT_FILE" | cut -f1)"