# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export PMAKE_ADD_OPTIONS=-L
export MANPATH=$MANPATH:$HOME/.local/share/man
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/rc
#export CM_ENV_ID=G!27.IP.L8 # WHAT ABOUT OPTIMISED MODE???
export MY_TACT_SOURCES="/cm/build13${TACT_CORE_HOME//.2/!2}"
export proxy_username=$HOME
#export http_proxy=http://$HOME:xxxxxxx@pac.eurocontrol.int:9512
#export https_proxy=http://$HOME:xxxxxxx@pac.eurocontrol.int:9512
#export PATH=$HOME/Downloads/Perl/site/bin:\/Downloads/Perl/bin:$PATH
export XDG_CONFIG_HOME=$HOME/.config/ # neovim uses this
###########################################################################################################
#export EDITOR=nvim
#export -f rtd
#export CDPATH=\:$HOME/software:$HOME/software/ruby:$HOME/software/rails:$HOME/software/youtube

# colorize man pages with bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# e.g. man 2 select
export REP_PAGER=delta
export DELTA_FEATURES=+side-by-side

export GOPATH=$HOME//LOCAL_HARD_DISK/go

export LC_ALL=en_US.utf-8
export LANG=en_US.utf-8

export DOTBARE_DIR="$HOME/.cfg"
export DOTBARE_TREE="$HOME"

export FZF_DEFAULT_OPTS='--height 100% --layout=reverse --border --exact'
export FZF_TMUX_HEIGHT='40%' # default height is 40%
export FZF_DEFAULT_COMMAND="fd --hidden"
#export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_ALT_C_COMMAND="fd -H -td -d3"
#export FZF_ALT_C_COMMAND="rg --sort-files --files --null 2> /dev/null | xargs -0 dirname | uniq".

export FZF_MARKER_CONF_DIR=$HOME/.config/marker
export FZF_MARKER_COMMAND_COLOR='\x1b[38;5;255m'
export FZF_MARKER_COMMENT_COLOR='\x1b[38;5;8m'
export FZF_MARKER_MAIN_KEY='\C-@'
export FZF_MARKER_PLACEHOLDER_KEY='\C-v'
##########################
#export BUN_INSTALL="\/.bun"
#export PATH="$BUN_INSTALL/bin:$PATH"
export CODON_PYTHON=$HOME/LOCAL_SSD/Python-3.11.1/lib/libpython3.11.so
###################################################
# export PYTHONBREAKPOINT="pudb.set_trace"
export PYTHONPYCACHEPREFIX=$HOME/.cache/cpython/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.local/Python-3.11.1/lib
#export PYTHONSTARTUP="$HOME/.local/ptpython_custom.py"
#export PYTHONPATH=$HOME/Downloads/miniconda3/bin
#export PYTHONPATH=$HOME/Downloads/anaconda3/bin
#export PYTHONSTARTUP=$HOME/Downloads/miniconda3/lib/python3.8/site-packages/ptpython_custom.py
##################################### PATH ###############################################################
export PATH=$PYTHONPATH:$PATH
export PATH=$HOME/.node/bin:$PATH
export PATH=$HOME/.deno/bin:$PATH
export PATH=$HOME/.local/Python-3.11.1/bin:$PATH
# export PATH=$HOME/.vscode/extensions/adacore.ada-24.0.5/x64/linux:$PATH
export PATH=$HOME/bin:$HOME/.local/bin:$HOME/bin/eurocontrol:$HOME/.cargo/bin:$PATH
#echopath |  rg codon
#export PATH=$PATH:$HOME/LOCAL_HARD_DISK/bin
#export PATH=$PATH:$HOME/LOCAL_HARD_DISK/nim/bin
#export PATH=$PATH:$HOME/.nimble/bin
export PATH=$PATH:$HOME/.codon/bin
export PATH=$PATH:$HOME/LOCAL_SSD/go/bin
export BASH_IDE_LOG_LEVEL=error
#LD_LIBRARY_PATH=~/Downloads/lib64:$LD_LIBRARY_PATH $@
################################## GTK4 ###################################################
export GTK4_HOME=/auto/home/ekhassan/Downloads/gtk4-devel-3.94.0-1.el8.x86_64/gtk4
# Compiler include paths
export CFLAGS="-I$GTK4_HOME/include -I$GTK4_HOME/include/gtk-4.0 $CFLAGS"
# Linker paths
export LDFLAGS="-L$GTK4_HOME/lib64 -Wl,-rpath,$GTK4_HOME/lib64 $LDFLAGS"
# pkg-config
export PKG_CONFIG_PATH="$GTK4_HOME/lib64/pkgconfig:$GTK4_HOME/share/pkgconfig:$PKG_CONFIG_PATH"
# Runtime library path (for running compiled binaries)
export LD_LIBRARY_PATH="$GTK4_HOME/lib64:$LD_LIBRARY_PATH"
################################## GRAPHENE ##############################
export GRAPHENE_HOME=/auto/home/ekhassan/Downloads/graphene-devel-1.8.6-1.el8.x86_64/graphene
export CFLAGS="-I$GRAPHENE_HOME/include -I$GRAPHENE_HOME/include/graphene-1.0 $CFLAGS"
export LDFLAGS="-L$GRAPHENE_HOME/lib64 -Wl,-rpath,$GRAPHENE_HOME/lib64 $LDFLAGS"
export PKG_CONFIG_PATH="$GRAPHENE_HOME/lib64/pkgconfig:$GRAPHENE_HOME/share/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="$GRAPHENE_HOME/lib64:$LD_LIBRARY_PATH"
