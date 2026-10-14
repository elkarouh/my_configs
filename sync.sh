#!/usr/bin/ksh
#
# sync.sh - synchronize between repo and live locations
#
# Usage:
#   ./sync.sh pull   - copy live files INTO the repo (before git commit)
#   ./sync.sh push   - copy repo files OUT to live locations (after git pull)

REPO=$(dirname "$(readlink -f "$0")")

usage() {
    echo "Usage: $0 pull|push"
    echo "  pull  copy live configs into the repo"
    echo "  push  copy repo configs out to live locations"
    exit 1
}

[[ $# -ne 1 ]] && usage
DIRECTION=$1
[[ $DIRECTION != pull && $DIRECTION != push ]] && usage

# Map: repo_path -> live_path
# Each entry is "repo_relative|live_absolute"
MAPPINGS="
.kshrc|$HOME/.kshrc
SHELL_SETTINGS|$HOME/LOCAL/SHELL_SETTINGS
CONFIGS|$HOME/LOCAL/CONFIGS
config/alacritty|$HOME/.config/alacritty
config/git|$HOME/.config/git
config/helix/config.toml|$HOME/.config/helix/config.toml
config/helix/languages.toml|$HOME/.config/helix/languages.toml
config/kitty/kitty.conf|$HOME/.config/kitty/kitty.conf
config/kitty/current-theme.conf|$HOME/.config/kitty/current-theme.conf
config/kitty/open-actions.conf|$HOME/.config/kitty/open-actions.conf
config/kitty/pass_keys.py|$HOME/.config/kitty/pass_keys.py
config/kitty/scrollback-pager.sh|$HOME/.config/kitty/scrollback-pager.sh
config/lazygit/config.yml|$HOME/.config/lazygit/config.yml
config/opencode|$HOME/.config/opencode
config/starship.toml|$HOME/.config/starship.toml
config/wezterm|$HOME/.config/wezterm
config/yazi/init.lua|$HOME/.config/yazi/init.lua
config/yazi/keymap.toml|$HOME/.config/yazi/keymap.toml
config/yazi/package.toml|$HOME/.config/yazi/package.toml
config/yazi/theme.toml|$HOME/.config/yazi/theme.toml
config/yazi/yazi.toml|$HOME/.config/yazi/yazi.toml
config/yazi/flavors|$HOME/.config/yazi/flavors
config/yazi/plugins/augment-command.yazi|$HOME/.config/yazi/plugins/augment-command.yazi
config/yazi/plugins/chmod.yazi|$HOME/.config/yazi/plugins/chmod.yazi
config/yazi/plugins/command.yazi|$HOME/.config/yazi/plugins/command.yazi
config/yazi/plugins/custom-shell.yazi|$HOME/.config/yazi/plugins/custom-shell.yazi
config/yazi/plugins/dual-pane.yazi|$HOME/.config/yazi/plugins/dual-pane.yazi
config/yazi/plugins/full-border.yazi|$HOME/.config/yazi/plugins/full-border.yazi
config/yazi/plugins/glow.yazi|$HOME/.config/yazi/plugins/glow.yazi
config/yazi/plugins/jump-to-char.yazi|$HOME/.config/yazi/plugins/jump-to-char.yazi
config/yazi/plugins/max-preview.yazi|$HOME/.config/yazi/plugins/max-preview.yazi
config/yazi/plugins/office.yazi|$HOME/.config/yazi/plugins/office.yazi
config/yazi/plugins/open-with-cmd.yazi|$HOME/.config/yazi/plugins/open-with-cmd.yazi
config/yazi/plugins/piper.yazi|$HOME/.config/yazi/plugins/piper.yazi
config/yazi/plugins/simple-tag.yazi|$HOME/.config/yazi/plugins/simple-tag.yazi
config/yazi/plugins/smart-filter.yazi|$HOME/.config/yazi/plugins/smart-filter.yazi
config/yazi/plugins/toggle-pane.yazi|$HOME/.config/yazi/plugins/toggle-pane.yazi
config/yazi/plugins/zoom.yazi|$HOME/.config/yazi/plugins/zoom.yazi
config/zed/keymap.json|$HOME/.config/zed/keymap.json
config/zed/settings.json|$HOME/.config/zed/settings.json
config/sublime-text/Packages/User/Default (Linux).sublime-keymap|$HOME/.config/sublime-text/Packages/User/Default (Linux).sublime-keymap
config/sublime-text/Packages/ClaudeCode|$HOME/.config/sublime-text/Packages/ClaudeCode
config/sublime-text/Packages/Terminus|$HOME/.config/sublime-text/Packages/Terminus
config/warp-oss/settings.toml|$HOME/.config/warp-oss/settings.toml
config/warp-oss/user_preferences.json|$HOME/.config/warp-oss/user_preferences.json
"

sync_item() {
    local repo_rel=$1
    local live=$2
    local repo="$REPO/$repo_rel"

    if [[ $DIRECTION == pull ]]; then
        local src=$live dst=$repo
    else
        echo "ARE YOU SURE?"
        exit
        local src=$repo dst=$live
    fi

    if [[ ! -e $src ]]; then
        echo "  SKIP (not found): $src"
        return
    fi

    if [[ -d $src ]]; then
        mkdir -p "$dst"
        rsync -a --exclude='.git' "$src/" "$dst/"
        echo "  DIR  $src -> $dst"
    else
        mkdir -p "$(dirname "$dst")"
        cp -f "$src" "$dst"
        echo "  FILE $src -> $dst"
    fi
}

sanitize_warp_prefs() {
    local f="$REPO/config/warp-oss/user_preferences.json"
    [[ ! -f $f ]] && return
    if ! command -v jq >/dev/null 2>&1; then
        echo "  WARN: jq not found, skipping warp prefs sanitize"
        return
    fi
    local tmp="$f.tmp"
    jq 'del(.prefs.ExperimentId, .prefs.MCPExecutionPath)' "$f" > "$tmp" && mv "$tmp" "$f"
    echo "  SANITIZED $f (stripped ExperimentId, MCPExecutionPath)"
}

echo "=== sync $DIRECTION ==="
echo "$MAPPINGS" | while IFS='|' read repo_rel live; do
    [[ -z $repo_rel ]] && continue
    sync_item "$repo_rel" "$live"
done
[[ $DIRECTION == pull ]] && sanitize_warp_prefs
echo "=== done ==="
