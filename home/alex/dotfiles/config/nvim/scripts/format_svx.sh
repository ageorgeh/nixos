#!/usr/bin/env bash

set -euo pipefail

tmpfile=$(mktemp)
cat - > "$tmpfile"


# Step 1: Prettify the whole input as MDX first
mdx_output=$(prettierd test.mdx --parser=mdx < "$tmpfile")


# Step 2: Re-format any <tag>…</tag> regions with the Svelte parser
while IFS= read -r line; do
  # single-line <tag>…</tag>
  if [[ $line =~ \<[[:alnum:]]+[^\>]*\>(.*)\<\/[[:alnum:]]+\> ]]; then
    printf "%s\n" "$line" \
      | prettierd test.svelte --parser=svelte

  # start of a multi-line <tag>
  elif [[ $line =~ \<([[:alnum:]]+)([^>]*)\> ]]; then
    tag="${BASH_REMATCH[1]}"
    buffer="$line"$'\n'
    depth=1
    while IFS= read -r inner; do
      buffer+="$inner"$'\n'
      # Increase depth for nested opening tags
      if [[ $inner =~ \<$tag([^>]*)\> ]]; then
        ((depth++))
      fi
      # Decrease depth for closing tags
      if [[ $inner =~ \<\/$tag\> ]]; then
        ((depth--))
        if [[ $depth -eq 0 ]]; then
          printf "%s" "$buffer" \
            | prettierd test.svelte --parser=svelte
          break
        fi
      fi
    done
  # everything else
  else
    printf '%s\n' "$line"
  fi
done <<< "$mdx_output"

rm "$tmpfile"
#!/usr/bin/env bash

set -euo pipefail

tmpfile=$(mktemp)
cat - > "$tmpfile"


# Step 1: Prettify the whole input as MDX first
mdx_output=$(prettierd test.mdx --parser=mdx < "$tmpfile")


# Step 2: Re-format any <tag>…</tag> regions with the Svelte parser
while IFS= read -r line; do
  # single-line <tag>…</tag>
  if [[ $line =~ \<[[:alnum:]]+[^\>]*\>(.*)\<\/[[:alnum:]]+\> ]]; then
    printf "%s\n" "$line" \
      | prettierd test.svelte --parser=svelte

  # start of a multi-line <tag>
  elif [[ $line =~ \<([[:alnum:]]+)([^>]*)\> ]]; then
    tag="${BASH_REMATCH[1]}"
    buffer="$line"$'\n'
    depth=1
    while IFS= read -r inner; do
      buffer+="$inner"$'\n'
      # Increase depth for nested opening tags
      if [[ $inner =~ \<$tag([^>]*)\> ]]; then
        ((depth++))
      fi
      # Decrease depth for closing tags
      if [[ $inner =~ \<\/$tag\> ]]; then
        ((depth--))
        if [[ $depth -eq 0 ]]; then
          printf "%s" "$buffer" \
            | prettierd test.svelte --parser=svelte
          break
        fi
      fi
    done
  # everything else
  else
    printf '%s\n' "$line"
  fi
done <<< "$mdx_output"

rm "$tmpfile"

