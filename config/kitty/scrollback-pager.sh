#!/bin/bash
#export DISPLAY=:1.0
tmp=$(mktemp /tmp/kitty-scrollback-XXXXXX.txt)
cat > "$tmp"
sed -i -r "s/\x1B\[[0-9;]*[mK]//g" $tmp
#emacs -nw +$1 "$tmp"
emacsclient -t -a "emacs -nw" "$tmp" +$1    #THIS WORKS
#emacs -nw +$1 "$tmp"
