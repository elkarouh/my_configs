#!/usr/bin/env ksh
export LD_LIBRARY_PATH=/home/ekhassan/opt/virtualgl/lib64:/home/ekhassan/opt/virtualgl/lib:$LD_LIBRARY_PATH
[ -t 0 ] || return
###################################### THE BELOW IS FROM wao's .kshrc #########################################
set -o emacs
#/usr/bin/xmodmap -e "keycode 66 ="
export HOME=${HOME%/}
# For xterm like terminals (including xfce4-terminal),
# set the terminal window/tab title to PWD at prompt.
# Also, when a command runs, shows the command first word ($1 of preexec)
if [[ -o interactive && "$TERM" =~ xterm ]]
then
  precmd() { print -Pn "\e]0;$(basename $(pwd))\a"  }
  preexec() { print -Pn "\e]0; $(basename $(pwd)) ${1%% *}\a" }
fi
###############################################################
###################################### THE BELOW IS MINE ######################################################
if [[ "$INSIDE_EMACS" = 'vterm' || "$INSIDE_EMACS" = *eat ]]
then
  #source $HOME/.local/SHELL_SETTINGS/my-prompt.sh
  #source $HOME/.local/SHELL_SETTINGS/my-shell-settings.sh
  export EDITOR='vterm_cmd find-file'
  #resize &>/dev/null
else
  export EDITOR='emacsclient -n -c'
fi
export ALTERNATE_EDITOR="" # for emacsclient
# if command -v hx >/dev/null; then
#   export EDITOR=hx
# else
#   export EDITOR=vim
# fi
export VISUAL=$EDITOR  # C-x C-e on the command line will use $VISUAL to edit the current command
export COLORTERN=truecolor
###############################################################################################################
setopt HIST_IGNORE_SPACE # preprending a space will not put it in history (interesting for passwords)
setopt HIST_IGNORE_ALL_DUPS  # Delete old recorded entry if new entry is a duplicate.
HISTORY_IGNORE="(l|cd*|sv|lv|spf|hi*)"
export ZSH_DISABLE_COMPFIX=true #
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
##################################################################
# THESE ARE MY PRIVATE ALIASES: aliases shouldn't override ANY standard commands !!!!!!
source $HOME/.local/SHELL_SETTINGS/my-eurocontrol-utils.sh
source $HOME/.local/SHELL_SETTINGS/my-aliases.sh
source $HOME/.local/SHELL_SETTINGS/lscolors.sh # add better colors to stock ls
source $HOME/bin/zf.sh # improved zoxide that uses fd

# Avoid doing s
source $HOME/.local/SHELL_SETTINGS/my-prompt.sh
source $HOME/.local/SHELL_SETTINGS/my-shell-settings.sh
##############################################
alias code='vs -n'
alias code_e='vs -n --user-data-dir $HOME/.config/Code-e /cm/vobs/pst1/ELD /cm/vobs/pst1/TOOL'
alias code_i='vs -n --user-data-dir $HOME/.config/Code-i /cm/vobs/ifps1/IFPS /auto/local_build/dhws149/disk1/cm/LATEST/ELD /auto/local_build/dhws149/disk1/cm/LATEST/TOOL'
alias code_t='vs -n --user-data-dir $HOME/.config/Code-t /cm/vobs/tact1/TACT /auto/local_build/dhws149/disk1/cm/LATEST/ELD /auto/local_build/dhws149/disk1/cm/LATEST/TOOL'
export GNAT8=/cm/build9/cm/ot/TOOL/G!31.L8/gnatpro-24.0w-20230604-L8
export PATH=${GNAT8}/bin:$PATH

# Codon compiler path (added by install script)
export PATH=$HOME/.codon/bin:$PATH
##################################### NIM #######################################
export PATH=$HOME/.nimble/bin:$PATH
################################### UV ##########################################
#eval "$(direnv hook zsh)"
################################# ELIA ##########################################
export REDHAT_VERSION=8
export BUILD_TAG=G!31.IP.L${REDHAT_VERSION}
source "/cm/ot/TOOL/COMMON_UTILS.LATEST/build_${BUILD_TAG}/exe/cd_by_pattern_to_build_directory"
alias cbd=cd_pattern
###############################################################################
