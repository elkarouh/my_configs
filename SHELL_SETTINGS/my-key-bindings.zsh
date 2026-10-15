
################################### MY ZSH KEY BINDINGS ##################################################
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line
bindkey  "^[[H"   beginning-of-line  # HOME key
bindkey  "^[[F"   end-of-line # END key
bindkey  "^[[3~"  delete-char
bindkey "^[[1;3C" forward-word # ALT-RIGHT key
bindkey "^[[1;3D" backward-word # ALT-LEFT key, use ALT-BACKSPACE to delete backwards, Ctrl-u to delete the line
bindkey "^[[5~" beginning-of-buffer-or-history  # Key Page Up
bindkey "^[[6~" end-of-buffer-or-history        # Key Page Down

### #use bm to bookmark current directory, use to foo to go to a directory containing 'foo'
#zle -N bm
#bindkey '^ ' bm  # Ctrl-Space to bookmark current dir | TO USE THIS CONSTRUCT, define a bm function above
#bindkey -s '^ ' 'bm\n'  # Ctrl-Space to bookmark current dir
# Ctrl-g to go to one of the bookmarked dirs
#bindkey -s '^g' 'to\n'

bindkey -s '^g' 'zi\n' # use zoyde to change directory


# RESUME JOB WITH C-z instead of typing 'fg'
_fg () { fg 2> /dev/null }
zle -N _fg
bindkey '^Z' _fg
##############################################################
source $HOME/.local/SHELL_SETTINGS/fzf_completion_widget.sh
#source $HOME/.local/SHELL_SETTINGS/improved_fzf_widgets.sh
#source $HOME/.local/SHELL_SETTINGS/deepseek_completion.sh
################################################
# ttr bound to C-k
# bindkey -s '^k' '^E^Uttr^M'
############################
## ctrl-x ctrl-n: edit last command output in neovim
# zmodload -i zsh/parameter
# vim-last-command-output() {
# LBUFFER+="vi $(eval $(tail -2 $HISTFILE | head -1 | cut -d';' -f2))"
#     zle accept-line
# }
# zle -N vim-last-command-output
# #bindkey '^x^n' vim-last-command-output
#
#source ~/.zsh/fzf-help/src/fzf-help.zsh
#zle -N fzf-help-widget
#bindkey "^k" fzf-help-widget
######################################### lf navigator ###########################################
#bindkey -s '^b' 'lfcd\n'  #  CALL lf with ctrl-b (b for browser !!!)
#lfcd () {
#    # `command` is needed in case `lfcd` is aliased to `lf`
#    cd "$(command lf -print-last-dir "$@")"
#}
########################################## yazi navigator #####################################################
#bindkey -s '^b' 'el\n'  #  CALL elio | yazi with ctrl-b (b for browser !!!)
bindkey -s '^b' 'yy\n'  #  CALL elio | yazi with ctrl-b (b for browser !!!)
bindkey -s '\ey' 'yy\n'  #  same, via Alt-y (ctrl-b is intercepted by Warp Terminal)
function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
alias y='yy'

# elio: cd into the directory elio was in when you quit
el() {
  typeset tmp cwd
  tmp=$(mktemp /tmp/elio-cwd.XXXXXX) || return
  EDITOR=sb VISUAL=sb command elio --cwd-file "$tmp" "$@"
  cwd=$(cat -- "$tmp")
  rm -f -- "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && cd -- "$cwd"
}
################################
copy-line-to-clipboard() {
  echo -n $BUFFER | xclip -selection clipboard
}
zle     -N   copy-line-to-clipboard
bindkey '\ew' copy-line-to-clipboard # Alt-w (same as emacs)

#######################################################################################
# Key bindings
# ------------
if [[ $- == *i* ]]; then
  #echo "Reading zsh key bindings"
  # CTRL-V - Paste the selected file path(s) into the command line
  __fsel() {
    local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
          -o -type f -print \
          -o -type d -print \
          -o -type l -print 2> /dev/null | cut -b3-"}"
    setopt localoptions pipefail 2> /dev/null
    eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
      echo -n "${(q)item} "
    done
    local ret=$?
  echo
  return $ret
  }

  __fzf_use_tmux__() {
    [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ]
  }

  __fzfcmd() {
    __fzf_use_tmux__ &&
      echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
  }

  fzf-file-widget() {
    LBUFFER="${LBUFFER}$(__fsel)"
    local ret=$?
    zle reset-prompt
    return $ret
  }
  zle     -N   fzf-file-widget
  # bindkey '^V' fzf-file-widget

  # Ensure precmds are run after cd
  fzf-redraw-prompt() {
    local precmd
    for precmd in $precmd_functions; do
      $precmd
    done
    zle reset-prompt
  }
  zle -N fzf-redraw-prompt

  # ALT-C - cd into the selected directory
  fzf-cd-widget() {
    local cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
          -o -type d -print 2> /dev/null | cut -b3-"}"
    setopt localoptions pipefail 2> /dev/null
    local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m)"
    if [[ -z "$dir" ]]; then
      zle redisplay
      return 0
    fi
    cd "$dir"
    local ret=$?
    zle fzf-redraw-prompt
    return $ret
  }
  zle     -N    fzf-cd-widget
  bindkey '\ec' fzf-cd-widget

  # CTRL-R - Paste the selected command from history into the command line
  fzf-history-widget() {
    local selected num
    setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
    selected=( $(fc -rl 1 |
                   FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
    local ret=$?
    if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
    fi
    zle reset-prompt
    return $ret
  }
  zle     -N   fzf-history-widget # Alt-c # Alt-c
  bindkey '^R' fzf-history-widget
  ###########################################
  fzf-preview-widget() {
    export FZF_DEFAULT_OPS=--preview-window=default
    ls | fzf -e --preview-window=default:right:80%
    export FZF_DEFAULT_OPS=--preview-window=hidden
    zle reset-prompt
  }
  zle -N fzf-preview-widget
  bindkey '^p' "fzf-preview-widget"
fi
