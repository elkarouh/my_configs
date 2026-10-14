#!/usr/bin/env ksh
export OLD_HOME=$HOME
export HOME=/home/ekhassan
#MACHINE=$(whohas $)
MACHINE=dhws149
export LD_LIBRARY_PATH=/home/ekhassan/opt/virtualgl/lib64:/home/ekhassan/opt/virtualgl/lib:$LD_LIBRARY_PATH
alias em='DISPLAY=${MACHINE}:1 emacs -l /home/ekhassan/e.el --eval="(progn (ghostel) (ghostel--send-string \"source ~ekhassan/a.sh\n\"))" &'
alias e='DISPLAY=${MACHINE}:1 emacs -l /home/ekhassan/e.el -l /home/ekhassan/EMACS_STUFF/themes/material-light-theme --eval="(progn (ghostel) (ghostel--send-string \"source ~ekhassan/a.sh\n\"))" &'
alias em10='DISPLAY=${MACHINE}:10 emacs -l /home/ekhassan/e.el --eval="(progn (ghostel) (ghostel--send-string \"source ~ekhassan/a.sh\n\"))" &'
alias e10='DISPLAY=${MACHINE}:10 emacs -l /home/ekhassan/e.el -l /home/ekhassan/EMACS_STUFF/themes/material-light-theme --eval="(progn (ghostel) (ghostel--send-string \"source ~ekhassan/a.sh\n\"))" &'
alias em99='DISPLAY=${MACHINE}:99 emacs -l /home/ekhassan/e.el --eval="(progn (ghostel) (ghostel--send-string \"source ~ekhassan/a.sh\n\"))" &'
alias e99='DISPLAY=${MACHINE}:99 emacs -l /home/ekhassan/e.el -l /home/ekhassan/EMACS_STUFF/themes/material-light-theme --eval="(progn (ghostel) (ghostel--send-string \"source ~ekhassan/a.sh\n\"))" &'
alias em63='DISPLAY=${MACHINE}:63 emacs -l /home/ekhassan/e.el --eval="(progn (ghostel) (ghostel--send-string \"source ~ekhassan/a.sh\n\"))" &'
alias e63='DISPLAY=${MACHINE}:63 emacs -l /home/ekhassan/e.el -l /home/ekhassan/EMACS_STUFF/themes/material-light-theme --eval="(progn (ghostel) (ghostel--send-string \"source ~ekhassan/a.sh\n\"))" &'
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
