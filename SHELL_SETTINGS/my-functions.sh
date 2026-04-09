alias print_funcs='print -l ${(k)functions} | rg '"'"'^[^._-]'"'"' '
######################################################################
# TRICK avoid 'exit' in all cases; "kill -INT $$" terminates the script safely in either case. !!!
##########################################################
gitmeld() {
  git difftool -x 'meld "$LOCAL" "$REMOTE"' "$@"
}

open_file_below() {
  vterm_cmd find-file-below "$(realpath "${@:-.}")"
}

run_in_emacs_shell() {
  local cmd="$*"
  emacs --eval "(progn
                  (shell)
                  (comint-send-string (current-buffer) \"$cmd\n\"))"
}

pytr() {
  pwd | python3 -c "import re; print(re.sub('$1','$2',open(0).read()))" | tee /dev/tty | hclip
  #pwd | pyline -i re "re.sub('$1','$2',line)" | tee /dev/tty | hclip
}

show_builds() {
  fdl -L --max-depth 1 -td $1 /cm/ot/TACT/
}

pairwise_reverse() {
  # fd -e adb opera -X ls -rt | pairwise_reverse | while read first second;do meld $first $second;done
  while IFS= read -r line; do files+=("$line"); done
  num_files="${#files[@]}"
  for ((i=num_files-1; i>0; i--)); do
    printf "%s %s\n" "${files[i]}" "${files[i-1]}"
  done
}

###############################################################################
command_exists() {
  command -v "$@" >/dev/null 2>&1
}

dedent() {
  local -n reference="$1"
  reference="$(echo "$reference" | sed 's/^[[:space:]]*//')"
}
# https://www.reddit.com/r/commandline/comments/11c2h0v/automatically_running_commands_when_you_enter_or/
____cd() {
  _arg="$1"
  _efile='./.env'
  test -f "$_efile" && test -G "$_efile" && . $_efile leave
  command cd $_arg
  rc=$?
  test -f "$_efile" && test -G "$_efile" && . $_efile enter
  unset _arg _efile
  return $rc
}
##################################################################
# changes the current directory to the specified destination,
# lists the contents of the new directory
# and limits the size of the directory stack.
mcd() {
  DST="$1"
  [ -z "$1" ] && DST="$HOME"
  pushd "$DST" &>/dev/null && lsd -FArtl --group-dirs first --date relative
  popd +500 &>/dev/null
}
################################################################
# The [ -t 1 ] check only works when the function is not called from
# a subshell (like in `$(...)` or `(...)`, so this hack redefines the
# function at the top level to always return false when stdout is not
# a tty.
if [ -t 1 ]; then
  is_tty() {
    true
  }
else
  is_tty() {
    false
  }
fi
######################################################################
write2prompt() {
  #> example usage: echo "MY CMD" | write2prompt
  perl -e 'ioctl STDOUT, 0x5412, $_ for split //, do{ chomp($_ = <>); $_ }'
}
#######################################################################
# while read n; do (( x++ )); done <<(seq 5)
# instead of this where you can't modify variables in the loop, since it runs in a subshell
# seq 5 | while read n; do (( x++ )); done

# to test if x is empty or undefined
# test ${#x} = 0
###########################################################
function remove_empty_lines {
  sd '^\s*\n' '' $1
  #sed -i '/^$/d' $1
}

function between() { # return lines between start and end, first arg is filename
  X=$2
  Y=$3
  Z=$((Y - X + 1))
  tail -n "+$X" $1 | head -n "$Z"
}

function cpman {
  # copy man page to where it belongs
  # echo "copying man page $1 to ~/.local/share/man/man1/"
  cp $1 ~/.local/share/man/man1
}

function most_common {
  # gives the most commnon entries in the history
  fc -l 1 | pyone -f collections -f pprint 'a=[];EL{a.append($2)};pprint(Counter(a).most_common())'
}

################################################################################################
## https://github.com/dduan/ea/blob/main/docs/UserManual.md
alias nfd='ea run linear fd --' # numbered fd, type 'ea p <number>' to retrieve an entry
ep() {
  # ep <number> to get a command
  ea p $1 "hemacs {path}" | write2prompt
}
#########################################################################
yn() {
  # usage: yn do you want to continue && echo you said yes || echo you said no
  printf "$* (y/N) "
  read -r REPLY
  [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]
}

# iterate the line of a file and call input function
iterlines() {
  (($# < 2)) && {
    echo "Usage: iterlines <File> <Callback>"
    return
  }
  local File=$1
  local Func=$2
  n=$(cat "$File" | wc -l)
  for ((i = 1; i <= n; i++)); do
    "$Func" "$(sed "${i}q;d" "$File")"
  done
}

#better tree
tre() { command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null; }

function run_one_liner() { line=$(fzf -i <$HOME/.local/oneliners.txt) && echo "$line" | sed 's/.*`\(.*\)`.*/\1/' | sh; }

# Searches for text in all files in the current folder
ftext() {
  # -i case-insensitive
  # -I ignore binary files
  # -H causes filename to be printed
  # -r recursive search
  # -n causes line number to be printed
  # optional: -F treat search term as a literal, not a regular expression
  # optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
  grep -iIHrn --color=always "$1" . | less -r
}

function my_aliases() {
  alias | fzf -e
}


function see_Tlogs() {
  function find_Tlogs {
    cd /cm/ot/TACT
    USER=${1:-EKHASSAN} # DEFAULT PARAMETER IS EKHASSAN
    USER=$(python -c "print ('${USER}'.upper())")
    fd -td -L -d1 -0 -p ${USER} | xargs -0 ls -td | while read dir; do
      fd -e log Tlog-in $dir
    done
  }
  function find_new_failing_tests {
    file=$1
    echo $file
    #start_line_number=$(echo "a=\"$(rg -n 'New tests failing' $file)\".split(':');print(a[0])" | python)
    start_line_number=$(python -c "a=\"$(rg -n 'New tests failing' $file)\".split(':');print(a[0])")
    echo "start linenumber=$start_line_number"
    end_line_number=$(rg -n "Tests still failing" $file | cut -d ':' -f 1)
    awk "NF && NR >= $start_line_number && NR < $end_line_number" $file | rg '\w*\.el\b'
    #echo "emacs +$start_line_number \"$file\"" | xclip -selection clipboard
    echo "emacs +$start_line_number \"$file\"" | write2prompt
  }
  find_new_failing_tests "/cm/ot/TACT/$(find_Tlogs "$1" | fzf -e)"
}
function tailc {
  # tail with colors
  tail $@ | ccze -A
}

function my_functions() {
  CMD=$(
    (functions | grep "()" | cut -d ' ' -f1 | grep -v "^_") | fzf --preview 'rg --color always -A10 {}' | cut -d '=' -f1
     )
  eval $CMD
}


eh() {
  hemacs "$@" --load ~ekhassan/e.el
}

# returns file modification age in seconds
fileAge() {
  local fileMod
  if fileMod=$(stat -c %Y -- "$1"); then
    echo "$(($(($(date +%s) - $fileMod)) / 60)) minutes ago"
  else
    return $?
  fi
}

shuffle() { # moves first arg to the end, preceded by a plus
  list=($(echo $1))
  echo "${list[@]:1}+${list[1]}"
}

###################################### general utilities #########################################################

function highlight {
  # usage: command_here | highlight green "input" | highlight red "output"
  declare -A fg_color_map
  fg_color_map[black]=30
  fg_color_map[red]=31
  fg_color_map[green]=32
  fg_color_map[yellow]=33
  fg_color_map[blue]=34
  fg_color_map[magenta]=35
  fg_color_map[cyan]=36

  fg_c=$(echo -e "\e[1;${fg_color_map[$1]}m")
  c_rs=$'\e[0m'
  sed -u s"/$2/$fg_c\0$c_rs/g"
}

# calc on the command line e.g. '= 7*8'
= () {
       bc -l <<< "$*"
}

mkcd() {
  mkdir -p $1 && cd $1
}

htail() {
  tail $@ | ccze -A
}
alias explain='python3 ~/.local/bin/explain.py'
show_centered() {
  COLUMNS=$(tput cols)
  title=$1
  printf "%*s\n" $(((${#title} + $COLUMNS) / 2)) "$title"
}

fuzzy-search-executables() {
  which $(compgen -c) 2>/dev/null | huniq | fzf
}

# if [ -z "${1}" ] || [ -z "${2}" ]; then
# printf "\nNo commit message provided"
# fi
######################################## git branches #####################################
br() {
  b="$(git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short) %(contents:subject) (%(committerdate:relative))' | fzf --no-sort)" && git checkout "${b%% *}"
}

############################################## COLORED ECHO ############################################################
# https://github.com/ppo/bash-colors/blob/master/bash-colors.sh
#c() { [ $# == 0 ] && printf "\e[0m" || printf "$1" | sed 's/\(.\)/\1;/g;s/\([SDIUFNHT]\)/2\1/g;s/\([KRGYBMCW]\)/3\1/g;s/\([krgybmcw]\)/4\1/g;y/SDIUFNHTsdiufnhtKRGYBMCWkrgybmcw/12345789123457890123456701234567/;s/^\(.*\);$/\\e[\1m/g'; }
#cecho() { echo -e "$(c $1)${2}\e[0m"; }

#source ./xcol.sh
############################################# PURE BIBLE snippets (https://github.com/dylanaraps/pure-bash-bible) ##########################
trim_string() {
  # Usage: trim_string "   example   string    "
  : "${1#"${1%%[![:space:]]*}"}"
  : "${_%"${_##*[![:space:]]}"}"
  printf '%s\n' "$_"
}
SLEEP_DURATION=${SLEEP_DURATION:=1}  # default to 1 second, use to speed up tests
DISPLAY_CHAR="▇"
hsleep() {
  local duration # TOTAL SLEEP DURATION IN MINUTES !!!!
  local columns
  local space_available
  local fit_to_screen
  local space_reserved

  space_reserved=6   # reserved width for the percentage value
  duration=$(( ${1} * 60 )) # given duration is in minutes
  columns=$(tput cols)
  space_available=$(( columns-space_reserved ))

  if (( duration < space_available )); then
    fit_to_screen=1;
  else
    fit_to_screen=$(( duration / space_available ));
    fit_to_screen=$((fit_to_screen+1));
  fi

  already_done() { for ((done=0; done<(elapsed / fit_to_screen) ; done=done+1 )); do printf $DISPLAY_CHAR; done }
  remaining() { for (( remain=(elapsed/fit_to_screen) ; remain<(duration/fit_to_screen) ; remain=remain+1 )); do printf " "; done }
  percentage() { printf "| %s%%" $(( ((elapsed)*100)/(duration)*100/100 )); }
  # clean_line() { printf "\r"; }
  clean_line() { printf "\n"; }

  for (( elapsed=1; elapsed<=duration; elapsed=elapsed+1 )); do
    already_done; remaining; percentage
    sleep "$SLEEP_DURATION"
    clean_line
  done
  clean_line
}
strip() {
  # Usage: strip "string" "pattern"
  # $ strip "The Quick Brown Fox" "[aeiou]"
  # Th Quick Brown Fox

  # $ strip "The Quick Brown Fox" "[[:space:]]"
  # TheQuick Brown Fox
  printf '%s\n' "${1/$2/}"
}

strip_all() {
  # Usage: strip_all "string" "pattern"
  # $ strip_all "The Quick Brown Fox" "[aeiou]"
  # Th Qck Brwn Fx

  # $ strip_all "The Quick Brown Fox" "[[:space:]]"
  # TheQuickBrownFox

  # $ strip_all "The Quick Brown Fox" "Quick "
  # The Brown Fox
  printf '%s\n' "${1//$2/}"
}

lstrip() {
  # Usage: lstrip "string" "pattern"
  printf '%s\n' "${1##$2}"
}

rstrip() {
  # Usage: rstrip "string" "pattern"
  printf '%s\n' "${1%%$2}"
}

cdfd() {
  #res=($(fd $@)) # we want an array !
  #if [ "${#res[@]}" -gt 1 ]; then
  #  res=$(printf "%s\n" "${res[@]}" | fzf)
  #fi
  #cdf $res
  ################# NEW #####################
  #M=$(for x in $S; do if [ $(( x % 2 )) == 0 ]; then echo $x; fi done)
  res=($(for f in $(fd $@); do printf "%s\n" $(dirname $f); done))
  if [ "${#res[@]}" -eq 1 ]; then
    cd $res
  else
    mdir=$(printf "%s\n" ${res[@]} | huniq | fzf)
    echo "cd to $mdir"
    cd $mdir
  fi
}

cdf() {
  cd $(dirname $1)
}

cdwhich() {
  cdf $(which $1)
}

cdpywhich() {
  cdf $(pywhich $1)
}

catwhich() {
  cat $(which $1)
}

regex() {
  # Usage: regex "string" "regex"
  # [[ $1 =~ $2 ]] && printf '%s\n' "${BASH_REMATCH[1]}"
  [[ $1 =~ $2 ]] && printf '%s\n' "${match}"
}

#pytest() {python -c "import sys;sys.exit(0) if $1 else sys.exit(1)"}
pytestX() {
  if [ $# = 0 ]; then
    cat <<EOF
Example Usages:
   a=HELLO.txt # WHOLE EXPRESSION WITHIN DOUBLE QUOTES and VARIABLE WITHIN SINGKE QUOTES !!!!!
   if \$(pytest "'\$a'.endswith('txt')");then echo IT WORKS;fi
EOF
    return
  fi
  python3 -c "if not $1: raise SystemExit(1)"
}

#export -f pyrg  # port the function so it can be inherited by subshells

pyline() {
  if [ $# = 0 ]; then
    cat <<EOF
#USAGE
ls | pyline "line if 'move' in line else ''"
ls | pyline -i re "re.sub('py','PYYY',line)"
procs ekhassan | pyline "line.split()[0]" # prints the pids
CAVEAT: the line ends with "\n" !!!!
EOF
    return
  fi
  typeset -a imports
  while [ "$1" = "-i" ] && [ "$2" ]; do;imports+=("$2"); shift 2; done
  PYTHON_COMMAND=""
  for import in "${imports[@]}"; do PYTHON_COMMAND="${PYTHON_COMMAND}import $import;"; done
  PYTHON_COMMAND="${PYTHON_COMMAND}[print($1,end='') for line in open(0)]"
  echo "================> $PYTHON_COMMAND"
  python3 -c "$PYTHON_COMMAND"
}

alias d=pydict

myrcsfiles() {
  #PREVIEW_CMD='bat --color=always $(echo {} | python3 <<< "print(chr(46)*2+chr(47)+open(0).read()[:-3])")'
  PREVIEW_CMD='bat --color=always {}'
  pyfd "FILENAME+',v'" RCS -a | pyrepl "'RCS/'" "" | pyrepl "GG+',v'" '$1' | fzf --preview "$PREVIEW_CMD"
}
#################################################################################################
encode_base64() {
  # cat hello.dot | encode_base64
  python3 <<<"import base64; import zlib; print(base64.urlsafe_b64encode(zlib.compress(open(0).read().encode('utf-8'), 9)).decode('ascii'))"
}

decode_base64() {
  # echo "eNpLyUwvSizIUHBXqPZIzcnJ17ULzy_KSanlAgB1EAjQ" | decode_base64
  python3 <<<"import base64; import zlib; print(zlib.decompress(base64.urlsafe_b64decode(open(0).read())).decode('utf8'))"
}
#################################################################
vterm_printf() {
  if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ]); then
    # Tell tmux to pass the escape sequences through
    printf "\ePtmux;\e\e]%s\007\e\\" "$1"
  elif [ "${TERM%%-*}" = "screen" ]; then
    # GNU screen (screen, screen-256color, screen-256color-bce)
    printf "\eP\e]%s\007\e\\" "$1"
  else
    printf "\e]%s\e\\" "$1"
  fi
}
vterm_prompt_end() {
  vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
}
# For example, vterm_cmd message "HI" will print "HI".
# To enable new commands, you have to customize Emacs's variable
# vterm-eval-cmds.
vterm_cmd() {
  local vterm_elisp
  vterm_elisp=""
  #echo "===========> $*"
  while [ $# -gt 0 ]; do
    vterm_elisp="$vterm_elisp""$(printf '"%s" ' "$(printf "%s" "$1" | sed -e 's|\\|\\\\|g' -e 's|"|\\"|g')")"
    shift
  done
  #echo "==> $vterm_elisp"
  vterm_printf "51;E$vterm_elisp"
}
vterm_cmd_one_arg() {
  local vterm_elisp
  vterm_elisp="$(printf '"%s" ' "$(printf "%s" "$1" | sed -e 's|\\|\\\\|g' -e 's|"|\\"|g')")"
  shift
  # i want all arguments to be a single string
  vterm_elisp="$vterm_elisp""$(printf '"%s" ' "$(printf "%s" "$*" | sed -e 's|\\|\\\\|g' -e 's|"|\\"|g')")"
  #echo "==> $vterm_elisp"
  vterm_printf "51;E$vterm_elisp"
}
####################################### PIPED OUTPUT ##########################
# https://github.com/akermu/emacs-libvterm/issues/524
vp() {
  # If receiving from stdin
  if [ -p /dev/stdin ]; then
    pipe_input=()
    # read all lines into an array
    mapfile -n 0 -t pipe_input || {
      echo "ERROR: mapfile failed in" "${FUNCNAME}"
      exit 1
    }
    # using the array directly fails for long outputs
    # vterm_cmd bash_pipe "${pipe_input[@]}"
    # replace newlines with '#nl#'
    nl_arr=$(printf '%b#nl#' "${pipe_input[@]}")
    vterm_cmd bash_pipe "${nl_arr}"
    # the preceding fails for files containing escape chars like ''
    # maybe use the '%q' which escapes non-printable chars instead?
    # null_arr=$(printf '%q\0' "${pipe_input[@]}")
  else
    vterm_cmd bash_pipe "$*"
  fi
}
vterm_less() {
  printf "\e]51;Eless \""
  cat | base64 -w0
  printf "\"\e\\"
}
# if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
#     alias less=vterm_less
# fi

###################################################################################
vterm_ripgrep() {
  if [ $# -eq 0 ]; then
    echo "No arguments provided."
  elif [ ! -t 0 ]; then
    # input comes from a pipe
    rg $@
  else
    # Get the total number of arguments
    # The last argument is the pattern !!!
    pattern="${@:$#}"
    #echo "PATTERN=$pattern"
    # Get all parameters except the last one
    args=$(echo "${args[@]}" | python3 -c "print(' '.join(open(0).read().split()[:-1]))")
    # Do something with the parameters
    #echo "All parameters except the last one: $args"
    vterm_cmd ripgrep-regexp $pattern $PWD "${args[@]}"
    #vterm_cmd ripgrep-regexp "$@" $PWD ""
  fi
}
vterm_compile() {
  vterm_cmd vterm-compile "$@"
}
vterm_debug() {
  vterm_cmd debug-vterm "$@"
}
#################################################################
PS1='$(get_prompt)'
if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
  PS1="${PS1}$(vterm_prompt_end)"
  #
  alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'
  alias cls='vterm_printf "51;Evterm-clear-scrollback";tput clear'
  #
  # alias o='vterm_cmd find-file' # open file within a vterm !!!!
  # alias ol='vterm_cmd find-file-at-line' # open file within a vterm !!!!
  # alias oo='vterm_cmd find-file-other-window'
  alias o='open_file_below' # open file or dir within a vterm !!!!
  #
  alias vtrg='vterm_ripgrep'      # ripgrep with new compilation buffer format !!!
  # use 'rrg' for compilation output in same vterm buffer
  alias vcompile='vterm_compile' # not necessary,
  alias vdebug0='vterm_cmd_one_arg run-gud-from-vterm'
  alias vdebug='vterm_debug'
  EDITOR='vterm_cmd find-file'
elif [[ "$TERM_PROGRAM" = 'vscode' ]]; then
  alias o='vs'
  EDITOR=code
elif [[ "$TERM_PROGRAM" = 'zed' ]]; then
  alias o='zd -a'
  EDITOR='zed'
elif [[ "$TERM_PROGRAM" = 'Terminus-Sublime' ]]; then
  alias o='sb'
  EDITOR='sb'
else
  EDITOR=hx
fi
##################################################################
#Here's a handy delta trick for you, to turn the side-by-side feature on and off based on window size. bash here, other shells left as an exercise:
function delta_sidebyside {
  if [[ COLUMNS -ge 120 ]]; then
    DELTA_FEATURES='side-by-side'
  else
    DELTA_FEATURES=''
  fi
}
trap delta_sidebyside WINCH
######################################################################
function forward_emacs_ssh {
  # LC_VARs get passed with the default openssh server settings.
  # Assumes the hostname is the last argument
  LC_HOSTNAME=${*: -1}
  LC_EMACS=1
  LC_EMACS_SERVER=$(cat ~/.emacs.d/server/server)
  ssh -R 5922:127.0.0.1:5922  -A "$@"
  ## ON THE REMOTE MACHINE, DO
  #mkdir -p ~/.emacs.d/server 2>&1 > /dev/null
  #echo "$LC_EMACS_SERVER" > ~/.emacs.d/server/server
}
# ;;;;;;;;;;;;;;;;;;;;;;; FUNCTIONAL PROGRAMMING IN SHELL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
# https://www.evalapply.org/posts/shell-aint-a-bad-place-to-fp-part-1-doug-mcilroys-pipeline/
# https://www.evalapply.org/posts/shell-aint-a-bad-place-to-fp-part-2-functions-as-unix-tools/
butlast_n() {
  head -n -${1:-0}
}
take_n() {
  # Given a number n, return those many lines of input
  # or 10 lines by default, if n is not specified.
  sed ${1:-10}q
}
drop_first_n() {
  local lines="${1:-0}"
  local offset="$(( lines + 1 ))"
  tail -n +"${offset}"
}
drop_last_n() {
  local lines="${1:-0}"
  head -n -"${lines}"
}
drop_header_footer() {
  local header_lines="${1:?'FAIL. Header line count required, 1-indexed.'}"
  local footer_lines="${2:?'FAIL. Footer line count required, 1-indexed.'}"
  drop_first_n "${header_lines}" | drop_last_n "${footer_lines}"
}
window_from_to_lines() {
  local from_line="${1:?'FAIL. \"FROM\" line number required, 1-indexed.'}"
  local to_line="${2:?'FAIL. \"TO\" line number required, 1-indexed.'}"
  drop_first_n "${from_line}" | head -n "${to_line}"
}

my_decorator() {
  cat <<EOF
  $(cat -)
  before
EOF
}

frequencies() {
  # Produce frequency distribution of input
  sort | uniq -c | sort -rn
}
flatten_paragraphs() {
  # English-only for easy explanation, but can be more general
  tr -cs A-Za-z '\n'
}

tokenise_lowercase() {
  # Transliterate uppercase to lowercase
  tr A-Z a-z
}
###############################################################################
# This runs programs with nohup, basicaly allows you to run programs
# without making them dependent on the terminal.
# https://www.reddit.com/r/commandline/comments/1i8mh2z/i_feel_like_this_should_be_public_knowloge_put_on/
spawn() {
  if [ "$1" = "-l" ]; then
    exec >"$2" 2>&1 || {
      printf "FATAL ERROR: Unable to log to '%s'.\n" "$2" >&2
      return 1
    }
    shift 2
  else
    exec >/dev/null 2>&1
  fi
  printf '%q ' "$@" | (nohup "${SHELL:-/bin/ksh}" &)
}

# Example of usage
# spawn -l out.log echo This is "a     test"
# SIMPLER
# nohup /path/to/some/program arg1 arg2 >program.log &
###################### BOOKMARK system ###########################################
source ~ekhassan/bin/shelf.ksh
##################################################################################
