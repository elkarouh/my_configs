
alias hls='Clsco'
alias hsb='Cshow_branches -f -noc'
alias latest_tact_baseline='ls -ld /cm/ot/TACT/TACT_CONFIG.LATEST | cut -d. -f6'
alias latest_eld_baseline='ls -ld /cm/ot/ELD/ELD_CONFIG.LATEST | cut -d. -f6'
alias cv='cleartool pwv | tail -1 | cut -f 3 -d " "'  # show current view
alias curr_baseline='Clsview | grep `cv` | cut -d. -f 7  | cut -d" " -f1' # baseline for the current view !
alias mtdn='make_tactdev_novnc'
alias ml='source ~ekhassan/bin/make_links'
alias cdr='cd /cm/ot/TACT/test_reports'
alias minx='| tr '\n' '\0' | xargs -0 -t -p -I {}'  # allows 'Cshow_branches minx Ccheckout {}'
###################################
alias broum='killnet > s.out 2>&1;Start_TACT >> s.out 2>&1 &'
alias monobroum='mono_process -i tacot.init.el  > $SVLOGS/mono.out 2>&1 & ; echo output redirected look at it with tail -f $SVLOGS/mono.out'
function CT.broken {
  [ $# -ne 0 ] && cecho Wy "'cdlog' to go to the logs directory"
  BASELINE=$([ $# -eq 0 ] && echo LATEST || echo 30.0.0.$1)
  Ccontext -b TACT.TACT_CONFIG.$BASELINE -e G!31.IP.L8
}
alias CT="Ccontext -b TACT.TACT_CONFIG.LATEST -e G!31.IP.L8"
alias CTO="Ccontext -b TACT.TACT_CONFIG.LATEST -e G!31.OP.L8"
alias CFMU='Ccontext -b CFMUTEST.CFMUTEST_CONFIG.LATEST'
function CTT {
  BASELINE=$([ $# -eq 0 ] && echo LATEST || echo 30.0.0.$1)
  Ccontext -b TACT.TACT_CONFIG.$BASELINE 
}

####################################################################
show_builds() {
  fdl -L --max-depth 1 -td $1 /cm/ot/TACT/
}
function see_Tlogs() {
  function find_Tlogs {
    cd /cm/ot/TACT
    USER=${1:-EKHASSAN} # DEFAULT PARAMETER IS EKHASSAN
    USER=$(python -c "print ('${USER}'.upper())")
    fd -td -L -d1 -0 -p ${USER} | xargs -0 ls -td | while read dir; do
      fd -e log Tlog-in $dir
    done
  }
  function find_new_failing_tests {
    file=$1
    echo $file
    #start_line_number=$(echo "a=\"$(rg -n 'New tests failing' $file)\".split(':');print(a[0])" | python)
    start_line_number=$(python -c "a=\"$(rg -n 'New tests failing' $file)\".split(':');print(a[0])")
    echo "start linenumber=$start_line_number"
    end_line_number=$(rg -n "Tests still failing" $file | cut -d ':' -f 1)
    awk "NF && NR >= $start_line_number && NR < $end_line_number" $file | rg '\w*\.el\b'
    #echo "emacs +$start_line_number \"$file\"" | xclip -selection clipboard
    echo "emacs +$start_line_number \"$file\"" | write2prompt
  }
  find_new_failing_tests "/cm/ot/TACT/$(find_Tlogs "$1" | fzf -e)"
}

function htactdev {
  export TIME_STAMP=$(timestamp -digital)
  export TACTDEV_HOME=/cm/local_build/TACTDEV_HOME/$(whoami)/replay_dir.$(hostname).${TIME_STAMP}
  set -x
  mkdir -p ${TACTDEV_HOME}
  set +x
  command+=(tactdev -nr_counters 1 -set_home $TACTDEV_HOME)
  # command+=(-separate_envs)
  # command+=(-use_real_ftps)
  # command+=(-ops_like)
  # command+=(-start_update_db_statistics_job)
  # command+=(-no_vnc)
  cecho Wb "Running ${command[@]}"
  pause_until_key_pressed
  set -x; "${command[@]}"; set +x
}
############################## SSH shortcuts (from wao) #############################
alias monobroum='mono_process -i tacot.init.el  > $SVLOGS/mono.out 2>&1 & ; echo output redirected look at it with tail -f $SVLOGS/mono.out'
alias pre='ssh ctacpre@ptacpre'
alias wpr7='ssh ctacpr7@dhws149'
alias prb='ssh -X ctacprb@ptacprb'
alias wprb='ssh -X ctacprb@dhws149'
alias prg='ssh -X ctacprg@ptacprg'
alias wprg='ssh -X ctacprg@dhws149'
alias prd='ssh -X ctacprd@ptacprd'
alias wprd='ssh -X ctacprd@dhws149'
alias prq='ssh -X ctacprq@ptacprq'
alias wprq='ssh -X ctacprq@dhws149'
alias predi='ssh -X cprepre@pprepre'
alias niemapc='ssh -X cssoop1@dhssod02'
# niemapc reports are in cd /cm/nasdata/TACT/POST_OPS/reports/
#
#############################################################################
# THIS FILE CONTAINS cd-related FUNCTIONS SO IT NEEDS TO BE SOURCED
cdw() { # cd to home dir of a workspace when in tactdev env or in a workspace
  cd ${CMA_WORKSPACE_NM_REPOSITORY_DIRECTORY}
  #cd ${CMA_WORKSPACE_DATA_DIRECTORY}
}

cdww() { # cd to working dir
  cd ${CMA_WORKSPACE_DATA_DIRECTORY}/work/Pmake
}

cdop() {
  if [[ $PWD == *IP* ]]; then
    new_pwd="${PWD%IP*}OP${PWD##*IP}"
    cd "$new_pwd"
  fi
}

cdip() {
  #cd ${PWD//OP/IP}
  if [[ $PWD == *OP* ]]; then
    new_pwd="${PWD%OP*}IP${PWD##*OP}"
    cd "$new_pwd"
  fi
}

#setopt bareglobqual nullglob noksh_glob   # needed because of ksh emulation

has_build_dir() {
    local d
    for d in "$1"/build*; do
        [[ -d $d ]] && return 0
    done
    return 1
}

find_build_dir_for_view() {
    local view_name=${1-$CMA_WORKSPACE}
    local VIEW_NAME=${(U)view_name}   # short view name in uppercase
    local submodule log_dir_root

    for submodule in $(cat ~/bin/CFMU_SUBMODULES.txt); do
        submodule=${submodule//./\/}
        log_dir_root="/cm/ot/${submodule}.${VIEW_NAME}"
        if has_build_dir "$log_dir_root"; then
            echo "${log_dir_root}"
            return 0
        fi
    done

    echo "NO BUILD FOUND" >&2
    return 1
}

cdb() {
  if [[ ! -v CONTEXT_CM_BASELINE ]]; then
    echo >&2 "NOT IN A CONTEXT !!! exiting"
    return 1
  fi
  if [[ ! -v CMA_WORKSPACE ]]; then
    cd $TACT_TACT_CONFIG_HOME/saved_logs
  else
    log_dir_root=$(find_build_dir_for_view $CMA_WORKSPACE) || exit 1
    log_dir_IP=${log_dir_root}/build_G!31.IP.L8/saved_logs
    if [[ ! -d $log_dir_IP ]]; then
        log_dir_IP="${log_dir_root}/build_G!31.IP.L8/"
    fi
    echo "===============> ${log_dir_IP}"
    case $CFMU_BUILD_TYPE in
      IP)
        echo IP_BUILD
        if [[ -d $log_dir_IP ]]; then
          cd $log_dir_IP
        else
          cd "${log_dir_IP%IP*}OP${log_dir_IP##*IP}" || exit
        fi
        ;;
      OP)
        echo OP_BUILD
        cd "${log_dir_IP%IP*}OP${log_dir_IP##*IP}" || exit
        ;;
      *)
        echo >&2 "No build available"
        return 1
        ;;
    esac
    dhelp
  fi
}

cdlog() {
  # when no parameter is given, goto the default 'in' log directory
  # otherwise goes to the alternate ('mono' or 'assert') log directory
  cdb &>/dev/null
  build_type=$1
  case $CFMU_BUILD_TYPE in
    IP)
      if [[ $build_type = "" ]]; then                                 # no params
        logdir=$(fd --max-results 1 -td -p 'logging-in.*LOGS_others$') # IP/in
        echo "IP/in $logdir"
      else                                                            # any parameter
        logdir=$(fd --max-results 1 -td -p 'logging-mono.*LOGS_mono$') # IP/mono
        echo "IP/mono $logdir"
      fi
      ;;
    OP)
      if [[ $build_type = "" ]]; then                                 # no params
        logdir=$(fd --max-results 1 -td -p 'logging-in.*LOGS_others$') # OP/in
        echo "OP/in $logdir"
      else                                                                # any params
        logdir=$(fd --max-results 1 -td -p 'logging-assert.*LOGS_others$') # OP/assert
        echo "OP/assert $logdir"
      fi
      ;;
  esac

  if [[ $logdir != "" ]]; then
    cd $logdir
  else
    echo "logs directory not found"
  fi
}

cdreplay() {
  cdb &>/dev/null
  cdop
  cd replay_dir*
}

cdint() { # goto TACT integration directory (TACT CONTEXT needed, do 'CT rel_number')
        # we need to look at the integration logs of the previous day !!!
        cd ~tactadm/integrate.log/from_$(pypr "(G(DIGITS[1:3]).preceded_by('.')+EOL).sub(lambda m:str(int(m.group())-1),'$CONTEXT_CM_BASELINE')")
        #cd ~ifpsadm/integrate.log/from_${CONTEXT_CM_BASELINE}
}
cdint2() { # goto ELD integration directory CAVEAT should we be in ELD context????
        #cd ~eldadm/integrate.log/from_$(echo $CONTEXT_CM_BASELINE | python3 -c "s,r=open(0).read().rsplit('.',1);print(f'{s}.{int(r)-1}')")
        cd ~eldadm/integrate.log/from_$(python3 -c "s,r='$CONTEXT_CM_BASELINE'.rsplit('.',1);print(f'{s}.{int(r)-1}')")
}
cdprev() { # goto the directory in the previous BASELINE
        # /cm/ot/TACT/TACT_CONFIG.27.0.0.199/build_G.29.IP.L8/saved_logs/tacot_corico_2022.12.13_22.02.13/work/logging-in/LOGS_other
        # should become
        # /cm/ot/TACT/TACT_CONFIG.27.0.0.198/build_G.29.IP.L8/saved_logs/tacot_corico.LATEST/work/logging-in/LOGS_other
        release_number_re=$(pypr "(DIGITS[1:3]).preceded_by(DOT).followed_by('/build')")
        corico_date_re=$(pypr "'tacot_corico_' + OneOrMore(DIGIT|'._')")
        cur_dir=$PWD
        # echo $cur_dir
        new_dir=$(python3 -c "import re;print(re.sub(r'$release_number_re',lambda m:f'{int(m.group(0))-1:0>d}','${cur_dir}'))")
        # echo $new_dir
        new_dir2=$(python3 -c "import re;print(re.sub(r'$corico_date_re','tacot_corico.LATEST','${new_dir}'))")
        # echo $new_dir2
        cd $new_dir2
}
cdnext() { # goto the directory in the next BASELINE
        # /cm/ot/TACT/TACT_CONFIG.27.0.0.199/build_G.29.IP.L8/saved_logs/tacot_corico_2022.12.13_22.02.13/work/logging-in/LOGS_other
        # should become
        # /cm/ot/TACT/TACT_CONFIG.27.0.0.200/build_G.29.IP.L8/saved_logs/tacot_corico.LATEST/work/logging-in/LOGS_other
        release_number_re=$(pypr "(DIGITS[1:3]).preceded_by(DOT).followed_by('/build')")
        corico_date_re=$(pypr "'tacot_corico_' + OneOrMore(DIGIT|'._')")
        cur_dir=$PWD
        # echo $cur_dir
        new_dir=$(python3 -c "import re;print(re.sub(r'$release_number_re',lambda m:f'{int(m.group(0))+1:0>d}','${cur_dir}'))")
        # echo $new_dir
        new_dir2=$(python3 -c "import re;print(re.sub(r'$corico_date_re','tacot_corico.LATEST','${new_dir}'))")
        # echo $new_dir2
        cd $new_dir2
}

cddat() {
  cdb &>/dev/null
  if datadir=$(fd -td -p 'tacot_corico.*data_files$') && [[ $datadir != "" ]]; then
    cd $datadir
  else
    echo >&2 "data_files directory not found"
    exit 1
  fi
}
#####################################################################

#############################################################
rtd() { # REMOVE A TACTDEV
  # view=$(cleartool pwv | tail -1 | cut -f 3 -d " ")
  # view=$(cleartool pwv | pypr 'open(0).read().split()[-1]')
  # VIEW=$(cleartool pwv | pypr 'open(0).read().split()[-1].upper()')
  # view_name=$(echo $view  | cut -f 2 -d.) # short view name
  view=$(cleartool pwv -short)
  VIEW_NAME=$(echo $view | tr a-z A-Z) # short view name in uppercase
  # if [[ $view == "ekhassan"* ]]
  if [[ $view != '** NONE **' ]]
  then
    command=$(fd -p "${VIEW_NAME}/tactdev_remove" /cm/local_build/TACTDEV_HOME/ekhassan | head -1) # show tactdev to remove
    if (( ${#command} == 0 ))
    then
      command=$(fd tactdev_remove$ /cm/local_build | rg -N -I --no-heading --color=never  $view_name | head -1) # show tactdev to remove
    fi;
    print -z $command
  else
    echo NOT WITHIN A VIEW
    fd -tx remove$ /cm/local_build/ekhassan  # show all tactdev's to remove
    fi;
}


vb() { # set up a view build within a view context !!!
    view_name=$CMA_WORKSPACE
    VIEW_NAME=${(U)view_name} # short view name in uppercase
    Ccontext -b TACT.TACT_CONFIG.$VIEW_NAME
}

humanize() {
  # humanize the template files that failed
  pyrg "'(ediff-files'+Group('FILES',OneOrMore(AnythingBut(')')))+')'" -r '$FILES' `fd -p 'other.*tacot1_out_01'` | while read line; do hek_templ2human.py $(python3 -c """import re;print(' '.join(re.split(r'(?<=(?:templ|.\.ssm|l\.gif))\b(?!\.)',$line)))""") ;done
  pyrg "'(ediff-files'+Group('FILES',OneOrMore(AnythingBut(')')))+')'" -r '$FILES' `fd -p 'other.*tacot1_out_01'` | while read line; do echo $(python3 -c """import re;print(re.split(r'(?<=(?:templ|.\.ssm|l\.gif))\b(?!\.)',$line)[0])""") ;done
  # copy templates and corresponding .out files into current dir
  for file in $(pyrg "'(ediff-files'+Group('FILES',OneOrMore(AnyBut(')')))+')'" -r '$FILES' `fd -p 'other.*tacot1_out_01'`)
  do
    #cp $(echo $file | python3 -c "print(open(0).read()[1:-2])") .
    # cp $(python3 -c """print($file)""") .
    cp $file .
  done
  #echo pyrg "'('+rxe('ediff-files')+Group('FILES',OneOrMore(AnythingBut(')')))+')'" -r '$FILES' `fd -p 'other.*tacot1_out_01'` | while read line; do hek_templ2human.py $line;done
}
Tdev() {
   cdb 1>/dev/null && $(fd -tx tactdev_context | python3 -c "print(min((l for l in open(0)),key=len))")
}
kb() { # kill build
  Tdev
  Tkill # Doesn't work, context has changed
}
mb() { # monitor build
  Tdev
  Tstatus # Doesn't work, context has changed
  Terr -m # Doesn't work, context has changed
  }

svb() { # set view build
    Csetup -e G!31.IP.L8 -view_build_setup $(choose_view)
}

svo25() { # set view for an optimized build
  export CM_ENV_ID=G!25.OP.L8
  #Csetup -e ${CM_ENV_ID/IP/OP} ${view}
  if [ $# -eq 0 ]
  then
    Csetup -e G!25.OP.L8 $(choose_view)
  else
    Csetup -e G!25.OP.L8 -b TACT.TACT_CONFIG.26.0.0.$1 $(choose_view)
  fi
}


###########################################################################################################
# ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
alias wdv='GIT_DIFF_TOOL=meld git difftool -d'
alias ch='Tchanges -head'
alias whci='Ccheckin $(Tchanges -head)'
