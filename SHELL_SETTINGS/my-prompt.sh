#!/usr/bin/env ksh
###################################### PROMPT ########################
cccc() { [ $# == 0 ] && printf "\e[0m" || printf "$1" | sed 's/\(.\)/\1;/g;s/\([SDIUFNHT]\)/2\1/g;s/\([KRGYBMCW]\)/3\1/g;s/\([krgybmcw]\)/4\1/g;y/SDIUFNHTsdiufnhtKRGYBMCWkrgybmcw/12345789123457890123456701234567/;s/^\(.*\);$/\\e[\1m/g'; }
my_cecho() { echo -e "$(cccc $1)${2}\e[0m"; }
######################################################################
get_machine() {
  if [[ $HOSTNAME == $(whohas $LOGNAME) ]];then
    echo "$USER@$HOSTNAME: "
  else
    my_cecho fs "$USER@$HOSTNAME: "
  fi
}

get_cwd() {
  local cwd="${PWD//!/.}"
  cwd="${cwd/#$HOME/~}"
  cwd=$(echo "$cwd" | sed 's|^/auto/home/\([^/]*\)|~\1|')
  my_cecho sWb "[${cwd}]"
}
get_time() {
  time=$(TZ="Europe/Brussels" date +"%T")
  my_cecho sWr "[$time]"
}
get_view() {
  if [[ -d $DATA_FILES ]];then
    TACTDEV="TACT_DEV-> "
  fi
  if [[ -d ${VIEWSTORE} ]]; then
    VIEW=$(basename $VIEWSTORE)
    VIEW=${VIEW#$USER.}
    VIEW="${TACTDEV}${VIEW}"
    BUILD_TYPE="${CM_ENV_ID:5:2}"
    echo -e $(cccc sKw)${BUILD_TYPE}$(cccc) $(cccc sWg) "[${VIEW#$USER}]" $(cccc)
  else
    #if command -v tactdev &>/dev/null; then
    if [ ${CM_SYSTEM} != TOOL ]; then
      # we are in a context
      my_cecho sBw "[${CFMU_BUILD_TYPE} ${CM_SYSTEM} context $(echo $CONTEXT_CM_BASELINE | cut -d. -f 6)]"
    fi
  fi
}

get_proxy() {
  if [[ -n $https_proxy ]]; then
    my_cecho SBw PROXY
  fi
}

#########################################################################
find_git_branch() {
  # Based on: http://stackoverflow.com/a/13003854/170413
  local branch
  if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
    if [[ "$branch" == "HEAD" ]]; then
      branch='detached*'
    fi
    git_branch="($branch)"
  else
    git_branch=""
  fi
  echo $git_branch
}

find_git_dirty() {
  local status=$(git status --porcelain 2>/dev/null)
  if [[ "$status" != "" ]]; then
    git_dirty='*'
  else
    git_dirty=''
  fi
  echo "$git_dirty"
}
##########################################################################
get_prompt() {
  local branch=$(find_git_branch)
  local dirty=$(find_git_dirty)
  local git_info=""
  if [[ -n "$branch" ]]; then
    git_info=" $(my_cecho sYb "${branch}${dirty}")"
  fi
  printf "$(get_machine)$(get_cwd)${git_info}
$(get_time)$(get_view) $(get_proxy)$"
}

######################################################################
##  PS1='$(get_prompt)'  this is not necessary
