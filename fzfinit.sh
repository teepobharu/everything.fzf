#!/bin/bash

export FZFEXE="$DOTFILES_DIR/scripts/everything.fzf"
_fzfscriptcmd='fzf --prompt="*.fzf commands now available" --preview="echo \"run: {}\"" --bind "enter:become({})" --height=50% --layout=reverse --border'

# Prefer `fd` so it respects .gitignore/.ignore (much faster + less noise).
# Fallback to `find` if `fd` is not installed.
if command -v fd >/dev/null 2>&1; then
  # -H: include hidden, -t f: files only, -a: search all (incl. hidden/ignored-by-default)
  # NOTE: fd still respects .gitignore/.ignore unless you add -I (do not ignore).
  ALLSCRIPTS=$(fd -H -t f -a --extension fzf . "$DOTFILES_DIR/scripts" 2>/dev/null)
else
  ALLSCRIPTS=$(find "$DOTFILES_DIR/scripts" -type f -name "*.fzf" 2>/dev/null)
fi
# check if $1 match filename (not whole path) of any scripts  in FZFEXE/$1 the list then just execute the script directlry without fzf
if [ -n "$ALLSCRIPTS" ]; then
  if [ -n "$1" ]; then
    # try to find a direct filename match (basename)
    script_match=""
    while IFS= read -r f; do

      # script_name_no_last_ext="${f%.fzf}" # remove fzf
      script_name_no_last_ext="${f%.*}" # remove last .* ext

      echo "$f -> if match:  $(basename "$f") or  $script_name_no_last_ext"

      # Allow calling with either:
      # - exact file name: gproj.fzf
      # - command name without path/ext: gproj
      if [ "$(basename "$f")" = "$1" ] || [ "$(basename "$script_name_no_last_ext")" = "$1" ]; then
        script_match="$f"
        break
      fi
    done <<<"$ALLSCRIPTS"

    if [ -n "$script_match" ]; then
      # execute the matched script directly with any remaining args
      shift
      exec "$script_match" "$@"
    fi

    # no direct match; fall back to fzf, prefilled with the original query
    if [ "$#" -gt 0 ]; then
      printf '%s\n' "$ALLSCRIPTS" | eval "$_fzfscriptcmd" -q "$@"
    else
      printf '%s\n' "$ALLSCRIPTS" | eval "$_fzfscriptcmd"
    fi
  else
    printf '%s\n' "$ALLSCRIPTS" | eval "$_fzfscriptcmd"
  fi
else
  echo "No .fzf scripts found in $DOTFILES_DIR/scripts"
fi
