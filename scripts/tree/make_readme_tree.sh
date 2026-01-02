#!/usr/bin/env bash
# make_readme_tree.sh
#
# Features:
#   - "stop here" directories (do not recurse below them)
#   - inline comments for specific paths
#   - respects .gitignore (via `git check-ignore`) when inside a git repo

set -euo pipefail

ROOT="."
MARKDOWN=0
SHOW_HIDDEN=0
MAX_DEPTH=""            # global max depth (optional)
RESPECT_GITIGNORE=1     # default on

declare -a STOP_PATHS=()
declare -a IGNORE_PATHS=()
declare -A COMMENTS=()
declare -A IGNORE_CACHE=()

usage() {
  cat <<'EOF'
Usage:
  make_readme_tree.sh [options]

Options:
  -r, --root PATH           Root directory to print (default: .)
  -s, --stop PATH           Stop descending below PATH (repeatable)
  -S, --stop-file FILE      File with stop paths, one per line (# comments allowed)
  -c, --comment SPEC        Add inline comment. SPEC format: path:comment
  -C, --comment-file FILE   File with comments, one per line: path:comment (# allowed)
  -i, --ignore PATH         Ignore PATH (repeatable; skips files/dirs)
  -I, --ignore-file FILE    File with ignore paths, one per line (# comments allowed)
  -a, --all                 Include hidden files/dirs (dotfiles)
  -d, --depth N             Global max depth (optional; applies everywhere)
  -m, --markdown            Wrap output in Markdown fenced code block
      --no-gitignore        Do not apply .gitignore rules
  -h, --help                Show help

Notes:
  - Paths can be absolute or relative. Relative paths are resolved from --root.
  - Ignored paths are detected using `git check-ignore` (matches .gitignore, .git/info/exclude, global excludes).
EOF
}

trim() { sed -e 's/^[[:space:]]\+//' -e 's/[[:space:]]\+$//' <<<"$1"; }

# Normalize path to absolute (best-effort). realpath -m is ideal if available.
abspath() {
  local p="$1"
  if command -v realpath >/dev/null 2>&1; then
    realpath -m "$p"
  else
    if [[ "$p" = /* ]]; then
      echo "$p"
    else
      echo "$(cd "$ROOT" && pwd)/$p"
    fi
  fi
}

add_stop() {
  local p; p="$(trim "$1")"
  [[ -z "$p" ]] && return 0
  STOP_PATHS+=("$(abspath "$p")")
}

add_ignore() {
  local p; p="$(trim "$1")"
  [[ -z "$p" ]] && return 0
  IGNORE_PATHS+=("$(abspath "$p")")
}

add_comment() {
  local spec="$1"
  local path="${spec%%:*}"
  local comment="${spec#*:}"
  path="$(trim "$path")"
  comment="$(trim "$comment")"
  [[ -z "$path" || -z "$comment" ]] && return 0
  COMMENTS["$(abspath "$path")"]="$comment"
}

read_stop_file() {
  local f="$1" line
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(trim "$line")"
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    add_stop "$line"
  done < "$f"
}

read_comment_file() {
  local f="$1" line
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(trim "$line")"
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    add_comment "$line"
  done < "$f"
}

read_ignore_file() {
  local f="$1" line
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(trim "$line")"
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    add_ignore "$line"
  done < "$f"
}

is_stopped_dir() {
  local dir_abs="$1" sp
  for sp in "${STOP_PATHS[@]}"; do
    [[ "$dir_abs" == "$sp" ]] && return 0
  done
  return 1
}

is_ignored_by_user() {
  local abs="$1" ip
  for ip in "${IGNORE_PATHS[@]}"; do
    if [[ "$abs" == "$ip" || "$abs" == "$ip/"* ]]; then
      return 0
    fi
  done
  return 1
}

should_skip_hidden() {
  local name="$1"
  [[ "$SHOW_HIDDEN" -eq 0 && "$name" == .* ]]
}

print_entry() {
  local prefix="$1" connector="$2" label="$3" abs_path="$4"
  local suffix=""
  if [[ -n "${COMMENTS[$abs_path]+x}" ]]; then
    suffix="  # ${COMMENTS[$abs_path]}"
  fi
  echo "${prefix}${connector}${label}${suffix}"
}

ROOT_ABS=""
IN_GIT_REPO=0

rel_from_root() {
  local abs="$1"
  if [[ "$abs" == "$ROOT_ABS" ]]; then
    echo "."
  elif [[ "$abs" == "$ROOT_ABS/"* ]]; then
    echo "${abs#$ROOT_ABS/}"
  else
    echo "$abs"
  fi
}

# Returns 0 if path should be ignored (i.e., skipped), 1 otherwise.
is_ignored() {
  if is_ignored_by_user "$1"; then
    return 0
  fi

  [[ "$RESPECT_GITIGNORE" -eq 0 || "$IN_GIT_REPO" -eq 0 ]] && return 1

  local abs="$1"
  local rel; rel="$(rel_from_root "$abs")"

  # cache key: rel
  if [[ -n "${IGNORE_CACHE[$rel]+x}" ]]; then
    [[ "${IGNORE_CACHE[$rel]}" == "1" ]] && return 0 || return 1
  fi

  # git check-ignore exit 0 if ignored, 1 if not ignored
  if (cd "$ROOT_ABS" && git check-ignore -q -- "$rel" 2>/dev/null); then
    IGNORE_CACHE["$rel"]="1"
    return 0
  else
    IGNORE_CACHE["$rel"]="0"
    return 1
  fi
}

walk_dir() {
  local dir_abs="$1" prefix="$2" depth="$3"

  if [[ -n "$MAX_DEPTH" && "$depth" -ge "$MAX_DEPTH" ]]; then
    return 0
  fi

  # If this directory itself is ignored, skip it completely.
  if is_ignored "$dir_abs"; then
    return 0
  fi

  # Stop points: print dir (already printed by caller), but do not descend.
  if is_stopped_dir "$dir_abs"; then
    return 0
  fi

  local -a children=()
  local entry name

  while IFS= read -r -d '' entry; do
    name="$(basename "$entry")"

    if should_skip_hidden "$name"; then
      continue
    fi

    if is_ignored "$entry"; then
      continue
    fi

    children+=("$entry")
  done < <(find "$dir_abs" -mindepth 1 -maxdepth 1 -print0 2>/dev/null | sort -z)

  local count="${#children[@]}" i=0
  for entry in "${children[@]}"; do
    i=$((i+1))
    local connector="├── "
    local next_prefix="${prefix}│   "
    if [[ "$i" -eq "$count" ]]; then
      connector="└── "
      next_prefix="${prefix}    "
    fi

    local base; base="$(basename "$entry")"

    if [[ -d "$entry" ]]; then
      print_entry "$prefix" "$connector" "${base}/" "$entry"
      walk_dir "$entry" "$next_prefix" "$((depth+1))"
    else
      print_entry "$prefix" "$connector" "$base" "$entry"
    fi
  done
}

# -------- arg parsing --------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--root) ROOT="$2"; shift 2;;
    -s|--stop) add_stop "$2"; shift 2;;
    -S|--stop-file) read_stop_file "$2"; shift 2;;
    -c|--comment) add_comment "$2"; shift 2;;
    -C|--comment-file) read_comment_file "$2"; shift 2;;
    -i|--ignore) add_ignore "$2"; shift 2;;
    -I|--ignore-file) read_ignore_file "$2"; shift 2;;
    -a|--all) SHOW_HIDDEN=1; shift;;
    -d|--depth) MAX_DEPTH="$2"; shift 2;;
    -m|--markdown) MARKDOWN=1; shift;;
    --no-gitignore) RESPECT_GITIGNORE=0; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1;;
  esac
done

ROOT_ABS="$(abspath "$ROOT")"
[[ -d "$ROOT_ABS" ]] || { echo "Root is not a directory: $ROOT" >&2; exit 1; }

if [[ "$RESPECT_GITIGNORE" -eq 1 ]] && command -v git >/dev/null 2>&1; then
  if (cd "$ROOT_ABS" && git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    IN_GIT_REPO=1
  fi
fi

if [[ "$MARKDOWN" -eq 1 ]]; then
  echo '```bash'
fi

echo "$(basename "$ROOT_ABS")/"
walk_dir "$ROOT_ABS" "" 0

if [[ "$MARKDOWN" -eq 1 ]]; then
  echo '```'
fi
