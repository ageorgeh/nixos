#!/usr/bin/env bash

# This script exists so that we can specifically format the svelte parts of a
# svx file with the svelte formatter and the mdx parts with the mdx formatter


set -euo pipefail

tmpfile=$(mktemp)
cat - > "$tmpfile"

# Step 1: Prettify the whole input as MDX first
mdx_output=$(prettierd test.svx --parser=mdx < "$tmpfile")

# process <script> blocks, inline or multi-line
while IFS= read -r line; do
  # single-line <script>…</script>
  if [[ $line =~ \<script([^>]*)\>(.*)\<\/script\> ]]; then
    formatted=$(printf "$line" | prettierd test.svx --parser=svelte )
    printf "$formatted\n" 

  # start of multi-line <script>
  elif [[ $line =~ \<script([^>]*)\> ]]; then
    buffer="$line"$'\n'
    # collect until closing </script>
    while IFS= read -r inner; do
      if [[ $inner =~ \</script\> ]]; then
        buffer+="$inner"$'\n'
        formatted=$(printf "%s" "$buffer" | prettierd test.svx --parser=svelte )
        printf "$formatted\n"
        break
      else
        buffer+="$inner"$'\n'
      fi
    done

  # anything else
  else
    printf '%s\n' "$line"
  fi
done <<< "$mdx_output"


rm "$tmpfile"

