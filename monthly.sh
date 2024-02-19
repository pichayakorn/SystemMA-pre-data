#!/bin/bash
# Shell program to collect mata data from server, prepare for reporting
# Meta Data included 
#   - Current processes
#   - System stat
#   - Disk free
#   - Disk usage
# -------------------------------------------------------------------------
# This script is part of Monthly Health Check report steps 
# -------------------------------------------------------------------------
 
# Set –e is used within the Bash to stop execution instantly as a query exits while having a non-zero status.
set -e
LOG_LOCATION="/Backup2/sysstat/report/log"
exec &> >(tee -a ${LOG_LOCATION}/$(date +"%Y%m%d").log) 

# Shell
_SHELL=$(which bash)

# Script variable
yearRange=("2018" "2025")
Month=("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")
M30=("Apr" "Jun" "Sep" "Nov")
M28=("Feb")
# Regex for Integer checking
re='^[0-9]+$'
# Current Year (default)
curYear=$(date +"%Y") 
curMon=$(date +"%b")
for i in "${!Month[@]}" ; do
  if [[ "${Month[$i]}" == "${curMon}" ]] ; then
    #echo "${i}";
    prevNMon=${i}
  fi
done

# Script and Log path
_scriptPath="/Backup2/sysstat/report/script"
_logPath="/Backup2/sysstat/report"
_sysstatMPath="/Backup2/sysstat/report/sysstatM"

_sh_sar="${_scriptPath}/sar.sh"
_sh_sum_cpu_mem="${_scriptPath}/sum_cpu_mem.sh"
_sh_du="${_scriptPath}/du_script.sh"
_sh_df="${_scriptPath}/df_script.sh"

# Terminate script function
function terminate {
  echo "Script got terminated..." >&2;
  exit 1
}

function isLeap {
  local yy=${YY}
  leap="false"

  # find out if it is a leap year or not
 
  if [ $((yy % 4)) -ne 0 ] ; then
    : #  not a leap year : means do nothing and use old value of isleap
  elif [ $((yy % 400)) -eq 0 ] ; then
    # yes, it's a leap year
    leap="true"
  elif [ $((yy % 100)) -eq 0 ] ; then
    : # not a leap year do nothing and use old value of isleap
  else
    # it is a leap year
    leap="true"
  fi
  if [ "${leap}" == "true" ];
  then
    echo "${yy} is leap year"
  else
    echo "${yy} is NOT leap year"
  fi
} 

function selectDate {
  # Select target year 
  echo -n "Enter target Year ${yearRange[0]} - ${yearRange[1]} [${curYear}]: "
  read YY

  # Condition check for anomaly case. 
  #  - Empty string
  #  - Not an Integer
  #  - Invalid number of year 
  if [[ -z ${YY} ]] ; then
    echo "Default year is ${curYear}"
    YY=${curYear}
  elif ! [[ ${YY} =~ ${re} ]] ; then
    echo "error: Not an Integer" >&2; 
    terminate
  elif [[ ${YY} -ge ${yearRange[0]} ]] && [[ ${YY} -le ${yearRange[1]} ]] ; then
    echo "Your choice is ${YY}"
  else
    echo "Year is out of range ${yearRange[0]} - ${yearRange[1]}"
    terminate
  fi

  echo "----------------------------------------"
  echo

  # Select Number of Month 1 to 12.
  echo "Select Month Number ..."
  
  for i in ${!Month[@]}; do
    if [[ ${i} -eq $(( ${prevNMon} - 1 )) ]] ; then
      echo "==> ${Month[$i]} : $(( ${i} + 1 ))"
    else
      echo "    ${Month[$i]} : $(( ${i} + 1 ))"
    fi
  done

  echo -n "Select Month Number (1 - 12) [${prevNMon}]: "
  read nMON 

  # Condition check for anomaly case. 
  #  - Empty string
  #  - Not an Integer
  #  - Invalid number of month
  if [[ -z ${nMON} ]] ; then
    #echo "error: No input" >&2;
    #terminate
    nMON=${prevNMon}
    echo "Default month is ${Month[$((${nMON} - 1))]}"
  elif ! [[ ${nMON} =~ ${re} ]] ; then
    echo "error: Not an Integer" >&2; 
    terminate
  elif [[ ${nMON} -ge 1 ]] && [[ ${nMON} -le 12 ]] ; then
    echo "Your choice is ${nMON} (${Month[$((${nMON} - 1))]})"
  else
    echo "error: Invalid Number of Month" >&2;
    terminate
  fi
  
  # Convert choice to month abbreviation.
  MON=${Month[$((${nMON} - 1))]}
  
  # Get number of day in month.
  if [[ ${M28[@]} =~ ${MON} ]] ; then
    isLeap
    if [ "${leap}" == "true" ] ; then
      echo "${MON} have 29 days" 
      dayInMon=29
    else
      echo "${MON} have 28 days" 
      dayInMon=28
    fi
  elif [[ ${M30[@]} =~ ${MON} ]] ; then 
    echo "${MON} have 30 days" 
    dayInMon=30
  else
    echo "${MON} have 31 days" 
    dayInMon=31
  fi
}

function outputdircheck {
  _targetOutputDir="${_logPath}/${_selectDir}"
  if [ -d "${_targetOutputDir}" ] ; then
    ### Take action if directory exists ###
    echo "${_targetOutputDir} directory exists : ${_targetOutputDir}"
    echo -n "Would you like to clear all content in directory or not? [y/N]: "
    read -n 1 yn
    echo
    case ${yn} in
      Yes|YES|yes|Y|y)
        echo "Clearing content in directory..."
        rm -rf ${_targetOutputDir}/* 
        ;;
      *)
        echo "Cancel script..." >&2;
        terminate
        ;;
    esac
  else
    ### If directory does NOT exists, create instead ###
    ### or in case of invalid directory name ### 
    mkdir -p ${_targetOutputDir}
    echo "Create Directory: ${_targetOutputDir}"
    echo "Successfully!"
  fi
}

# Environtment Checking before start execute the script's body
#   - All path variables are exist.
#   - All related scripts are exist.
function envcheck {
  if ! [ -d "${_logPath}" ] ; then
    echo "${_logPath} path dose not exist ..." >&2;
    terminate
  fi
  if ! [ -d "${_scriptPath}" ] ; then
    echo "${_scriptPath} path does not exist ..." >&2;
    terminate
  fi
  if ! [ -d "${_sysstatMPath}" ] ; then
    echo "${_sysstatMPath} path does not exist ..."
    echo "Create ${_sysstatMPath} directory"
    mkdir -p ${_sysstatMPath}
    echo "Create ${_sysstatMPath} complete!"
  fi
  
  if [ -e "${_sh_sar}" ] ; then
    _sh_sar="${_SHELL} ${_scriptPath}/sar.sh"
  else
    echo "${_sh_sar} does not exist" >&2;
    terminate
  fi
  if [ -e "${_sh_sum_cpu_mem}" ] ; then
    _sh_sum_cpu_mem="${_SHELL} ${_scriptPath}/sum_cpu_mem.sh"
  else
    echo "${_sh_sum_cpu_mem} does not exist" >&2;
    terminate
  fi
  if [ -e "${_sh_du}" ] ; then
    _sh_du="${_SHELL} ${_scriptPath}/du_script.sh"
  else
    echo "${_sh_du} does not exist" >&2;
    terminate
  fi
  if [ -e "${_sh_df}" ] ; then
    _sh_df="${_SHELL} ${_scriptPath}/df_script.sh"
  else
    echo "${_sh_df} does not exist" >&2;
    terminate
  fi
}

# ---------- Start getting log ----------
echo "----- Start getting log : $(date) -----"
echo
# Check environment before execute the script's body
envcheck

# Call salect date function
selectDate
echo "----------------------------------------"
echo

# -- Create directory from input parameter
_defaultDir="${YY}$(printf -- '%02d' "${nMON}")"
echo -n "Enter output directory name [${_defaultDir}]: "
read _selectDir
echo

if [ -z ${_selectDir} ] ; then
  echo "Default directory is ${_defaultDir}"
  _selectDir=${_defaultDir}
fi
# Call outputdircheck function
outputdircheck
echo 
echo "Log path : ${_targetOutputDir}"
echo
echo "----------------------------------------"
echo

# Change directory to target output log path
cd ${_targetOutputDir}

# Top processes
echo "[TOP] Current processes ..."
top -b n 1 | head -n 37 > top.txt 
echo "> Get current processes complete!"
echo
echo "----------------------------------------"
echo

# Sysstat
echo "[Sysstat] System Status ..."
echo "> Clear content in sysstatM (TEMP) directory ..."
rm -rf ${_sysstatMPath}/*
echo "> Clear content in sysstatM directory complete!"
echo
${_sh_sar} ${YY} ${MON} ${dayInMon}
echo
echo "----------------------------------------"
echo

# Sum cpu and memory in csv format
# Change directory to sysstatM
cd ${_sysstatMPath} 
echo "[Sum CPU & MEM] Convert to CSV ..."
${_sh_sum_cpu_mem}
echo "> Sum all average cpu and memory to csv format complete!"
echo "> Compress sysstat log & Move all files to ${_targetOutputDir}"
echo "> Compress sysstat log"
mv sum_* ${_targetOutputDir}
zip -rm "${_targetOutputDir}/${MON}${YY}.zip" ${MON}*.txt
echo "> Compress and Move all files complete!"
echo
echo "----------------------------------------"
echo

# Disk free and disk usage
# Change directory to target output log path
cd ${_targetOutputDir} 
echo "[Disk Space] Disk space information ..."
echo "> Disk free ..."
${_sh_df}
echo "> Disk usage ..."
${_sh_du}
echo "> Get disk space information complete!"
echo
echo "----------------------------------------"
echo
echo "----- Complete: $(date) -----"
echo
