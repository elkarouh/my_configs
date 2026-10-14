# Handles completions only if the cursor is after a space.
# Supports environment variable completions via fzf.
# Handles path parsing, e.g., ~, ~/, or partial paths, to offer fzf-based file suggestions.
# Supports Makefile target completion when the first word is 'make'.
# Supports custom command completions via a registry (see _fzf_register_completion).
# Auto-completes without showing fzf menu when only one choice exists.
# Uses bat/eza when available for richer previews.

# ── Custom completion registry ──────────────────────────────────────────
#
# To add completions for a command:
#   1. Write a function that prints candidates (one per line)
#   2. Call _fzf_register_completion with the command name, function, and
#      optionally a prompt label and/or a preview command
#
# Example:
#   _my_fruits() { printf '%s\n' apple banana cherry; }
#   _fzf_register_completion fruit-picker _my_fruits "Fruit"
#
# With a preview:
#   _fzf_register_completion fruit-picker _my_fruits "Fruit" 'echo "You picked: {}"'

typeset -gA _fzf_comp_funcs _fzf_comp_prompts _fzf_comp_previews

_fzf_register_completion() {
  local cmd="$1" func="$2" prompt="${3:-$1}" preview="${4:-}"
  _fzf_comp_funcs[$cmd]="$func"
  _fzf_comp_prompts[$cmd]="$prompt"
  [[ -n "$preview" ]] && _fzf_comp_previews[$cmd]="$preview"
}

# ── Built-in registrations ──────────────────────────────────────────────

_my_gitconfig_targets() {
  local config_dir="$HOME/.local"
  for f in "$config_dir"/.gitconfig.*; do
    [[ -f "$f" ]] || continue
    basename "$f" | sed 's/^\.gitconfig\.//'
  done
}

_fzf_register_completion switch-gitconfig _my_gitconfig_targets "Git Config" \
  "echo '── {}'; echo ''; git config --file '$HOME/.local/.gitconfig.{}' --list 2>/dev/null | head -30"

_fzf_register_completion swg _my_gitconfig_targets "Git Config" \
  "echo '── {}'; echo ''; git config --file '$HOME/.local/.gitconfig.{}' --list 2>/dev/null | head -30"
# ── Widget ──────────────────────────────────────────────────────────────

function my_fzf_completion_widget() {
  local partial_path
  local MY_HOME="$HOME"

  if [[ $LBUFFER != *" "* ]]; then
    zle expand-or-complete
    return
  fi

  partial_path="${LBUFFER##* }"

  # Check custom completion registry
  local cmd="${LBUFFER%% *}"
  if (( ${+_fzf_comp_funcs[$cmd]} )); then
    _fzf_complete_custom "$cmd" "$partial_path"
    return
  fi

  # Make target completion (context-dependent, not registry-based)
  if [[ $LBUFFER == make\ * ]]; then
    _fzf_complete_make "$partial_path"
    return
  fi

  # Environment variable completion
  if [[ "$partial_path" == *\$* ]]; then
    _fzf_complete_envvar "$partial_path"
    return
  fi

  # File / directory completion (default)
  _fzf_complete_path "$partial_path"
}

# ── Helpers ─────────────────────────────────────────────────────────────

_fzf_escape_pattern() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//./\\.}"
  s="${s//\*/\\*}"
  s="${s//\?/\\?}"
  s="${s//+/\\+}"
  s="${s//\[/\\[}"
  s="${s//\]/\\]}"
  s="${s//\(/\\(}"
  s="${s//\)/\\)}"
  s="${s//\{/\\{}"
  s="${s//\}/\\}}"
  s="${s//\^/\\^}"
  s="${s//\$/\\$}"
  s="${s//|/\\|}"
  printf '%s' "$s"
}

_fzf_build_preview() {
  local dir="$1" mode="${2:-file}"
  local bat_cmd="bat --color=always --style=numbers --line-range=:200"
  local eza_cmd="eza -la --color=always --icons --group-directories-first"

  if [[ "$mode" == "dir" ]]; then
    echo "$eza_cmd '$dir'/{} 2>/dev/null || tree -C -L 1 '$dir'/{} 2>/dev/null || ls -la '$dir'/{} 2>/dev/null"
  else
    echo "if [[ -f '$dir'/{} ]]; then $bat_cmd '$dir'/{} 2>/dev/null || head -100 '$dir'/{} 2>/dev/null || echo 'Binary file'; elif [[ -d '$dir'/{} ]]; then $eza_cmd '$dir'/{} 2>/dev/null || tree -C -L 1 '$dir'/{} 2>/dev/null || ls -la '$dir'/{} 2>/dev/null; fi"
  fi
}

_fzf_common_opts() {
  echo "--height=70% --reverse --bind=ctrl-/:toggle-preview --preview-window=right:50%"
}

_fzf_filter_list() {
  local list="$1" pattern="$2"
  if [[ -z "$pattern" ]]; then
    echo "$list"
    return
  fi
  local escaped
  escaped=$(_fzf_escape_pattern "$pattern")
  local filtered
  filtered=$(echo "$list" | grep -i "^$escaped" 2>/dev/null)
  if [[ -z "$filtered" ]]; then
    filtered=$(echo "$list" | grep -i "$escaped" 2>/dev/null)
  fi
  if [[ -n "$filtered" ]]; then
    echo "$filtered"
  else
    echo "$list"
  fi
}

# ── Custom completion handler ───────────────────────────────────────────

_fzf_complete_custom() {
  local cmd="$1" partial="$2"
  local list_func="${_fzf_comp_funcs[$cmd]}"
  local prompt="${_fzf_comp_prompts[$cmd]}"
  local preview="${_fzf_comp_previews[$cmd]:-}"

  local items
  items=$($list_func)
  [[ -z "$items" ]] && return

  items=$(_fzf_filter_list "$items" "$partial")

  local selected
  if [[ -n "$preview" ]]; then
    selected=$(echo "$items" | fzf $(_fzf_common_opts) \
      --select-1 --exit-0 \
      --prompt="${prompt}> " \
      --query="$partial" \
      --preview="$preview" \
    )
  else
    selected=$(echo "$items" | fzf $(_fzf_common_opts) \
      --select-1 --exit-0 \
      --prompt="${prompt}> " \
      --query="$partial" \
    )
  fi

  if [[ -n "$selected" ]]; then
    LBUFFER="${LBUFFER% *} $selected "
    CURSOR=${#LBUFFER}
    zle redisplay
  fi
}

# ── Make ────────────────────────────────────────────────────────────────

_fzf_complete_make() {
  local partial="$1"

  local makefile_name
  if [[ -f "GNUmakefile" ]]; then
    makefile_name="GNUmakefile"
  elif [[ -f "Makefile" ]]; then
    makefile_name="Makefile"
  elif [[ -f "makefile" ]]; then
    makefile_name="makefile"
  else
    return
  fi

  local targets
  targets=$(
    awk -F':' '
      /^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {
        target = $1
        gsub(/^[ \t]+|[ \t]+$/, "", target)
        if (target !~ /^\./ && target !~ /%/) {
          print target
        }
      }
    ' "$makefile_name" | sort -u
  )
  [[ -z "$targets" ]] && return

  targets=$(_fzf_filter_list "$targets" "$partial")

  local selected
  selected=$(echo "$targets" | fzf $(_fzf_common_opts) \
    --select-1 --exit-0 \
    --prompt="Make Target> " \
    --query="$partial" \
    --preview="grep -A 10 '^{}:' '$makefile_name' 2>/dev/null" \
  )

  if [[ -n "$selected" ]]; then
    LBUFFER="${LBUFFER% *} $selected "
    CURSOR=${#LBUFFER}
    zle redisplay
  fi
}

# ── Environment variables ───────────────────────────────────────────────

_fzf_complete_envvar() {
  local partial_path="$1"
  local env_prefix="${partial_path##*\$}"

  local env_vars
  env_vars=$(env | cut -d'=' -f1 | sort)

  env_vars=$(_fzf_filter_list "$env_vars" "$env_prefix")

  local env_var
  env_var=$(echo "$env_vars" | fzf $(_fzf_common_opts) \
    --select-1 --exit-0 \
    --prompt="Env Var> " \
    --query="$env_prefix" \
    --preview='echo "${}"="$(printenv {} 2>/dev/null)"' \
  )

  if [[ -n "$env_var" ]]; then
    LBUFFER="${LBUFFER%\$*}\$${env_var}"
    CURSOR=${#LBUFFER}
    zle redisplay
  fi
}

# ── File / directory path ───────────────────────────────────────────────

_fzf_complete_path() {
  local partial_path="$1"
  local MY_HOME="$HOME"

  local directory partial_filename show_hidden=false

  case "$partial_path" in
    "~")
      directory="$MY_HOME"
      partial_filename=""
      ;;
    "~/")
      directory="$MY_HOME"
      partial_filename=""
      ;;
    "~/"*/)
      directory="${partial_path%/}"
      directory="${directory/\~/$MY_HOME}"
      partial_filename=""
      ;;
    "~/"*)
      directory="$(dirname "$partial_path")"
      directory="${directory/\~/$MY_HOME}"
      partial_filename="$(basename "$partial_path")"
      ;;
    */)
      directory="${partial_path%/}"
      partial_filename=""
      ;;
    *)
      local expanded_path="${partial_path/\~/$MY_HOME}"
      directory="$(dirname "$expanded_path")"
      partial_filename="$(basename "$expanded_path")"
      ;;
  esac

  [[ ! -d "$directory" ]] && directory="."
  [[ "$partial_filename" == .* ]] && show_hidden=true

  local file_list
  if [[ $LBUFFER == cd\ * ]]; then
    if $show_hidden; then
      file_list=$(find "$directory" -maxdepth 1 -mindepth 1 -type d -name '.*' 2>/dev/null | while IFS= read -r f; do basename "$f"; done | sort)
    else
      file_list=$(find "$directory" -maxdepth 1 -mindepth 1 -type d ! -name '.*' 2>/dev/null | while IFS= read -r f; do basename "$f"; done | sort)
    fi
  else
    if $show_hidden; then
      file_list=$(ls -1A "$directory" 2>/dev/null | grep '^\.')
    else
      file_list=$(ls -1At "$directory" 2>/dev/null)
    fi
  fi

  [[ -z "$file_list" ]] && return

  file_list=$(_fzf_filter_list "$file_list" "$partial_filename")

  local preview_cmd
  if [[ $LBUFFER == cd\ * ]]; then
    preview_cmd=$(_fzf_build_preview "$directory" "dir")
  else
    preview_cmd=$(_fzf_build_preview "$directory" "file")
  fi

  local selected_file
  if [[ $LBUFFER == cd\ * ]]; then
    selected_file=$(echo "$file_list" | fzf $(_fzf_common_opts) \
      --select-1 --exit-0 \
      --prompt="Dir> " \
      --query="$partial_filename" \
      --preview="$preview_cmd" \
    )
  else
    selected_file=$(echo "$file_list" | fzf $(_fzf_common_opts) \
      --multi --select-1 --exit-0 \
      --prompt="File> " \
      --query="$partial_filename" \
      --preview="$preview_cmd" \
    )
  fi

  [[ -z "$selected_file" ]] && return

  local processed_files=""
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue

    local full_path
    if [[ "$directory" == "." ]]; then
      full_path="$file"
    else
      full_path="$directory/$file"
    fi

    if [[ -d "$full_path" ]]; then
      full_path="$full_path/"
    fi

    if [[ "$full_path" == "$MY_HOME"/* ]]; then
      full_path="~${full_path#$MY_HOME}"
    fi

    if [[ "$file" == *[[:space:]\'\"\`\$\&\|\;\<\>\(\)\{\}\[\]\*\?\\]* ]]; then
      local dir_part="" filename_part=""
      local bare="${full_path%/}"
      if [[ "$bare" == */* ]]; then
        dir_part="${bare%/*}/"
        filename_part="${bare##*/}"
      else
        filename_part="$bare"
      fi
      [[ "$full_path" == */ ]] && filename_part="$filename_part/"
      filename_part="${filename_part//\'/\'\\\'\'}"
      full_path="${dir_part}'${filename_part}'"
    fi

    if [[ -n "$processed_files" ]]; then
      processed_files="$processed_files $full_path"
    else
      processed_files="$full_path"
    fi
  done <<< "$selected_file"

  if [[ $LBUFFER != cd\ * ]] && [[ "$processed_files" != */ ]] && [[ "$processed_files" != *"'/" ]]; then
    processed_files="$processed_files "
  fi

  LBUFFER="${LBUFFER% *} $processed_files"
  CURSOR=${#LBUFFER}
  zle redisplay
}

# Register and bind
zle -N my_fzf_completion_widget
bindkey "^I" my_fzf_completion_widget
