# Handles completions only if the cursor is after a space.
# Supports environment variable completions via fzf.
# Handles path parsing, e.g., ~, ~/, or partial paths, to offer fzf-based file suggestions.
# Supports Makefile target completion when the first word is 'make'.

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

  # Handle make target completion
  if [[ $LBUFFER == "make "* ]]; then
    if [[ -f "Makefile" ]] || [[ -f "makefile" ]] || [[ -f "GNUmakefile" ]]; then
      local makefile_name
      # Check in GNU Make's priority order
      if [[ -f "GNUmakefile" ]]; then
        makefile_name="GNUmakefile"
      elif [[ -f "Makefile" ]]; then
        makefile_name="Makefile"
      else
        makefile_name="makefile"
      fi
      
      local selected_target=$(
        awk -F':' '
          /^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {
            target = $1
            gsub(/^[ \t]+|[ \t]+$/, "", target)
            # Exclude special targets and pattern rules
            if (target !~ /^\./ && target !~ /%/) {
              print target
            }
          }
        ' "$makefile_name" | sort -u | fzf --height=70% --reverse --prompt="Make Target> " --query="$partial_path" --preview="grep -A 5 '^{}:' '$makefile_name' 2>/dev/null" --preview-window='right:50%'
      )
      
      if [[ -n "$selected_target" ]]; then
        LBUFFER="${LBUFFER% *} $selected_target "
        CURSOR=${#LBUFFER}
        zle redisplay
      fi
      return
    fi
  fi

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
    # Process each file (handle newlines from multi-select)
    local processed_files=""
    while IFS= read -r file; do
      [[ -z "$file" ]] && continue

      # Build the full path
      local full_path
      if [[ "$directory" == "." ]]; then
        full_path="./$file"
      else
        full_path="$directory/$file"
      fi

      # Check if it's a directory and add trailing slash
      local is_dir=false
      if [[ -d "$full_path" ]]; then
        full_path="$full_path/"
        is_dir=true
      fi

      # Convert to tilde notation BEFORE quoting
      local use_tilde=false
      if [[ "$full_path" == "$MY_HOME"/* ]]; then
        full_path="~${full_path#$MY_HOME}"
        use_tilde=true
      fi

      # Quote only the filename if it contains special characters
      if [[ "$file" == *[[:space:]\'\"\`\$\&\|\;\<\>\(\)\{\}\[\]\*\?\\]* ]]; then
        # Extract directory path and filename separately
        local dir_part filename_part
        
        if [[ "$full_path" == */ ]]; then
          # It's a directory - quote the directory name only
          dir_part="${full_path%/*/}/"
          filename_part="${full_path%/}"
          filename_part="${filename_part##*/}/"
        else
          # It's a file
          dir_part="${full_path%/*}/"
          filename_part="${full_path##*/}"
        fi
        
        # Escape single quotes in filename
        filename_part="${filename_part//\'/\'\\\'\'}"
        
        # Reconstruct path with quoted filename
        full_path="${dir_part}'${filename_part}'"
      fi

      # Add to processed files
      if [[ -n "$processed_files" ]]; then
        processed_files="$processed_files $full_path"
      else
        processed_files="$full_path"
      fi
    done <<< "$selected_file"

    # Only add trailing space for non-cd commands AND if not ending with directory slash
    # Check both unquoted slash and quoted slash
    if [[ $LBUFFER != "cd "* ]] && [[ "$processed_files" != */ ]] && [[ "$processed_files" != *"'/" ]]; then
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
