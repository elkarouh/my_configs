#!/bin/sh
# Usage: prompt.sh <output-file>
out="$1"
title="zping"
label="name"

clear
cols=$(tput cols 2>/dev/null || echo 80)
rows=$(tput lines 2>/dev/null || echo 24)

if command -v gum >/dev/null 2>&1; then
  # Nicer: a bordered input box, if you have gum installed.
  value=$(gum input --header "$title" --header.foreground 212 \
    --placeholder "$label..." --width 40 --prompt "> ")
else
  # Plain fallback: a box drawn with printf, centered vertically.
  width=40
  pad_left=$(( (cols - width) / 2 ))
  pad_top=$(( (rows / 2) - 3 ))
  [ "$pad_top" -lt 0 ] && pad_top=0
  [ "$pad_left" -lt 0 ] && pad_left=0
  indent=$(printf '%*s' "$pad_left" '')

  i=0; while [ $i -lt $pad_top ]; do echo; i=$((i + 1)); done
  printf '%s┌%s┐\n' "$indent" "$(printf '─%.0s' $(seq 1 $((width - 2))))"
  printf '%s│ %-*s│\n' "$indent" $((width - 3)) "$title"
  printf '%s└%s┘\n' "$indent" "$(printf '─%.0s' $(seq 1 $((width - 2))))"
  echo
  printf '%s%s: ' "$indent" "$label"
  read -r value
fi

printf '%s' "$value" > "$out"
clear

