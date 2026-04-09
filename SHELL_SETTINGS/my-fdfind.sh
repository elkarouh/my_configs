###################################
alias rfd='fd --changed-within 1day' # fd for recent files
alias fdh='fd -H' # search also hidden directories
alias fd.='fd -H -d1' # only search in current dir, also for hidden files, no subdirs !!!
alias fdx="fd -d1 -tf '^[^.]+$'" # find files without extensions in curr dir
fdfile () {
  FILENAME=$1
  shift
  the_date="$(date -d "$(stat -c %y $FILENAME)" '+%Y-%m-%d %H:%M:%S')"
  fd --change-newer-than "${the_date}" $@
}

# Find files that were modified by a given command
# touch /tmp/file ; $EXECUTECOMMAND ; fdfile /tmp/file
##################################
alias fd,='hdir2'
##################################
alias fz=fzfx
# alias ffd='fd | fzy'
alias hid='fc -li 1'  # like history but with dates
alias changedfiles="fd -0 | xargs stat --format '%Z :%z %n' | sort -nr | cut -d: -f2- | head -n 20"
############################################################################################
# ffind 'xyz' instead of find -iname '*xyz*'
####################################################

my_fd () {
  (( "$#" )) || { printf 'Insufficient arguments provided \n' >&2; return 1; }
  find "$1" -regextype egrep -iregex ".*\.(sh|md)$"
}

hdir () {
  fd -d 1 "$@" --exec-batch lsd -rtl
}

vfd () { # SEARCH THE VOB
  echo Searching \"$1\" in $CM_VOB
  fd -tf $1 $CM_VOB
}
ffind() { find -iname '*'"$@"'*' ; }
lf2() { # list latest files, only current dir
  fd -H -d1 -tf -tl --changed-within 1d . "$@" -X lsd -FArtl --date relative
  #fd -H -a  -d1 -tf -tl "$@" -X ~ekhassan/.local/bin/lsd -FArtl
}

lrec() { # show the recent files in the current directory: e.g lrec -D 1h OR lrec -D 1h . PATH
  if [[ "$@" == *"-D "* ]]; then
    fd -d 1 -tf ${@/-D/--changed-within} -X lsd -rtl --date relative
  else
    fd -d 1 --newer 1d -tf $@ -X lsd -rtl --date relative
  fi
}

#list my .justfiles !!
#ljf(){
#  print -z $(fd -e just . ~ekhassan/REPLAYS/AIREON_REPLAYS/bin | fzf)
#  }


# "| cat - <(alias | cut -d= -f1)" is a smart way to append to a pipe !!!!! Note that it'll newline-separate the concatenated streams;
# | cat - <(declare -f  | rg -o "^[a-z_]\+" | grep -vE "^dequote|^quote|^in_array")
xx() { # show all executables on the path + ALL FUNCTIONS + ALL ALIASES !!!
    cmd=$(echo ${PATH//\/\//\/} | tr : '\n' | xargs -I{} fd -tx -tf -tl -d1 . {} 2> /dev/null  | cat - <(declare -f  | grep -o "^[a-z_]\+") | cat - <(alias | cut -d= -f1) | sort | uniq | fzf -e --preview "alias {} || declare -f {} || (file {} | grep -iq ASCII && cat {})" -q "$(echo $@)")
    test -n "$cmd" && print -z $(basename $cmd)
}

xf() { # show ALL FUNCTIONS + ALL ALIASES !!!
    cmd=$(declare -f  | grep -o "^[a-z_]\+" | cat - <(alias | cut -d= -f1) | sort | uniq | fzf -e --preview "alias {} || declare -f {}")
    test -n "$cmd" && print -z $(basename $cmd)
}
#sk --ansi -i -c 'rg --color=always --line-number "{}"' --preview "preview.sh {}"
#sk --ansi -i -c 'rg --color=always --line-number "{}"'

henv() {
    env | fzf -e
}

# list man pages
list_man() {
  manlist=$(man -k . 2>/dev/null | awk 'BEGIN {FS=OFS="- "} /\([1|4]\)/ {gsub(/\([0-9]\)/, "", $1); if (!seen[$0]++) { print }}' | fzf) \
    && man "$(echo "$manlist" | awk -F' |,' '{print $1}')" \
    && unset manlist
}

# list env variables
list_env() {
  var=$(printenv | cut -d= -f1 | fzf) \
    && echo "$var=$(printenv "$var")" \
    && unset var
}

#vf() {fzf | myxargs vi {};}
# h - history
hh() {
  #print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s -e --tac -q ${1:- ''} | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
  print -z $(fc -l 1 | fzf +s -e --tac -q ${1:- ''} | tr -s ' ' | cut -d ' ' -f 3-)
}

# hkill - kill processes - list only the ones you can kill. Uses "top" to show the processes using the most memory to kill !
htop() {
    local pid
    pid=$(top -b -n 1 | tail -n +6 | fzf -e -m | awk '{print $1}')
    pids=($pid)
    if [ "x$pid" != "x" ]
    then
        print -z "kill -9 "${pids[@]}""
    fi
}
hkill() {
    local pid
    pid=$(show_processes | fzf -e -m | awk '{print $2}')
    pids=($pid)
    if [ "x$pid" != "x" ]
    then
        print -z "kill -9 "${pids[@]}""
    fi
}
hkill1() {
    local pid
    pid=$(lsof | fzf -e -m | awk '{print $2}')
    pids=($pid)
    if [ "x$pid" != "x" ]
    then
        print -z "kill -9 "${pids[@]}""
    fi
}
hkill2() {
    local pid
    pid=$(lsof | fzf -e -m | awk '{print $2}')
    pids=($pid)
    if [ "x$pid" != "x" ]
    then
        print -z "kill -9 "${pids[@]}""
    fi
}
rhist() {
    # first do 'rlog FILE' to see the description, then 'rhist FILE' sssss
    local revision
    #revision=$(rlog $1 | rg 'revision \d\.\d+' | fzf -e -m | awk '{print $2}')
    revision=$(rlog $1 | awk '/^revision/ {print $2;getline;getline;printf "    ===><<%s>>\n",$0}' | fzf -e)
    #echo $revision
    if [ "x$revision" != "x" ]
    then
        print -z "rcs co -p "${revision} $1""
    fi
}

hkill0() {
    local pid
    pid=$(ps -ef --sort=-start_time | fzf -e -m | awk '{print $2}')
    pids=($pid)
    if [ "x$pid" != "x" ]
    then
        print -z "kill -9 "${pids[@]}""
    fi
}


htail() {
  tail -f $1 | bat --paging=never -l log
}

hdir2 () {
   print -z $(fd -L -tf ${@/-d/--changed-within} | fzf --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200')
}
hdir1() { # only current dir
   print -z $(fd -d 1 -tf ${@/-d/--changed-within} | fzf --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200')
}
##########################################################
lfa() {
  fd -a -tf "$@" -X lsd -Artl
}

fdlog() { # show the most recent logs
    echo "Changed logs in the past ${1:-10} minutes"
    #fd -tf --changed-within "${1:-10}min" log$ | xargs -I{} bash -c 'echo "{} -> $(( $(( $(date +%s)-$(stat -c %Y -- "{}") ))/60 )) minutes ago"'
    fd -tf --changed-within "${1:-10}min" '(log|_out_01)$' -x bash -c 'echo "{} -> $(( $(( $(date +%s)-$(stat -c %Y -- "{}") ))/60 )) minutes ago"' | sort -k3 -n -r
    #fd -tf --changed-within "${1:-10}min" log$ -x bash -c fileAge {}
}

fdlogs () {
    #print -z $(fd -tf --changed-within "${1:-10}min" log$ | sk -m -e)
    print -z $(fd -tf --changed-within "${1:-10}min" '(log|_out_01)$' | fzf --preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | tail -50')
}

fdpa() { # fd but only for the executables in the path
  path=`echopath | sort | uniq | tr '\n' ' '`;
  fd -tx "${@:2}" $1 $path 2> /dev/null
}

fff() {
    sels=( "${(@f)$(fd "${fd_default[@]}" "${@:2}"| fzf -m)}" )
    if test -n "$sels"; then
        print -z -- "$1 ${sels[@]:q:q}"
    else
        print -z -- "$1"
    fi;
 }
hfind() { # fuzzy search in non-interactive mode : hfind ada debug py$
    # we concatenate all arguments in one string "ada debug py$"
    sk -e -f "$(echo "$@")"
}


#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fif() {
  myfile=$(rg -L --files-with-matches --no-messages "$1" | fzf --query="$(echo $2)" --preview-window=right:70% --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}")
  linenumber=$(rg --line-number "$1" $myfile | awk -F: '{print $1; exit}')
  print -z "vi $myfile +$linenumber"
}

# IT WORKS, OPEN SEVERAL FILES at line number AT ONCE (vi -p +8 .kshrc +"tabnew +3 t.ada" +"tabnew +10 .fzf.zsh")
frgOBSO() {  # frg pattern py$
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  #print -z -n "vi "
  myfiles=$(rg -L --files-with-matches --no-messages "$1" | fzf -m -q "$(echo ${@:2})" --preview-window=bottom:70% --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}")
  res=""
  files=( $myfiles )
  my_array=(vi -p)
  i=0
  for file in "${files[@]}"
  do
    #file="${files[$i]}"
    linenumber=$(rg --line-number "$1" $file | awk -F: '{print $1; exit}') # ONLY FIRST RESULT!!!
    if [[ $i -eq 0 ]]; then
        my_array+=( "+$linenumber" "${file}" )
    else
        my_array+=( "+\"tabnew" "+$linenumber" "${file}\"" )
    fi;
    let i=i+1
  done
  if [[ $i -ne 0 ]]; then
    #set -x
    cmd="${my_array[*]}"
    eval $cmd
    #eval "${my_array[@]}"
  fi;
  # TODO use a function instead
}

function frg_zsh {
  result=$(rg --ignore-case --color=always --line-number --no-heading "$@" |
    fzf --ansi \
        --color 'hl:-1:underline,hl+:-1:underline:reverse' \
        --delimiter ':' \
        --preview "bat --color=always {1} --theme='Solarized (light)' --highlight-line {2}" \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
  file=${result%%:*}
  linenumber=$(echo "${result}" | cut -d: -f2)
  if [[ -n "$file" ]]; then
          $EDITOR +"${linenumber}" "$file"
  fi
}

function frg_bash {
result=`rg --ignore-case --color=always --line-number --no-heading "$@" |
  fzf --ansi \
      --color 'hl:-1:underline,hl+:-1:underline:reverse' \
      --delimiter ':' \
      --preview "bat --color=always {1} --theme='Solarized (light)' --highlight-line {2}" \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'`
file="${result%%:*}"
linenumber=`echo "${result}" | cut -d: -f2`
if [ ! -z "$file" ]; then
  $EDITOR +"${linenumber}" "$file"
fi
}

# fman() {
#   man -k . | fzf -q "$1" --prompt='man> '  --preview $'echo {} | tr -d \'()\' | awk \'{printf "%s ", $2} {print $1}\' | xargs -r man | col -bx | bat -l man -p --color always' | tr -d '()' | awk '{printf "%s ", $2} {print $1}' | xargs -r man
# }
# Get the colors in the opened man page itself
#export MANPAGER="sh -c 'col -bx | bat -l man -p --paging always'"

hvnc () {
  print -z $(echo -e "\
vncviewer dhws149:10
vncviewer ptacprd:90 # 28.0 install
vncviewer dhbldd25:7 # build server
vncviewer dhws028:22 # alv
vncviewer dhws020:10 # eli
vncviewer dhws012:10 # ammaniot
vncviewer dhws056:10 # nobody
vncviewer dhws050:10 # pdcorrei
vncviewer dhws054:10 # antonio
vncviewer dhws024:10 # serge
vncviewer dhbldd19:99 # overview of all WS
vncviewer dhdevd01:99 # build master machine

vncviewer ptacprq:90 # 29
vncviewer ptacprg:33 # 28
vncviewer ptacvg5:90 # 28.0
vncviewer pprevg3:90 # ?
vncviewer dhdevd17:0 # ?
vncviewer dhws018:5 # ?
vncviewer ptacprg:5 # 27.2
vncviewer ptacot9:50 # 27.2
vncviewer pprepre:90 # 28.0
vncviewer ptacprg:90 # 27.2
vncviewer dhbldd01:99 # BUILDS MACHINE
vncviewer dhbldd25:18
vncviewer dhbldd25:2
vncviewer dhbldd25:28
vncviewer dhbldd25:5
vncviewer dhbldd25:16
vncviewer dhbldd25:7
vncviewer dhdevd15:1
vncviewer dhdevd17:1
vncviewer dhdevd18:1
vncviewer dhdevd27:1
vncviewer dhdevd28:4
vncviewer dhdevd28:1
vncviewer dhtacd04:1
vncviewer dhtacd05:1
psh taccsa # password cfmuadm*
" | fzf)
  }

make_links_to_build() {
  # fd needs a single root directory so i make symlinks under /tmp/ROOT
  rm -fr /tmp/ROOT/
  mkdir -p /tmp/ROOT/
  echo "BUILDING CLOSURE LINKS"
  echo $ADA_INCLUDE_PATH | sd : '\n' | while read path;do ln -s $path "/tmp/ROOT/$(echo $path | sd '/' '_KOKO_')" ;done
}

# explore the vob
# ONLY ADB and ADS files !!!
hvob() {
  make_links_to_build
  print -z "emacs $(fd -L -tf -e adb -e ads . /tmp/ROOT -x readlink -f {}  | sk -m -e -q $(echo $@))"
}

# explore the vob
# only script files !!!
hvob1 () {
  # this version with sk is faster than with fzf!!!
  print -z "xlsvtree $(fd -tf -e adb -e ads -e el -e ksh -e sql . $CM_VOB | sk -m -e -q $(echo $@))"
  #print -z "xlsvtree $(fd -tf -e adb -e ads -e el -e ksh -e sql . $MY_TACT_SOURCES | sk -m -e -q $(echo $@))"
  # files= $(fd -tf . $CM_VOB | sk -m -e -q "$(echo $@)")
  # [[ -n "$files" ]] && print -z "${files[@]}"
}

# defaultBind="f1:execute-silent(xdg-open {} 2>/dev/null)+cancel,f2:execute($editor {})+cancel,f3:execute-silent(xclip <<< {})+cancel,f4:accept,enter:execute(echo $searchPath/{})+abort"
defaultBind="enter:accept,Ctrl-v:execute(vi -R {} > /dev/tty)"
defaultHeader="enter → Confirm choice (use tab for multiple select), Ctrl-v -> view, Ctrl-q -> Quit"

f6 () {
  test ${#1} = 0 && echo "Need one argument" && return 1
  res=$(echo $(lolcate --db TACT_CLOSURE $1 --type all_vob | fzf -e -m --bind "$defaultBind" --header "$defaultHeader" --preview "bat --color=always --style=numbers --line-range=:500 {}" --preview-window down,80%))
  if [ "$res" ]; then
    echo "Ccheckout -force $res" | write2prompt
  fi
}

f6_exact () { # we know the exact filename
  test ${#1} = 0 && echo "Need one argument" && return 1
  res=$(lolcate --db TACT_CLOSURE $1 --type all_vob)
  if [ "$res" ]; then
    Ccheckout -force $res
  fi
}

f7 () {
  test ${#1} = 0 && echo "Need one argument" && return 1
  res=$(echo $(lolcate --db TACT_CLOSURE $1 --type all_vob | fzf -e -m --bind "$defaultBind" --header "$defaultHeader" --preview "bat --color=always --style=numbers --line-range=:500 {}" --preview-window down,80%))
  if [ "$res" ]; then
    echo "emacs $res" | write2prompt
  fi
}
ivob () {
    print -z $(fd -tf . $CM_VOB | sk -m -e -q "$(echo $@)")
}
ifd () {
    print -z $(fd -tf . $1 | sk -m -e -q "$(echo $@)")
}


hvob2 () { # slow version with fzf
    print -z $(fd -tf . $MY_TACT_SOURCES | fzf -m -e -q "$(echo $@)")
}

#
frg2() {  # EDIT A FILE ONE AT A TIME !!!!
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  myfile=$(rg -L --files-with-matches --no-messages "$1" | fzf --query="$(echo $2)" --preview-window=right:70% --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}")
 if [[ -n "$myfile" ]]; then
  linenumber=$(rg --line-number "$1" $myfile | awk -F: '{print $1; exit}')
  vi $myfile +$linenumber
  fe2 $1
  fi;
}
# THIS ONE NEEDS SOME WORK !
fxxxgr() {
    fd $@ | sk --ansi -i --preview "preview.sh {}" -c 'rg --color=always --line-number "{}"'
}

rga-fzf() {
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
        xdg-open "$file"
}
