#!/usr/bin/env ksh
export OLD_HOME=$HOME
export HOME=/home/ekhassan
export LD_LIBRARY_PATH=/home/ekhassan/opt/virtualgl/lib64:/home/ekhassan/opt/virtualgl/lib:$LD_LIBRARY_PATH
alias em='DISPLAY=dhws149:1 emacs -l /home/ekhassan/e.el --eval="(progn (vterm) (vterm-send-string \"source ~ekhassan/a.sh\n\"))" &'
alias e='DISPLAY=dhws149:1 emacs -l /home/ekhassan/e.el -l /home/ekhassan/EMACS_STUFF/themes/material-light-theme --eval="(progn (vterm) (vterm-send-string \"source ~ekhassan/a.sh\n\"))" &'
alias em10='DISPLAY=dhws149:10 emacs -l /home/ekhassan/e.el --eval="(progn (vterm) (vterm-send-string \"source ~ekhassan/a.sh\n\"))" &'
alias e10='DISPLAY=dhws149:10 emacs -l /home/ekhassan/e.el -l /home/ekhassan/EMACS_STUFF/themes/material-light-theme --eval="(progn (vterm) (vterm-send-string \"source ~ekhassan/a.sh\n\"))" &'
alias em99='DISPLAY=dhws149:99 emacs -l /home/ekhassan/e.el --eval="(progn (vterm) (vterm-send-string \"source ~ekhassan/a.sh\n\"))" &'
alias e99='DISPLAY=dhws149:99 emacs -l /home/ekhassan/e.el -l /home/ekhassan/EMACS_STUFF/themes/material-light-theme --eval="(progn (vterm) (vterm-send-string \"source ~ekhassan/a.sh\n\"))" &'
alias em63='DISPLAY=dhws149:63 emacs -l /home/ekhassan/e.el --eval="(progn (vterm) (vterm-send-string \"source ~ekhassan/a.sh\n\"))" &'
alias e63='DISPLAY=dhws149:63 emacs -l /home/ekhassan/e.el -l /home/ekhassan/EMACS_STUFF/themes/material-light-theme --eval="(progn (vterm) (vterm-send-string \"source ~ekhassan/a.sh\n\"))" &'
################
source $HOME/.local/SHELL_SETTINGS/my-prompt.sh
#source $HOME/.local/my-aliases.sh
alias q='exit'
alias l='ls -lFArt --group-directories-first'
#alias l='lsd -FArtl --group-dirs first --date relative'
source $HOME/.local/SHELL_SETTINGS/my-key-bindings.zsh
source $HOME/.local/SHELL_SETTINGS/my-exports.sh
source $HOME/.local/SHELL_SETTINGS/my-ripgrep.sh
source $HOME/.local/SHELL_SETTINGS/my-fdfind.sh
source $HOME/.local/SHELL_SETTINGS/my-fzf-tricks.sh
source $HOME/.local/SHELL_SETTINGS/my-functions.sh
################
export HOME=$OLD_HOME


#unset HISTFILE; HISTSIZE=0
