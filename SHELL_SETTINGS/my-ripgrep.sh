
######################## GREP commands############################################
alias rg.="rg -. -g '!*/'" # only search in current dir, also for hidden files, no subdirs !!!
alias rg,='frg'
alias ug='ug --index'
alias mrg='rg --multiline --multiline-dotall'
# rg coloured version
alias rgc="rg --colors 'match:none' --colors 'match:bg:0x33,0x66,0xFF' --colors 'match:fg:white' --colors 'match:style:bold'"
#alias rg='rg -L --color=always'
#alias rg="rg -H -n --color=always -i --type-add 'ada:*.{adb,ads}' --type-add 'other:*.{el,ksh,log}'"
# alias rg="rg --type-add 'log:*.{log,svlog}'"
alias rgada='rg -n -t ada'
alias rgpy='rg -n -t py'
alias rgel='rg -n -t elisp'
alias rgh="rg --hidden" # search hidden directories
alias rg,,='cd $CM_VOB;rg, ; cd -'
#;;;;;;;;;;;;;;;;;;;;;;;; search in file (rg) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rrg () {
  rg --no-heading --color=always -n  "$@" 2> /dev/null
}
fdrg () {
  test ${#1} = 0 && echo "argument needed"; return 1
  last_arg="${@: -1}"
  all_but_last_args=$(echo "${@:1:$# - 1}") # echo needed to remove the quotes
  fd "$all_but_last_args" -x rg -l $last_arg {}
}

hrg3 () {
  last_arg="${@: -1}"
  all_but_last_args=$(echo "${@:1:$# - 1}") # echo needed to remove the quotes
  echo "LAST $last_arg"
  echo "FIRST $all_but_last_args"
  set -x
  if [ ! "$#" -gt 1 ]; then rg -l "$1"; return 1; fi
  if echo x"$last_arg" | grep -q '*' ; then
    rg "$all_but_last_args" -g "$last_arg"
  else
    echo "LAST ${last_arg}/**"
    rg "$all_but_last_args" -g $(echo "${last_arg}/**") # echo needed to remove the quotes !!!
  fi;
}
hrg2() { # rg and fzf
  RG_PREFIX="rga --files-with-matches"
  local file
  file="$(
                FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
                        fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
                                --phony -q "$1" \
                                --bind "change:reload:$RG_PREFIX {q}" \
                                --preview-window="70%:wrap"
        )" &&
    echo "opening $file" &&
    gio open "$file"
}
hrg4 () {
  FS=: read -ra selected < <(
    rg --color=always --line-number --no-heading --smart-case "${*:-}" 2>/dev/null |
      fzf --ansi \
          --color "hl:-1:underline,hl+:-1:underline:reverse" \
          --delimiter : \
          --preview 'bat --color=always {1} --highlight-line {2}' \
          --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
  )
  [ -n "${selected[0]}" ] && vim "${selected[0]}" "+${selected[1]}"
}

hrg5() {
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  INITIAL_QUERY="${*:-}"
  IFS=: read -ra selected < <(
    FZF_DEFAULT_COMMAND="$RG_PREFIX $(printf %q "$INITIAL_QUERY")" \
                       fzf --ansi \
                       --disabled --query "$INITIAL_QUERY" \
                       --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
                       --delimiter : \
                       --preview 'bat --color=always {1} --highlight-line {2}' \
                       --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
  )
  [ -n "${selected[0]}" ] && vim "${selected[0]}" "+${selected[1]}"
}
######################################################
hfdd () {
  INITIAL_QUERY=''
  DIRECTORY_QUERY=''

  CMD_PREFIX='fd --full-path '
  #PREVIEW_CMD='bat --color=always {} '
  PREVIEW_CMD='[ -d {} ] && tree -L 1 {} || bat --color=always {} '

  # if there is only one argument it needs to be a query
  if [[ $# -eq 1 ]]; then
    INITIAL_QUERY="$*"

    # if there is more then one then all but the last one is the query
    # and the last is the file path to search
  elif [[ $# -gt 1 ]]; then
    while [[ $# -gt 1 ]]; do
      INITIAL_QUERY+="$1"
      shift
    done

    DIRECTORY_QUERY="$1"
  fi


  # there should be a better way to do this
  # but i cant seem to get anything else to work right
  IFS=$'\n' read -d '' -ra selected < <(
    FZF_DEFAULT_COMMAND="$CMD_PREFIX $(printf '%q' "$INITIAL_QUERY") $DIRECTORY_QUERY" \
                       fzf --multi  \
                       --ansi \
                       --disabled --query "$INITIAL_QUERY" \
                       --bind "change:reload:sleep 0.1; $CMD_PREFIX {q} $DIRECTORY_QUERY || true" \
                       --preview "$PREVIEW_CMD" \
                       --preview-window 'up:60%:+{2}+3/3:~3' \
                       --border bottom
  )

  [ -n "$selected" ] && "$EDITOR" "${selected[@]}"

}
##############################################################
# For fuzzy-jumping down your home directory.
# See http://richardmavis.info/fuzzy-jumping
function fcd {
  cache=~/.config/home-dirs-list
  if (( $# == 0 )); then
    if [ -e $cache ]; then
      cd "`fzf --height=10 < ${cache}`"
    else
      echo "No directory cache."
      cd `find ~ -type d | fzf --height=10`
    fi
  elif (( $# == 1 )); then
    if [[ $1 == "--cache" ]]; then
      echo "Making home directory cache."
      find ~ -type d | sort > $cache
    elif [ -e $cache ]; then
      cd "`cat ${cache} | grep $1 | fzf --height=10`"
    else
      echo "No directory cache."
      cd `find $1 -type d | fzf --height=10`
    fi
  else
    echo "Usage: fcd [DIR]|--cache"
  fi
}

function hcd4 {
  cd "$(llama "$@")"
}

hcd2 () {
  cd ${1:-$PWD} && cd "$(fd -L -H -td | fzf --preview="tree -L 1 {}")" && echo "$PWD" && tree -L 2
}

# cdf - cd into the directory of the selected file $1, optional start dir is $2 (otherwise cur_dir)
hcdf () {
  local file
  local dir
  [ ! -z "$2" ] && cd  $2
  file=$(fzf +m -q "$1") && dir=$(dirname "$file") && cd "$dir"
}
hcd () {
  [ ! -z "$2" ] && cd $2
  cd "$(fd -H -td $1 $2 | fzf --preview="tree -L 1 {}")" && echo "$PWD" && tree -L 2
}
# file browser (show the files too: enter (to select) and ctrl-g to quit !!!)
hbr () {
  if [[ "$#" != 0 ]]; then
    builtin cd "$@";
    return
  fi
  while true; do
    local lsd=$(echo ".." && ls -p | grep '/$' | sed 's;/$;;')
    #local lsd=$(echo ".." && ls -p --group-directories-first | sed 's;/$;;')
    local dir="$(printf '%s\n' "${lsd[@]}" |
            fzf --reverse --preview '
                __cd_nxt="$(echo {})";
                __cd_path="$(echo $(pwd)/${__cd_nxt} | sed "s;//;/;")";
                if [ -d "${__cd_path}" ]; then
                        echo $__cd_path;
                        echo /;
                        ls -p --color=always "${__cd_path}";
                else
                        echo $__cd_path;
                        echo;
                        highlight -O ansi -l "${__cd_path}";
                fi
        ')"
    [[ ${#dir} != 0 ]] || return 0
    if [ -d "$dir" ]; then
      builtin cd "$dir" &> /dev/null
    else
      print -z "vi $dir"
    fi
  done
}

##########################################################################
hxn () {
 # hx-narrow : narrows using fzf
 # TODO bail out if no line is selected
  if [ ! "$#" -gt 0 ]; then echo "Need a file to look at!"; return 1; fi
  # print -z "hx $1 +$(nl -b a $1 | fzf -e | awk '{print $1}')"
  hx $1 +$(nl -b a $1 | fzf -e | awk '{print $1}')
}

# ripgrep->fzf->vim [QUERY]
rfv() (
  RELOAD='reload:rg --column --color=always --smart-case {q} || :'
  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
            vim {1} +{2}     # No selection. Open the current line in Vim.
          else
            vim +cw -q {+f}  # Build quickfix list for the selected items.
          fi'
  fzf --disabled --ansi --multi \
      --bind "start:$RELOAD" --bind "change:$RELOAD" \
      --bind "enter:become:$OPENER" \
      --bind "ctrl-o:execute:$OPENER" \
      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
      --delimiter : \
      --preview 'bat --style=full --color=always --highlight-line {2} {1}' \
      --preview-window '~4,+{2}+4/3,<80(up)' \
      --query "$*"
)

fif1() {
 : quickly find in files using fuzzy search and surrounding context
 local query="${*:-}"
 local result file line
 result="$(
        FZF_DEFAULT_COMMAND="rg --column --line-number --no-heading --color=always --smart-case -- '$query'" \
        fzf --ansi \
            --disabled \
            --query "$query" \
            --bind 'change:reload:rg --column --line-number --no-heading --color=always --smart-case -- {q} || true' \
            --delimiter ':' \
            --nth '4..' \
            --preview 'bat --style=numbers --color=always --highlight-line {2} -- {1}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
    )" || return
 [[ -z "$result" ]] && return
 file="${result%%:*}"
 result="${result#*:}"
 line="${result%%:*}"
 "${EDITOR:-vim}" "$file" "+$line"
}