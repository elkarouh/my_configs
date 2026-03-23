# Handles completions only if the cursor is after a space.
# Supports environment variable completions via fzf.
# Handles path parsing, e.g., ~, ~/, or partial paths, to offer fzf-based file suggestions.

function my_fzf_completion_widget() {
  local selected_file partial_path directory partial_filename
  local MY_HOME="$HOME"

  # Only use custom completion if there's a space in the buffer
  if [[ $LBUFFER != *" "* ]]; then
    zle expand-or-complete
    return
  fi

  # Extract the partial path after the last space
  partial_path="${LBUFFER##* }"

  # Handle environment variable completion
  if [[ "$partial_path" == *\$* ]]; then
    local env_prefix="${partial_path##*\$}"
    local env_var=$(env | cut -d'=' -f1 | sort | fzf --height=70% --reverse --prompt="Env Var> " --query="$env_prefix" --preview='printenv {} 2>/dev/null' --preview-window='right:50%')
    if [[ -n "$env_var" ]]; then
      LBUFFER="${LBUFFER%\$*}\$${env_var}"
      CURSOR=${#LBUFFER}
      zle redisplay
    fi
    return
  fi

  # Parse the path to determine directory and filename
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

  # Ensure directory exists, fallback to current directory
  [[ ! -d "$directory" ]] && directory="."

  # Simple completion approach
  if [[ $LBUFFER == "cd "* ]]; then
    # CD command - directories only, filter out files
    selected_file=$(ls -1At "$directory" 2>/dev/null | while read item; do [[ -d "$directory/$item" ]] && echo "$item"; done | fzf --height=70% --reverse --prompt="Dir> " --query="$partial_filename" --preview="tree -C -L 1 '$directory'/{} 2>/dev/null || ls -la '$directory'/{} 2>/dev/null" --preview-window='right:50%')
  else
    # General completion - all files and directories
    selected_file=$(ls -1At "$directory" 2>/dev/null | fzf --multi --height=70% --reverse --prompt="File> " --query="$partial_filename" --preview="if [[ -f '$directory'/{} ]]; then head -100 '$directory'/{} 2>/dev/null || echo 'Binary file'; elif [[ -d '$directory'/{} ]]; then tree -C -L 1 '$directory'/{} 2>/dev/null || ls -la '$directory'/{} 2>/dev/null; fi" --preview-window='right:50%')
  fi

  # Process selection if we got one
  if [[ -n "$selected_file" ]]; then
    # Convert newlines to spaces for multiple selections
    selected_file=$(echo "$selected_file" | tr '\n' ' ')

    # Process each file
    local processed_files=""
    for file in $selected_file; do
      [[ -z "$file" ]] && continue

      # Add directory prefix
      file="$directory/$file"

      # Add trailing slash for directories
      if [[ -d "$file" ]]; then
        file="$file/"
      fi

      # Convert to tilde notation
      if [[ "$file" == "$MY_HOME"/* ]]; then
        file="~${file#$MY_HOME}"
      fi

      # Add to processed files
      processed_files="$processed_files $file"
    done

    # Clean up leading space and conditionally add trailing space
    processed_files="${processed_files# }"

    # Only add trailing space for non-cd commands AND if not ending with directory slash
    if [[ $LBUFFER != "cd "* && "$processed_files" != */ ]]; then
      processed_files="$processed_files "
    fi

    LBUFFER="${LBUFFER% *} $processed_files"
    CURSOR=${#LBUFFER}
    zle redisplay
  fi
}

# Register and bind
zle -N my_fzf_completion_widget
bindkey "^I" my_fzf_completion_widget
