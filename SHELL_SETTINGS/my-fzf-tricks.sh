f0() {
    sels=( "${(@f)$(fd "${fd_default[@]}" "${@:2}"| fzf --preview='preview.sh {}')}" )
    test -n "$sels" && print -z -- "$1 ${sels[@]:q:q}"
}

# Like f, but not recursive.
f1() {
  f "$@" --max-depth 1
}

# (date; ps -ef) | fzf --bind='ctrl-r:reload(date; ps -ef)' --header=$'Press CTRL-R to reload\n\n' --header-lines=2 \
      # --preview='echo {}' --preview-window=down,3,wrap --layout=reverse --height=80% | awk '{print $2}' | xargs kill -9
# find * | fzf --prompt 'All> ' \
             # --header 'CTRL-D: Directories / CTRL-F: Files' \
             # --bind 'ctrl-d:change-prompt(Directories> )+reload(find * -type d)' \
             # --bind 'ctrl-f:change-prompt(Files> )+reload(find * -type f)'

function delete-branches() {
  git branch |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --multi --preview="git log {}" |
    xargs --no-run-if-empty git branch --delete --force
}

# Deps
#alias fz="fzf-noempty --bind 'tab:toggle,shift-tab:toggle+beginning-of-line+kill-line,ctrl-j:toggle+beginning-of-line+kill-line,ctrl-t:top' --color=light -1 -m"
fzf-noempty () {
        local in="$(</dev/stdin)"
        test -z "$in" && (
                exit 130
        ) || {
                ec "$in" | fzf "$@"
        }
}
ecXXXX () {
        if [[ -n $ZSH_VERSION ]]
        then
                print -r -- "$@"
        else
                echo -E -- "$@"
        fi
}
