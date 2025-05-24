#!/usr/bin/env bash

set -euo pipefail

tmpfile=$(mktemp)
cat - > "$tmpfile"

# Step 1: Prettify the whole input as MDX first
mdx_output=$(prettierd test.svx --parser=mdx < "$tmpfile")

# Step 2: Re-format any <tag>…</tag> regions with the Svelte parser
while IFS= read -r line; do
  # single-line <tag>…</tag>
  if [[ $line =~ \<([[:alnum:]]+)([^>]*)\>(.*)\<\/\1\> ]]; then
    printf "%s\n" "$line" \
      | prettierd test.svx --parser=svelte
  # start of a multi-line <tag>
  elif [[ $line =~ \<([[:alnum:]]+)([^>]*)\> ]]; then
    tag="${BASH_REMATCH[1]}"
    buffer="$line"$'\n'
    # collect until matching </tag>
    while IFS= read -r inner; do
      buffer+="$inner"$'\n'
      if [[ $inner =~ \</$tag\> ]]; then
        printf "%s" "$buffer" \
          | prettierd test.svx --parser=svelte
        break
      fi
    done
  # everything else
  else
    printf '%s\n' "$line"
  fi
done <<< "$mdx_output"

rm "$tmpfile"

