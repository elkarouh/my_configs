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
alias CTG='cleartool setview -exec "Ccontext -b TACT.TACT_CONFIG.LATEST_GOOD -e G!31.IP.L8" cmadm.default_view'
alias CTOG='cleartool setview -exec "Ccontext -b TACT.TACT_CONFIG.LATEST_GOOD -e G!31.OP.L8" cmadm.default_view'
alias CI='cleartool setview -exec "Ccontext -b IFPS.FPL_CONFIG.LATEST  -e G!31.IP.L8" cmadm.default_view'
# alias CT='cleartool setview -exec "Ccontext -b TACT.TACT_CONFIG.LATEST -e G!31.IP.L8" cmadm.default_view'
function CT {
  [ $# -ne 0 ] && cecho Wy "'cdlog' to go to the logs directory"
  BASELINE=$([ $# -eq 0 ] && echo LATEST || echo 29.0.0.$1)
  cleartool setview -exec "Ccontext -b TACT.TACT_CONFIG.$BASELINE -e G!31.IP.L8" cmadm.default_view
}

function CFMU {
  cleartool setview -exec "Ccontext -b CFMU.CFMU_CONFIG.LATEST" cmadm.default_view
}
function ct27 {
  cleartool setview -exec "ccontext -b tact.tact_config.27.0.0.${1:-latest} -e g!30.IP.L8" cmadm.default_view
}
function CT271 {
  cleartool setview -exec "Ccontext -b TACT.TACT_CONFIG.27.1.0.${1:-LATEST} -e G!30.IP.L8" cmadm.default_view
}
function CT272 {
  cleartool setview -exec "Ccontext -b TACT.TACT_CONFIG.27.2.0.${1:-LATEST} -e G!30.IP.L8" cmadm.default_view
}
function CTO272 {
  cleartool setview -exec "Ccontext -b TACT.TACT_CONFIG.27.2.0.${1:-LATEST} -e G!30.OP.L8" cmadm.default_view
}
function ct270 {
  cleartool setview -exec "ccontext -b tact.tact_config.27.0.0.${1:-latest} -e g!30.OP.L8" cmadm.default_view
}
function CT26 {
  cleartool setview -exec "Ccontext -b TACT.TACT_CONFIG.26.0.0.${1:-LATEST} -e G!27.IP.L8" cmadm.default_view
}
function CT28 {
  cleartool setview -exec "Ccontext -b TACT.TACT_CONFIG.28.1.0.${1:-LATEST} -e G!31.IP.L8" cmadm.default_view
}

function CTO {
  [ $# -ne 0 ] && cecho Wy "'cdlog' to go to the logs directory"
  BASELINE=$([ $# -eq 0 ] && echo LATEST || echo 29.0.0.$1)
  cleartool setview -exec "Ccontext -b TACT.TACT_CONFIG.$BASELINE -e G!31.OP.L8" cmadm.default_view
}

#alias CE='cleartool setview -exec "Ccontext -b ELD.ELD_CONFIG.LATEST -e G!31.IP.L8" cmadm.default_view'
function CE {
  BASELINE=$([ $# -eq 0 ] && echo LATEST || echo 28.1.0.$1)
  cleartool setview -exec "Ccontext -b ELD.ELD_CONFIG.$BASELINE -e G!31.IP.L8" cmadm.default_view
}
function CE272 {
  BASELINE=$([ $# -eq 0 ] && echo 27.2.0.LATEST || echo 27.2.0.$1)
  cleartool setview -exec "Ccontext -b ELD.ELD_CONFIG.$BASELINE -e G!31.IP.L8" cmadm.default_view
}
## As long as you need frequent help keep these aliases in your .kshrc
alias Ct=cleartool
alias Csb='cd /home/$(whoami)/cm/; Csetup -view_build_setup '
alias CO='Ccontext -e ${CM_ENV_ID/IP/OP}'
####################################################################
pause_until_key_pressed () {
  #python -c "raw_input('Press enter to continue...')" # the only portable way for all shells !!!
  python3 -c "input('Press enter to continue...')" # the only portable way for all shells !!!
  cecho sWr "\ncontinuing ..."
  echo
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
cdv() { # cd to home dir of a view when in tactdev env or in a view
  myview=$(cleartool pwv -short)
  # echo "VIEW=$myview"
  if [[ ${myview:0:2} == '**' ]]; then
    echo "Not in a view, do nothing" >&2
    return
  fi
  cd $HOME/${CLEARCASE_ROOT/\/view/cm}
}

cdop() {
        cd ${PWD//IP/OP}
}
cdip() {
        cd ${PWD//OP/IP}
}

cdb() { # cd to the build log directory of the current view
  if [[ -z "${CLEARCASE_ROOT}" ]]; then
    echo >&2 "NOT IN A CONTEXT !!! exiting"
    return 1
  fi
  if [ $CLEARCASE_ROOT = /view/cmadm.default_view ]; then
    cd $TACT_TACT_CONFIG_HOME/saved_logs
  else
    view_name=$(cleartool pwv -short)
    VIEW_NAME=${(U)view_name} # short view name in uppercase
    view_type=$(Clsview | tr -s ' ' | tr ' ' '.' | grep $view_name | cut -d . -f 3)
    if [[ $view_type == TACT ]]; then
      log_dir_root="/cm/ot/TACT/TACT_CONFIG.$VIEW_NAME"
    else # must be IFPS
      log_dir_root="/cm/ot/IFPS/FLIGHT_CONFIG.$VIEW_NAME"
    fi
    log_dir_IP="${log_dir_root}/build_G!31.IP.L8/saved_logs"
    case $CFMU_BUILD_TYPE in
      IP)
        echo IP_BUILD
        if [[ -d $log_dir_IP ]]; then
          cd $log_dir_IP
        else
          cd ${log_dir_IP//IP/OP} || exit
        fi
        ;;
      OP)
        echo OP_BUILD
        cd ${log_dir_IP//IP/OP} || exit
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
  # view=$(cleartool pwv | tail -1 | cut -f 3 -d " ")
  # view_name=$(echo $view  |  cut -f 2 -d.) # short view name
  view=$(cleartool pwv -short)
  VIEW_NAME=$(echo $view | tr a-z A-Z) # short view name in uppercase
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

############################################## PYTHON VIEWS ###############################################
choose-python-view() {
  view=$(lpv | fzfmenu)
  echo "$view"
}

lpv() { # list python VIEWS
  fd -tl -d 1 . ~/.virtualenvs/ -x echo {/}
}

spv() { # set python view (virtual env)
  view_dir=$(choose-python-view)
  if [ -n $view_dir ];then
    cd ~/.virtualenvs/
    cd $(readlink ${view_dir})
    source bin/activate
    alias pexit='deactivate'
    echo "USE 'pexit' or 'deactivate' to exit"
  fi
}

mpv() { # make python view (virtual env)
  view_name=$1
  version=${2:-3.11}
  if python${version} -m venv ${view_name} ; then
    cur_dir=$(pwd)/${view_name}
    cd ~/.virtualenvs/
    ln -s $cur_dir "${view_name}-${version}"
    cd $cur_dir
    echo "PYTHON${version} VIEW '$view_name' CREATED"
  fi
}

dpv() { # delete python VIEW
    view_dir=$(choose-python-view)
    cd ~/.virtualenvs
    data_dir=$(readlink ${view_dir})
    echo "DELETING SYMLINK ${view_dir}"
    rm ${view_dir} # delete the symbolic link
    # now delete the directory
    echo "DELETING $data_dir"
    rm -fr $data_dir
    cd -
    }
###########################################################################################################
set_replay_context() {
  export CM_ENV_ID=G!31.OP.L8
  if [ $# -eq 0 ]
  then
    echo "BASELINE NUMBER REQUIRED, e.g. 160"
  else
    cleartool setview -exec "Ccontext -b TACT.TACT_CONFIG.28.1.0.$1 -e G!31.OP.L8" cmadm.default_view
  fi
  }
# alias bv='Tbuild_view -dir /cm/local_build -del -para 24'
bvDELETE() { # build view
  cdv
  if [ $# -eq 0 ];then
    prequal_replay_options=""
  else
    prequal_replay_options='-replay "db_instance" "TAC_LO3" "ora_instance" "${DEFAULT_ORA_LO}" "prequal"'
    prequal_replay_options="-replay prequal assert none"
    if [[ $CM_ENV_ID != *"OP"* ]]; then
      echo PREQUAL VIEW BUILD MUST RUN IN OPTIMISED MODE
      echo use the svo alias
      exit 1
    fi
  fi
  myview=$(cleartool pwv | tail -1 | cut -d' ' -f3)
  if [[ $myview == '**' ]]; then
    echo "You are not in the context of a view, please switch to a TACT or IFPS view" >&2
    return
  fi
  if [[ $myview == *"_e" ||  $myview == *"_eld" ]]; then
    echo "An ELD view cannot be built on its own, please switch to TACT view" >&2
    return
  fi
  if [[ $myview == *"_i" ]]; then
    print -z "Cbuild_view -dir best -del"
    return
  fi
  if [[ $myview != *"_t" && $myview != *"_tact" ]]; then
    echo "view $myview has to follow '_t' or '_tact' suffix convention" >&2
    return
  fi
  myviews=( $(Clsview | awk '/ekhassan./{if ($1=="ekhassan") print $2; else print $1}') )
  if [[ $myview == *"_t" ]]; then
    eld_view="${myview:0: -2}_e"
    ifps_view="${myview:0: -2}_i"
  else
    eld_view="${myview:0: -5}_eld"
    ifps_view="${myview:0: -5}_ifps"
  fi;
  if printf '%s\n' "${myviews[@]}" | grep -q --line-regex $eld_view; then
    eld_view_exists="TRUE"
  fi
  if printf '%s\n' "${myviews[@]}" | grep -q --line-regex $ifps_view; then
    ifps_view_exists="TRUE"
  fi
  if [[ -n $eld_view_exists ]] && [[ -n $ifps_view_exists ]]; then
    print -z $(echo "Tbuild_view -eld $eld_view -ifps $ifps_view -dir best -del -para 24 $prequal_replay_options")
  elif [[ -n $eld_view_exists ]]; then
    print -z $(echo "Tbuild_view -eld $eld_view -dir best -del -para 24 $prequal_replay_options")
  else
    print -z "Tbuild_view -dir best -del -para 24 $prequal_replay_options"
  fi;
}

hcompareOBSOLETE () {
  cdv
  remote_file=$(fd -tf $1 $CM_VOB | fzf)
  remote_dir="${remote_file}@@/main"
  echo "REMOTE FILE=$remote_file"
  echo "REMOTE_DIR=$remote_dir"
  old_version1=$(fd '^\d{1,3}' --max-depth 1 $remote_dir | fzf)
  if [ ! "$#" -gt 1 ]
  then
    echo "BASELINE=$remote_file"
    kompare $remote_file $old_version1 2>/dev/null
  else
    old_version2=$(fd '^[0-100]' --max-depth 1 $remote_dir | fzf)
    kompare $old_version1 $old_version2 2>/dev/null
    #meld ${remote_file}@@/main/$3 ${remote_file}@@/main/$2 2>/dev/null
  fi;
  }

hcomplogOBSOLETE () { # compare logs
  Tcompare_last $1 $2
  kompare Tcompare_last_1.comp Tcompare_last_2.comp
}
