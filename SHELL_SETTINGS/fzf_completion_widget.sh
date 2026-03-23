# Handles completions only if the cursor is after a space.
# Supports environment variable completions via fzf.
# Handles path parsing, e.g., ~, ~/, or partial paths, to offer fzf-based file suggestions.
# Supports Makefile target completion when the first word is 'make'.
# Auto-completes without showing fzf menu when only one choice exists.

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
      
      # Get targets into array
      local targets
      targets=$(
        awk -F':' '
          /^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {
            target = $1
            gsub(/^[ \t]+|[ \t]+$/, "", target)
            # Exclude special targets and pattern rules
            if (target !~ /^\./ && target !~ /%/) {
              print target
            }
          }
        ' "$makefile_name" | sort -u
      )
      
      # Filter by partial_path if provided
      if [[ -n "$partial_path" ]]; then
        targets=$(echo "$targets" | grep -i "^$partial_path" 2>/dev/null || echo "$targets" | grep -i "$partial_path" 2>/dev/null)
      fi
      
      local target_count=$(grep -c . <<< "$targets")
      
      local selected_target
      if [[ $target_count -eq 1 ]]; then
        # Only one match - use it directly
        selected_target=$(head -1 <<< "$targets")
      elif [[ $target_count -gt 1 ]]; then
        # Multiple matches - show fzf
        selected_target=$(fzf --height=70% --reverse --prompt="Make Target> " --query="$partial_path" --preview="grep -A 5 '^{}:' '$makefile_name' 2>/dev/null" --preview-window='right:50%' <<< "$targets")
      fi
      
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
    local env_vars
    env_vars=$(env | cut -d'=' -f1 | sort)
    
    # Filter by prefix if provided
    if [[ -n "$env_prefix" ]]; then
      env_vars=$(echo "$env_vars" | grep -i "^$env_prefix" 2>/dev/null || echo "$env_vars" | grep -i "$env_prefix" 2>/dev/null)
    fi
    
    local var_count=$(grep -c . <<< "$env_vars")
    
    local env_var
    if [[ $var_count -eq 1 ]]; then
      # Only one match - use it directly
      env_var=$(head -1 <<< "$env_vars")
    elif [[ $var_count -gt 1 ]]; then
      # Multiple matches - show fzf
      env_var=$(fzf --height=70% --reverse --prompt="Env Var> " --query="$env_prefix" --preview='printenv {} 2>/dev/null' --preview-window='right:50%' <<< "$env_vars")
    fi
    
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

  # Get file list
  local file_list
  if [[ $LBUFFER == "cd "* ]]; then
    # CD command - directories only
    file_list=$(ls -1At "$directory" 2>/dev/null | while IFS= read -r item; do [[ -d "$directory/$item" ]] && echo "$item"; done)
  else
    # General completion - all files and directories
    file_list=$(ls -1At "$directory" 2>/dev/null)
  fi
  
  # Filter by partial_filename if provided
  if [[ -n "$partial_filename" ]]; then
    local filtered_list
    filtered_list=$(echo "$file_list" | grep -i "^$partial_filename" 2>/dev/null)
    if [[ -z "$filtered_list" ]]; then
      # Try contains match if prefix match fails
      filtered_list=$(echo "$file_list" | grep -i "$partial_filename" 2>/dev/null)
    fi
    if [[ -n "$filtered_list" ]]; then
      file_list="$filtered_list"
    fi
  fi
  
  local file_count=$(grep -c . <<< "$file_list")
  
  if [[ $file_count -eq 1 ]]; then
    # Only one match - use it directly
    selected_file=$(head -1 <<< "$file_list")
  elif [[ $file_count -gt 1 ]]; then
    # Multiple matches - show fzf
    if [[ $LBUFFER == "cd "* ]]; then
      selected_file=$(fzf --height=70% --reverse --prompt="Dir> " --query="$partial_filename" --preview="tree -C -L 1 '$directory'/{} 2>/dev/null || ls -la '$directory'/{} 2>/dev/null" --preview-window='right:50%' <<< "$file_list")
    else
      selected_file=$(fzf --multi --height=70% --reverse --prompt="File> " --query="$partial_filename" --preview="if [[ -f '$directory'/{} ]]; then head -100 '$directory'/{} 2>/dev/null || echo 'Binary file'; elif [[ -d '$directory'/{} ]]; then tree -C -L 1 '$directory'/{} 2>/dev/null || ls -la '$directory'/{} 2>/dev/null; fi" --preview-window='right:50%' <<< "$file_list")
    fi
  else
    # No matches
    return
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
