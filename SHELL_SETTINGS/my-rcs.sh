########################################## VERSION CONTROL STUFF ############################
# RCS (Revision Control System) helper functions
# Provides a simplified interface to RCS commands with consistent error handling

rcs_register() {
  local file="$1"
  
  if [[ -z "$file" ]]; then
    echo "Error: No file specified" >&2
    return 1
  fi
  
  if [[ ! -f "$file" ]]; then
    echo "Error: File '$file' does not exist" >&2
    return 1
  fi
  
  if [[ -f "RCS/${file},v" ]]; then
    echo "$file is already registered"
    return 0
  fi
  
  [[ -d RCS ]] || mkdir -p RCS
  echo "Registering $file with RCS"
  echo . | ci -u "$file"
}

alias rcs_track='rcs_register'

rcs_untrack() {
  local file="$1"
  
  if [[ -z "$file" ]]; then
    echo "Error: No file specified" >&2
    return 1
  fi
  
  if [[ ! -f "RCS/${file},v" ]]; then
    echo "Error: File '$file' is not tracked by RCS" >&2
    return 1
  fi
  
  echo "Untracking $file from RCS"
  rm "RCS/${file},v"
}

rcs_checkin() {
  local file="$1"
  
  if [[ -z "$file" ]]; then
    echo "Error: No file specified" >&2
    return 1
  fi
  
  if [[ ! -f "RCS/${file},v" ]]; then
    echo "Error: File '$file' is not tracked by RCS" >&2
    return 1
  fi
  
  ci -u "$file"
}

rcs_checkout() {
  local file="$1"
  
  if [[ -z "$file" ]]; then
    echo "Error: No file specified" >&2
    return 1
  fi
  
  if [[ ! -f "RCS/${file},v" ]]; then
    echo "Error: File '$file' is not tracked by RCS" >&2
    return 1
  fi
  
  co -l "$file"
}

rcs_commit() {
  local file="$1"
  local branch="$2"
  
  if [[ -z "$file" ]]; then
    echo "Error: No file specified" >&2
    return 1
  fi
  
  if [[ ! -f "RCS/${file},v" ]]; then
    echo "Error: File '$file' is not tracked by RCS" >&2
    return 1
  fi
  
  # Check in the file
  ci -u "$file" || return 1
  
  # If branch specified, check out on that branch
  if [[ -n "$branch" ]]; then
    echo "Checking out on branch: $branch"
    co -l -r"$branch" "$file"
  else
    # Otherwise, check out locked for continued editing
    co -l "$file"
  fi
}

###########################################################################################
# Helper function to get the head revision number
rcs_get_head() {
  local file="$1"
  
  if [[ -z "$file" ]]; then
    echo "Error: No file specified" >&2
    return 1
  fi
  
  if [[ ! -f "RCS/${file},v" ]]; then
    echo "Error: File '$file' is not tracked by RCS" >&2
    return 1
  fi
  
  rlog "$file" 2>/dev/null | grep -m1 "^head:" | sed 's/head: *//' | cut -d. -f1
}

rcs_hist() {
  local file="$1"
  local in_rcs_dir=false
  
  if [[ -z "$file" ]]; then
    echo "Error: No file specified" >&2
    return 1
  fi
  
  # Handle .rcs subdirectory workflow
  if [[ -d .rcs ]]; then
    if [[ -w "$file" ]]; then
      co -l ".rcs/$file" 2>/dev/null
      cp "$file" .rcs/
    fi
    cd .rcs || return 1
    in_rcs_dir=true
  fi
  
  if [[ ! -f "RCS/${file},v" ]]; then
    echo "Error: File '$file' is not tracked by RCS" >&2
    [[ "$in_rcs_dir" == true ]] && cd - > /dev/null
    return 1
  fi
  
  # Check if tkdiff is available
  if ! command -v tkdiff &> /dev/null; then
    echo "Error: tkdiff command not found" >&2
    [[ "$in_rcs_dir" == true ]] && cd - > /dev/null
    return 1
  fi
  
  local head_version
  head_version=$(rcs_get_head "$file")
  
  if [[ -z "$head_version" ]]; then
    echo "Error: Could not determine head version" >&2
    [[ "$in_rcs_dir" == true ]] && cd - > /dev/null
    return 1
  fi
  
  echo "Comparing current version with 1.$head_version"
  tkdiff "$file" -r"1.$head_version" "$file"
  
  # Show diffs between consecutive versions
  for new in $(seq "$head_version" -1 2); do
    local old=$((new - 1))
    echo "Comparing 1.$old with 1.$new"
    tkdiff -r"1.$old" -r"1.$new" "$file"
  done
  
  # Clean up if we changed to .rcs directory
  if [[ "$in_rcs_dir" == true ]]; then
    if [[ -w "$file" ]]; then
      ci -u "$file"
    fi
    cd - > /dev/null || return 1
  fi
}

rcs_vi() {
  local file="$1"
  
  if [[ -z "$file" ]]; then
    echo "Error: No file specified" >&2
    return 1
  fi
  
  if [[ -z "$EDITOR" ]]; then
    echo "Error: EDITOR environment variable not set" >&2
    return 1
  fi
  
  # Register file if not already tracked
  if [[ ! -f "RCS/${file},v" ]]; then
    [[ -d RCS ]] || mkdir -p RCS
    
    if [[ -f "$file" ]]; then
      echo "Registering $file with RCS"
      ci -u "$file" || return 1
    else
      echo "Error: File '$file' does not exist" >&2
      return 1
    fi
  fi
  
  # Check out if not already locked
  if [[ ! -w "$file" ]]; then
    co -l "$file" || return 1
  else
    echo "File is already checked out"
  fi
  
  # Edit the file
  "$EDITOR" "$file"
  
  # Check it back in after modification
  if [[ -f "RCS/${file},v" ]]; then
    echo "Checking in modified file"
    ci -u "$file"
  fi
}

###########################################################################
rcs_bulk_register() {
  if ! command -v hsb &> /dev/null; then
    echo "Error: hsb command not found" >&2
    return 1
  fi
  
  local file
  hsb | while IFS= read -r filepath; do
    file=$(basename "$filepath")
    
    if [[ ! -e ".rcs/$file" ]]; then
      mkdir -p .rcs
      cp "$filepath" ".rcs/$file" || continue
      
      pushd .rcs > /dev/null || continue
      echo "Registering $file"
      rcs_register "$file"
      popd > /dev/null || continue
    else
      echo "Skipping $file (already exists in .rcs)"
    fi
  done
}

rcs_bulk_commit() {
  if ! command -v hls &> /dev/null; then
    echo "Error: hls command not found" >&2
    return 1
  fi
  
  local files_to_commit=()
  local file
  
  hls | while IFS= read -r filepath; do
    file=$(basename "$filepath")
    
    if [[ ! -f ".rcs/$file" ]]; then
      echo "Warning: $file not found in .rcs directory" >&2
      continue
    fi
    
    if cmp -s -- ".rcs/$file" "$filepath"; then
      echo "$file did not change"
    else
      if command -v cecho &> /dev/null; then
        cecho Wb "$file was modified"
      else
        echo "$file was modified"
      fi
      
      co -l ".rcs/$file" 2>/dev/null
      cp "$filepath" ".rcs/$file"
      files_to_commit+=("$file")
    fi
  done
  
  if [[ ${#files_to_commit[@]} -eq 0 ]]; then
    echo "No files to commit"
    return 0
  fi
  
  command -v hr &> /dev/null && hr
  
  pushd .rcs > /dev/null || return 1
  ci -u "${files_to_commit[@]}"
  popd > /dev/null || return 1
}

#############################################################
rcs_revert() {
  local file="$1"
  
  if [[ -z "$file" ]]; then
    echo "Error: No file specified" >&2
    return 1
  fi
  
  if [[ ! -f "RCS/${file},v" ]]; then
    echo "Error: File '$file' is not tracked by RCS" >&2
    return 1
  fi
  
  if [[ ! -w "$file" ]]; then
    echo "File '$file' is not checked out, nothing to revert"
    return 0
  fi
  
  echo "Reverting changes to $file"
  rcs -u "$file"
  rm "$file"
  co "$file"
}

#############################################################
# Git diff before commit (requires broot)
rcs_git_diff() {
  if ! command -v br &> /dev/null; then
    echo "Error: broot (br) command not found" >&2
    return 1
  fi
  
  local conf_file="$HOME/.config/broot/git-diff-conf.toml"
  
  if [[ ! -f "$conf_file" ]]; then
    echo "Warning: Config file not found: $conf_file" >&2
    br --git-status
  else
    br --conf "$conf_file" --git-status
  fi
}

rcs_tag() {
  local label="$1"
  local version="$2"
  local filename="$3"
  
  if [[ -z "$label" || -z "$version" || -z "$filename" ]]; then
    echo "Usage: rcs_tag LABEL VERSION FILENAME" >&2
    echo "Example: rcs_tag v1.0 1.5 myfile.txt" >&2
    return 1
  fi
  
  if [[ ! -f "RCS/${filename},v" ]]; then
    echo "Error: File '$filename' is not tracked by RCS" >&2
    return 1
  fi
  
  echo "Tagging $filename version $version as $label"
  rcs -N"${label}:${version}" "$filename"
}

rcs_tag_all() {
  local label="$1"
  local branch_head="$2"  # Optional, example format: 1.2
  
  if [[ -z "$label" ]]; then
    echo "Usage: rcs_tag_all LABEL [BRANCH_HEAD]" >&2
    echo "Example: rcs_tag_all v1.0 1.2" >&2
    return 1
  fi
  
  if [[ ! -d RCS ]] || [[ -z "$(ls -A RCS 2>/dev/null)" ]]; then
    echo "Error: No RCS files found" >&2
    return 1
  fi
  
  echo "Tagging all files with label: $label"
  if [[ -n "$branch_head" ]]; then
    echo "Branch head: $branch_head"
    rcs -N"${label}:${branch_head}" RCS/*,v
  else
    rcs -N"${label}:" RCS/*,v
  fi
}

rcs_hco() {
  local label="$1"
  
  if [[ -z "$label" ]]; then
    echo "Usage: rcs_hco LABEL" >&2
    echo "Example: rcs_hco v1.0" >&2
    return 1
  fi
  
  if [[ ! -d RCS ]] || [[ -z "$(ls -A RCS 2>/dev/null)" ]]; then
    echo "Error: No RCS files found" >&2
    return 1
  fi
  
  echo "Checking out all files with label: $label"
  co -r"$label" RCS/*,v
}

rcs_hls() {
  # List all files currently checked out
  if [[ ! -d RCS ]] || [[ -z "$(ls -A RCS 2>/dev/null)" ]]; then
    echo "No RCS files found"
    return 0
  fi
  
  echo "Files currently checked out:"
  rlog -L -R RCS/*,v 2>/dev/null
}

rcs_hsb() {
  # List all files currently registered with RCS
  if [[ ! -d RCS ]] || [[ -z "$(ls -A RCS 2>/dev/null)" ]]; then
    echo "No RCS files found"
    return 0
  fi
  
  echo "Files registered with RCS:"
  ls RCS/*,v 2>/dev/null
}

rcs_status() {
  # Show overall RCS status
  echo "=== RCS Status ==="
  echo
  echo "Registered files:"
  rcs_hsb
  echo
  echo "Checked out files:"
  rcs_hls
}

# Completion helper
rcs_list_tracked() {
  if [[ -d RCS ]]; then
    ls RCS/*,v 2>/dev/null | sed 's|RCS/||;s|,v$||'
  fi
}
