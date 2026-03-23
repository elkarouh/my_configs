#!/usr/bin/zsh

j() { # 1 line per job, always
    for id cmd in "${(@kv)jobtexts}"; do
        echo "${(r:3:)id}  $cmd  [${jobdirs[$id]}]";
    done
}

fzf-jobs-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(j |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS --tiebreak=index $FZF_CTRL_R_OPTS +m" $(__fzfcmd)) )
  local ret=$?
  if [ -z "$selected" ]; then
    zle reset-prompt
    return $ret
  fi;

  local mypath="$(echo "$selected" | sed 's/^.*\[\(.*\)\]$/\1/')";
  local mypath="${mypath/#\~/$HOME}";
  local myjobid="$(echo "$selected" | sed -n 's/^\([[:digit:]]\+\).*$/\1/p')";

  # check we got valid path and job id
  if [ ! -d "$mypath" ] || [[ ! "$myjobid" -gt 0 ]]; then
    echo "error invalid path or job id";
    zle reset-prompt
    return 1;
  else
    # execute
    zle reset-prompt
    cd "$mypath";
    fg %"$myjobid";
  fi;
}

# bind to a key, uncomment this:
zle -N fzf-jobs-widget
bindkey '^J' fzf-jobs-widget
