#!/usr/bin/env zsh
# find_project.sh - Fuzzy project name matching using fd and fzf

find_project() {
    local input_name="$1"
    local projects_dir="${HOME}/Downloads/python-projects"
    
    # Check if projects directory exists
    if [[ ! -d "${projects_dir}" ]]; then
        echo "❌ Projects directory not found: ${projects_dir}" >&2
        return 1
    fi
    
    # If no input provided, show interactive selection with fzf
    if [[ -z "$input_name" ]]; then
        if command -v fzf >/dev/null 2>&1; then
            local selected
            selected=$(cd "$projects_dir" && fd -t d -d 1 . | sed 's|^\./||' | fzf --height 40% --prompt "Select project: ")
            if [[ -n "$selected" ]]; then
                echo "$selected"
                return 0
            else
                echo "❌ No project selected" >&2
                return 1
            fi
        else
            echo "❌ fzf not installed and no project name provided" >&2
            return 1
        fi
    fi
    
    # Check if fd is available for better searching
    if command -v fd >/dev/null 2>&1; then
        # Use fd for fast directory finding
        local matches=()
        
        # First try: exact match (case-insensitive)
        local exact_match=$(cd "$projects_dir" && fd -t d -d 1 -i "^${input_name}$" . | sed 's|^\./||')
        if [[ -n "$exact_match" ]]; then
            echo "$exact_match"
            return 0
        fi
        
        # Second try: fuzzy match with fd
        local fuzzy_matches=($(cd "$projects_dir" && fd -t d -d 1 -i "$input_name" . | sed 's|^\./||'))
        
        if [[ ${#fuzzy_matches[@]} -eq 1 ]]; then
            echo "${fuzzy_matches[1]}"
            return 0
        elif [[ ${#fuzzy_matches[@]} -gt 1 ]]; then
            # Multiple matches - use fzf if available for interactive selection
            if command -v fzf >/dev/null 2>&1; then
                local selected=$(printf '%s\n' "${fuzzy_matches[@]}" | fzf --height 40% --prompt "Multiple matches, select one: " --query "$input_name")
                if [[ -n "$selected" ]]; then
                    echo "$selected"
                    return 0
                else
                    echo "❌ No project selected" >&2
                    return 1
                fi
            else
                # No fzf, show list and ask user to be more specific
                echo "❌ Multiple projects match '$input_name':" >&2
                for match in "${fuzzy_matches[@]}"; do
                    echo "   - $match" >&2
                done
                echo "   Please be more specific, or install fzf for interactive selection" >&2
                return 1
            fi
        fi
    fi
    
    # Fallback: basic shell matching if fd is not available
    # First, try exact match
    if [[ -d "${projects_dir}/${input_name}" ]]; then
        echo "${input_name}"
        return 0
    fi
    
    # Try case-insensitive exact match
    local matches=()
    for project in "${projects_dir}"/*(/N); do
        local project_name="${project:t}"
        if [[ "${project_name:l}" == "${input_name:l}" ]]; then
            echo "${project_name}"
            return 0
        fi
    done
    
    # Try partial match (case-insensitive)
    for project in "${projects_dir}"/*(/N); do
        local project_name="${project:t}"
        if [[ "${project_name:l}" == *"${input_name:l}"* ]]; then
            matches+=("${project_name}")
        fi
    done
    
    # Return result based on matches
    if [[ ${#matches[@]} -eq 1 ]]; then
        echo "${matches[1]}"
        return 0
    elif [[ ${#matches[@]} -gt 1 ]]; then
        # Try fzf even in fallback mode
        if command -v fzf >/dev/null 2>&1; then
            local selected=$(printf '%s\n' "${matches[@]}" | fzf --height 40% --prompt "Select project: " --query "$input_name")
            if [[ -n "$selected" ]]; then
                echo "$selected"
                return 0
            else
                echo "❌ No project selected" >&2
                return 1
            fi
        else
            echo "❌ Multiple projects match '$input_name':" >&2
            for match in "${matches[@]}"; do
                echo "   - $match" >&2
            done
            echo "   Please be more specific" >&2
            echo "   💡 Install fd and fzf for better fuzzy finding: sudo apt install fd-find fzf" >&2
            return 1
        fi
    fi
    
    # No matches found
    echo "❌ No project found matching '$input_name'" >&2
    return 1
}
