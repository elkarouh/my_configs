#!/usr/bin/env ksh
alias rh8='scl enable gcc-toolset-12 ksh' # enable new libraries (REDHAT8)
alias pycod='echo "first run rh8 "; ~/.codon/bin/codon' # the python-like compiler
alias nuitka='nuitka --standalone --onefile'
alias rm,,="echo -e 'If you want to use rm really, then use \"\\\\rm\" instead.'; false"
alias mtop='~mea/bin/htop'
alias docker=podman
alias Hgrep='Pgrep -closure TACT'
###################### clipboard #######################
alias hpaste='xsel --clipboard' # pipe into hclip to paste to the clipboard
###############################################################################
alias my_show_processes='ps -eo user,pid,comm,lstart --sort=-lstart'
alias termaid='python -m termaid'
alias wssh='wezterm ssh'
#alias hclock='TZ=Europe/Brussels xclock -d -strftime "%H:%M:%S"'
alias hclock='TZ=Europe/Brussels xclock -d -brief -chime'
############################################################################
alias hclone='git clone --depth 1'
alias wksh='ENV=~/WAOkshrc ksh' # wao’s terminal !!!
alias hksh='ENV=~/WAOkshrc ksh' # wao’s terminal !!!
alias hget='eget' # get files from github releases
alias miniserve='miniserve -i 0.0.0.0 -p 8000 '
# alias br='br -s'
alias tparse='tree-sitter parse'
alias gv='get_view'
alias ada-parse='parse -quiet -file'
alias less='less -r' # PRESERVE THE COLORS !!!!
##alias -g cdd,='cd;cd "$(fd -td --hidden | fzf)"'
alias gho='ghostty'
alias v,='if res=$(fd -H -tf -tl . | fzf -e -m);then v $res;fi'
alias xa='if res=$(alias | cut -d= -f1 | fzf -e -m);then echo $res | write2prompt;fi'
alias typora,='if res=$(fd -e md -tf -tl | fzf -m);then typora $res;fi'
# alias t='tmux new -s'
alias erd='erd -H --sort rmod --dir-order first'
alias duf='duf -sort usage'
function lfs1 {
  lfs -f "use > 88%"
  }
#alias -g ,fc='$(rg -c never| fzf)'  # vi ,ff
# HOW TO ESCAPE SINGLE QUOTES WITHIN SINGLE-QUOTED STRING
#Explanation of how '"'"' is interpreted as just ':
#    ' End first quotation which uses single quotes.
#    " Start second quotation, using double-quotes.
#    ' Quoted character.
#    " End second quotation, using double-quotes.
#    ' Start third quotation, using single quotes.
alias proxy='source ~/bin/eurocontrol/my'
#################################### EMACS ##############################################
#alias E='emacsclient -n'
#alias ec='emacsclient'
#alias E="emacsclient -n -c"
#alias ec="TERM=xterm-256color emacsclient -n -a \"\" -t"
#alias et='emacsclient -t'
#alias edit='emacsclient -t -a emacs -nw'
#alias ed='emacs --daemon'
#alias ee='HOME=/home/ekhassan emacs'
################
alias en='emacs -nw'
alias eq='emacs -Q'
alias kille='kill -9 $(pidof emacs)'
##############
# alias v='hx' # helix editor
alias v='nem' # nem editor (nano with emacs bindings)
alias evm="eh --eval '(add-hook '\''emacs-startup-hook #'\''vterm)'"
alias ev="eh -nw --eval '(add-hook '\''emacs-startup-hook #'\''ghostel)'"
alias temv="eh --eval '(add-hook '\''emacs-startup-hook #'\''vterm)' -nw"
alias vz='v ~/.zshrc'
alias vk='v ~/.kshrc'
#alias evm='em -fs -f vterm' # same as ev but starts maximized
alias hemacs,='if res=$(fd -tf -tl | fzf -m);then cmd="emacs $res";print -s $cmd; $cmd &;fi'
#alias e='HOME=~ekhassan emacs -n --load ~ekhassan/EMACS_STUFF/themes/material-theme.el'
alias e2='HOME=~ekhassan hemacs2'
#alias et='typora'
alias e,='hemacs,'
alias vih='$EDITOR $HISTFILE'
alias ,less='ov --regexp-search'
alias wemacs='emacs -n --load ~ekhassan/EMACS_STUFF/themes/material-theme' # only in 28 context
#alias wemacs='emacs -q --load ~ekhassan/EMACS_STUFF/my_hemacs.el'
alias temacs='set +o bgnice; DISPLAY=dhws149:10 test_emacs -i -geometry 133x72+1950+30 -fh '
alias lemacs='set +o bgnice; emacs -i -geometry 133x72+1950+30 -fh '
alias femacs='set +o bgnice; DISPLAY=dhws149:0 emacs -i -geometry =133x64+70+0 -fn "-adobe-courier-medium-r-normal--*-140-*-*-m-*-iso8859-1" '
alias gemacs='set +o bgnice; DISPLAY=dhws149:10 emacs -i -geometry 133x72+1950+30 -fh '
alias my_emacs='emacs -q --load ~ekhassan/EMACS_STUFF/my_hemacs.el'
alias my_emacs2='emacs -n -q --load ~ekhassan/EMACS_STUFF/my_hemacs.el'
#alias emacs='my_emacs --load ~ekhassan/EMACS_STUFF/themes/hc-zenburn-theme.el --eval "(fira-code-mode)"'
#alias hemacs2='emacs --load ~ekhassan/EMACS_STUFF/hek-emacs2.el'
alias em1='em --load ~ekhassan/EMACS_STUFF/themes/aalto-light-theme-source-code.el'
alias em2='em --load ~ekhassan/EMACS_STUFF/themes/aalto-light-theme-source-code.el'
alias em3='em --load ~ekhassan/EMACS_STUFF/themes/material-light-theme.el'
alias em4='em --load ~ekhassan/EMACS_STUFF/themes/gruber-darker-theme.el'
alias em5='em --load ~ekhassan/EMACS_STUFF/themes/lychee-theme.el'
alias em6='em --load ~ekhassan/EMACS_STUFF/themes/spacemacs-light-theme.el'
alias em0='emacs -q -f ansi-term --load ~ekhassan/EMACS_STUFF/themes/aalto-light-theme-source-code.el'
#alias em2='em --load ~ekhassan/EMACS_STUFF/themes/moe-light.el'
#alias em5='em --load ~ekhassan/EMACS_STUFF/themes/afternoon-theme.el'
#alias qmax='my_emacs2 --load ~ekhassan/EMACS_STUFF/themes/aalto-light-theme-source-code.el' # GOOD ONE
#alias em9='emacs --load ~ekhassan/EMACS_STUFF/themes/modus-operandi-theme-source-code.el'
#alias vemacs='my_emacs -q -d :10 --load ~ekhassan/EMACS_STUFF/my_vemacs.el' # vob emacs
alias centaur_emacs='my_emacs -Q --l ~ekhassan/EMACS_STUFF/centaur/init-mini.el'
#########################################################################
alias 2out='| tee /tmp/out'  # usage: 'fd 2out'; then 'cat /tmp/out'
alias chx='chmod a+x'
# alias diff='delta'
#############################################################################################
#alias s='source $HOME/.local/SHELL_SETTINGS/my-prompt.sh;source $HOME/.local/SHELL_SETTINGS/my-shell-settings.sh'
alias configOOO='/usr/bin/git --git-dir=~ekhassan/.cfg/ --work-tree=~ekhassan/'
alias e-gdb0='emacs --load ~ekhassan/bin/hek-gdb-session.el'
#alias e-gdb='emacs -q -d $DISPLAY --load ~ekhassan/EMACS_STUFF/my_hemacs.el --load ~ekhassan/bin/hek-gdb-session.el'
#alias hgit=dotbare
#alias p='pwd'
#alias j='just'
#alias .j='just -f ~ekhassan/.justfile -d .'
alias kcheck='ksh_style_scanner -all_checks'
################################################################################################
alias rci='rcs ci -u'
alias rco='rcs co -l'
alias rlog='rcs log'
alias rdiff='rcs diff'
################################### DISK USAGE #############################################################
alias ncdu='ncdu --color dark' # for pretty colors
## 'gdu' is better than ncdu
alias myduf='du -sk * | sort -n | perl -ne '\''($s,$f)=split(m{\t});for (qw(K M G)) {if($s<1024) {printf("%.1f",$s);print "$_\t$f"; last};$s=$s/1024}'\'
################################################################################################
#alias .just='just -f {{justfile()}} -d .' # within a just file (that may have a name /= 'justfile')
# which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
alias ,g='gio open'
alias g,='gio open $(fd -tf -tl -d 1 | fzf -m)' #
alias timeit='hyperfine --warmup 3'
alias fos='fossil'
alias myxargs='xargs -0 -r -p -t -I{}'
# the below is an example of how to escape quotes within an alias definition !!!
alias remdup='awk '"'"'!visited[$0]++'"'"''
alias kolorize='ccze -A -o nolookups'
alias hdiff='difft --width 180 --ignore-comments --syntax-highlight off --display side-by-side-show-both'
alias MV='mv -iv'
alias CP='cp -iv'
alias sizex='ls -l | awk "{i+=\$5} END {print i}"'  # e.g. fd -d 1 Trepl -x ls -l | awk '{i+=$5} END {print i}'
################################################################################
alias k='journal'
################################################################################
#alias ll='ls -phartl --group-directories-first --color=auto'
#alias echopath="echo $PATH | awk 'BEGIN{RS =\":\";ORS=\"\n\"} {print}' | uniq"
#alias echopath="echo "${PATH//\/\//\/}"  | tr ':' '\n' "
alias echopath="tr : '\n' <<<$PATH"
alias showexes="echopath | xargs -I{} fd -tx -tf -tl -d1 . {} 2> /dev/null"
alias echoadapath="echo "$ADA_INCLUDE_PATH" | tr ':' '\n' "

#alias -g LL=' |& less'
#alias -g ZZ=' | fzf --layout=reverse --height=80%'
#alias lsdirfirst='ls -p --group-directories-first'
alias D='delta -ns --diff-highlight --true-color=auto --paging=always'
alias ltar="tar -ztvf" # list tar
alias untar="tar -zxvf"
alias unbz2='tar -xvjf'
#alias ctar="tar -cvzf" # create tar
#alias mktar='tar -cvf'
#alias mkbz2='tar -cvjf'
#alias mkgz='tar -cvzf'
#alias untar='tar -xvf'
#alias ungz='tar -xvzf'
alias cls='clear'

function q {
    # exit 1 still works normally
    if [[ $# -gt 0 ]]; then
        builtin exit "$@"
    # In venv? Deactivate and stay in shell
    elif [[ -n "${VIRTUAL_ENV:-}" ]]; then
        echo "👋 Deactivating venv..."
        deactivate
        echo "💡 Type 'exit' again to close terminal."
    # Not in venv? Exit normally
    else
        builtin exit
    fi
}
alias wt=wezterm
alias zj=zellij
alias ,='h'
alias ,,='ew'
alias hp=bhop
################################################ cd ######################################
# cd to the latest changed directory
alias cdl='cd `eza -1 -D -s changed |tail -1`'
alias cdL='cd $HOME/.local'
alias cdh='cd $HOME/LOCAL_HARD_DISK/local'
alias cdd='cd $HOME/Downloads'
alias cdo='cd $HOME/Documents'
alias cdnas='cd /cfmu/nasdata'
alias ssd='cd LOCAL_SSD'
alias cdB='cd LOCAL_SSD/CFMU'
alias db='cd LOCAL_SSD/GEO_ENV_DB'
alias z,=zi # zoxide interactive !!!
alias cd,='cd $(fd -uu -td -d3 | fzf -e --preview "tree -C {} | head -200")'
alias Cs='cd /home/$(whoami)/cm/; Csetup '  # setup a new view
alias Cd='cd /home/$(whoami)/cm/${CLEARCASE_ROOT##*/}; pwd'
# cd to the local dir
#alias ..='cd ..'
#alias ...='cd ../..'
#alias ....='cd ../../..'
function .. {
  cd $(printf '../%.0s' $(seq 1 $1))
}
# mkcd is defined as a function in my-functions.sh — keep that one.
# (Defining it as both an alias and a function trips zsh's parser, since
# aliases are expanded when functions are read.)
# alias mkcd='_(){ mkdir -p $1; cd $1; }; _'

#####################################################################################################
# #use bm to bookmark current directory, use to foo to go to a directory containing 'foo'
# bm () {
#     # usage: bm bookmark (bookmarks current directory)
#     [ -f ~/.config/to ] || touch ~/.config/to
#     if grep -E $PWD'$' ~/.config/to
#     then
#         echo ...already exists
#     else
#         echo "$PWD" >> ~/.config/to
#         # let us sort by directory depth
#         cat ~/.config/to | xargs -I{} sh -c 'echo "$(echo -n {} | tr -cd / | wc -c) {}"' | sort -n -k1,1 -k2 | cut -d' ' -f2- > /tmp/to
#         mv /tmp/to ~/.config/to
#     fi
# }
# to () {
#     # allows typing "to foo -bar", which becomes "foo !bar" in the fzf query
#     q=" $*"
#     q=${q// -/ !}
#     cd "$(fzf -1 +m -q "$q" < ~/.config/to)"
# }
#######################################################################################################

tere() {
    local result=$(command tere "$@")
    [ -n "$result" ] && cd -- "$result"
}
###############################################  fzf #################################
# make fzf prettier !!! ####
#fzf --prompt='Open File: ' --pointer='ᐅ'
#fzf --prompt='Open File: ' --pointer='➡'
POINTER0='➡'
pointer1='ᐅ'
color0='fg:#e6e1cf,fg+:#ddeeff,bg:#2b292E,bg+:#3D3B40,prompt:#A9DC76,pointer:#FF6188,header:#AB9DF2,query:#FFD866'
# Inspired from ayu colorscheme Vim
COLOR1='fg:#E6E1CF,fg+:#ddeeff,bg:#0F1419,pointer:#FF8400,header:#70B650,query:#FCD363'
# Inspired from afterglow theme Vim
COLOR2='fg:#E6E1CF,fg+:#ddeeff,bg:#1A1A1A,bg+:#393939,pointer:#FF8400,header:#717879'
# Inspired from sonokai theme Vim
COLOR3='fg:#E6E1CF,fg+:#ddeeff,bg:#2C2E34,bg+:#3C3E48,pointer:#EB4B48,header:#7F8490'
# d Inspired from Monokai Pro
alias fzf="fzf --pointer=$POINTER0 --color $COLOR0"
# browse with fzf (horizontally or vertically)!!!!!!!!!!!!!!!!!
alias fzfv="fzf --preview='bat --style=full --color=always {}' --bind pgup:preview-page-up --bind pgdn:preview-page-down --preview-window down,80%"
alias fzfh="fzf --preview='bat --style=full --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"

# Ctrl-b to toggle the preview. Ctrl-v to maximize the preview
alias b="fzf --preview='hek-fzf-preview {}' \
  --bind 'ctrl-p:preview-page-up,ctrl-n:preview-page-down,ctrl-b:toggle-preview,ctrl-v:change-preview-window(right:90%|right:50%)' \
  --header 'Ctrl-n: scroll down, Ctrl-p: scroll up, Ctrl-b: toggle preview, Ctrl-v: maximize preview, Ctrl-q: Quit, Esc: quit viewer'"

alias fzf-p='fzf | write2prompt'
dofzf() { local sel; sel=$(b) && "$@" "$sel"; }
alias f=dofzf # will run the command with the output of fzf, e.g. 'f hx'
########################################## lsd ###############################################
# same as above, using exa
alias   l='lsd -FArtl --group-dirs first --date relative' # --hyperlink always
alias  lt='lsd --tree'
alias lt2="lsd --tree --group-dirs first --depth=2 2>/dev/null"
alias  lr='lsd -FArtl --group-dirs last --date relative' # --hyperlink always'
alias llt='lsd -FArtl --date relative --tree' # same as lt but with more details

alias l2='eza --group-directories-first -a -l -s newest --time-style relative --icons'
alias L='eza -1labT --time-style relative -L2' # limit recursion to 2
#alias l='eza --group-directories-first -a -l -s changed --header --git --time-style relative'
###########################

#lsd --directory-only (.*|*)(^/)   # Only list files
#lsd --directory-only *(^/)        # Only list visible files
#lsd --directory-only .*(^/)       # Only list hidden files
########################################### eza aliases #####################################
# ld - lists only directories (no files)
# lf - lists only files (no directories)
# lh - lists only hidden files (no directories)
# ll - lists everything with directories first
# ls - lists only files sorted by size
# lt - lists everything sorted by time updated

# ld='eza -lD'
# lf='eza -lF --color=always | grep -v /'
# lh='eza -dl .* --group-directories-first'
# ll='eza -al --group-directories-first'
# ls='eza -alF --color=always --sort=size | grep -v /'
# lt='eza -al --sort=modified'
##########################
# other eza aliases
# alias ls='eza --group-directories-first'
# alias lsa='ls -a'
# alias l='ls -lbF'
# alias ll='l'
# alias lh='l -d .*'
# alias lb='l -B'
# alias la='l -a'
# alias lm='la --sort=modified'
# alias lt='la --sort=newest'
#################################### erdtree (tree viewer) ######################
alias t='erd -H -P -I -u si -y inverted'
######################################
whois() {
  # my finger version. Other useful command is 'whohas dhws012'
  if [ -n "$1" ];then
    getent passwd "$1" | choose -f '[:,]' 4
  else
    getent passwd | fzf
  fi
}
#####################################
alias notify-me='zenity --info --text="DONE" 2>/dev/null'
alias gr='tgrep'
###################################
zm() {
  cd -- "$(zoom ${1})"
}
alias wcurl='curl -# -O $1 --location --remote-name --remote-time --retry 10 --retry-max-time 10 --continue-at -'
############################################
alias .just='just -f {{justfile()}} -d .'
#############################################

# save last command in history to notes
alias sl='n $(fc -ln -1 | sed "s/^\s*//")'
# echo $(fc -ln -1 | sed "s/^\s*//") | cb to save last command to clipboard

alias :q='exit'
##############################################################
function h {
  # lookup location and content for commands
  pattern="$1" # todo, if empty, use xx !!!!
  res=$(type -f $pattern)
  kat -l sh <<< $res
  if rg -q "$pattern is an alias" <<< "$res"; then
    return
  fi
  if rg -q "$pattern is" <<<"$res"; then
    #filepath=$(echo $res | python3 -c "print(open(0).read().split()[-1])")
    filepath=$(echo $res | pypr "open(0).read().split()[-1]")
    echo "FILEPATH=$filepath"
    if rg -iq 'ASCII|Unicode' <<<$(file $filepath); then
      echo "################## FILE CONTENTS ###############################"
      kat -l sh $filepath
      # cd $(dirname $(pyextr LINUXPATH '$0' <<< $res))
    else
      link=$(readlink $filepath)
      if [[ $link != "" ]]; then
        echo "$pattern is a symbolic link to $link"
        ? $link
      else
        echo "THIS IS A BINARY FILE"
      fi
    fi
  else
    (
      cd ~/.local &>/dev/null
      definition_file=$(pyrg "'$pattern'+Either(WS,'(',')')[1:]+'{'" -l -w -g "my*.sh")
      echo "DEFINITION FILE=$definition_file"
      if [[ -n $definition_file ]]; then
        echo "The definition of this function can be found in ~/.local/$definition_file"
      fi
    )
    #cd - &>/dev/null
  fi
}
#alias h='?'
alias pysv='source ~ekhassan/bin/pysv'
#######################################
# c () { echo "$*" | bc -l; }
#alias c=zi
################## Easily search running processes ####################
#alias 'ps?'='ps ax | rg '
#################################################################
# colorised help
# This highlights the help output with colors so it looks nicer, works with most help outputs,
# as it highlights the first part which is the flag/argument in one color and the description in another color
hlp() {
   "$@" --help 2>&1 | bat --plain --language=help
 }
####################################################
# create a temporary scratch directory
alias scratch='cd "$(mktemp -dp "${HOME}/.scratch")" && pwd'
alias sf='date_dir=$(date +%Y-%m-%d) && mkdir -p ~/LOCAL_SSD/SCRATCH-DIR/$date_dir && cd ~/LOCAL_SSD/SCRATCH-DIR/$date_dir'
#alias python3.14='uv run --python 3.14 python'
alias cdpy='cd ~ekhassan/Documents/PYTHON_THINGS'
alias cdmy='cd ~ekhassan/Downloads/MY-GITHUB-REPOS'
#######################################################
function emacs-web {
  latest_html=$(ls -t *.html | head -n 1)
  emacs --eval "(eww-open-file \"$latest_html\")"
}
#########################################################
alias jimmy="$HOME/jimmy-env/bin/jimmy"
####################### https://github.com/stianhoiland/cd ########################################
export MY_FUZZY_PICKER=fzf
ESC=$'\x1b'
YELLOW="$ESC[33m"
RESET="$ESC[0m"
# sed -r: colorize last path component
COLORIZE="s,([^/]+/?)$,$YELLOW\1$RESET,"
# sed: strip ansi color sequences
DECOLORIZE="s,$ESC[[0-9;]*[mK],,g"
CDHISTFILE="$HOME/.cd_history"
cd() {
  command cd "$@" && printf '%s\n' "$PWD" >> "$CDHISTFILE"
}
c() {
  dir=$(
    tac "$CDHISTFILE" |
    awk '$0 != ENVIRON["PWD"] && !seen[$0]++' |
    sed -r "$COLORIZE" |
    fzf --ansi |
    sed "$DECOLORIZE"
  )
  [ "$dir" ] && cd "$dir"
}
alias hpull='git pull --recurse-submodules'
########################################################################
alias gg='git1'
alias swg='switch-gitconfig'
alias Hreport='Tcheck_tact -focus changes'
alias cdcm='cd /auto/local_build/dhws149/disk1/ekhassan/cm/'
#alias tpyc='python3.13 -m tpyc -x
alias tpy='/auto/home/ekhassan/LOCAL_SSD/DOWNLOADS/uv/python/cpython-3.13.7-linux-x86_64-gnu/bin/tpy'
alias tpyc='/auto/home/ekhassan/LOCAL_SSD/DOWNLOADS/uv/python/cpython-3.13.7-linux-x86_64-gnu/bin/tpyc'
