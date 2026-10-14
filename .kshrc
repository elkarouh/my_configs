#!/usr/bin/env ksh
export LD_LIBRARY_PATH=/home/ekhassan/opt/virtualgl/lib64:/home/ekhassan/opt/virtualgl/lib:$LD_LIBRARY_PATH
# Skip if not ksh or zsh (avoids errors when sourced by sh/bash)
[ -z "$KSH_VERSION" ] && [ -z "$ZSH_VERSION" ] && return 2>/dev/null
[ -t 0 ] || return
# Clean up inherited WEZTERM env vars in Zed terminal
# (KITTY_WINDOW_ID is intentionally kept — Zed supports Kitty Graphics Protocol)
if [ "$ZED_TERM" = "true" ]; then
  unset KITTY_PID KITTY_INSTALLATION_DIR
  unset WEZTERM WEZTERM_PANE WEZTERM_UNIX_SOCKET WEZTERM_EXECUTABLE WEZTERM_EXECUTABLE_DIR WEZTERM_CONFIG_DIR WEZTERM_CONFIG_FILE
fi
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
if [[ "$INSIDE_EMACS" = 'ghostel' ]]; then
  _ghostel_osc7() { printf '\e]7;file://%s%s\e\\' "$(hostname)" "$PWD"; }
  precmd() { _ghostel_osc7; }
  export EDITOR='emacsclient -n -c'
elif [[ "$INSIDE_EMACS" = 'vterm' || "$INSIDE_EMACS" = *eat ]]; then
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
export PATH=/auto/home/ekhassan/bin/eurocontrol/BUILD_MASTER:$PATH
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

################################# NPM GLOBAL ##################################
export PATH="$PATH:/auto/local_build/dhws149/disk1/DOWNLOADS/node-v22.16.0-linux-x64/bin"

################################# OLLAMA ######################################
#pgrep -x ollama >/dev/null || ollama serve &>/dev/null &
############################## AICOE #############################################
export ANTHROPIC_FOUNDRY_BASE_URL=https://nmlab-ai-gate.azure-api.net/ai/anthropic
export CLAUDE_CODE_USE_FOUNDRY="1"
######################################################################################
#export PATH="/auto/local_build/dhws149/disk1/DOWNLOADS/GITHUB-REPOS/mojo:$PATH"
#export PATH="/auto/local_build/dhws149/disk1/DOWNLOADS/uv/python/cpython-3.14.3-linux-x86_64-gnu/bin:$PATH"

# Codon compiler path (added by install script)
# Codon compiler path (added by install script)
#export PATH=$HOME/.codon/bin:$PATH
#export PATH=/auto/home/ekhassan/.codon/bin:$PATH
###########################################################
# Aliases are only expanded when zsh first reads a command line, and only for the first word.
# Inside the function, "$@" is just a list of words, so zsh never looks them up as aliases.
# The fix is to run the arguments through eval, which makes zsh read them again as a command line,
# alias expansion included:
run-in-emacs() {
  emacs --insert =(eval "$*") --eval '(progn
    (require (quote ansi-color))
    (fundamental-mode)
    (ansi-color-apply-on-region (point-min) (point-max))
    (goto-char (point-min)))'
}
#########################################################
# export PERL5LIB=$HOME/bin/eurocontrol/pm:$PERL5LIB
export NM_REPOSITORY_ALTERNATE='/auto/local_build/dhws143/disk1/pphilbey/nmhist/NM'
#########################################################
# removes user path before launching a command (useful for builds !!!)
# usage: e.g. "without_user_path Tbuild ..."
without_user_path() {
    typeset newpath dir
    typeset oldIFS=${IFS}
    IFS=:
    for dir in ${PATH}; do
        [[ "${dir}" == *"/${USER}/"* ]] && continue
        [[ -n "${newpath}" ]] && newpath="${newpath}:"
        newpath="${newpath}${dir}"
    done
    IFS=${oldIFS}
    PATH=${newpath} "$@"
}
alias pbeta='eval $(~pphilbey/bin/install_beta_test)'
