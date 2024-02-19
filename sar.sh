#!/bin/bash
set -e

_Year=${1}
_Mon=${2}
_dayInMon=${3}

# In case of pure excute
if [ -z ${_Year} ] || [ -z ${_Mon} ] || [ -z ${_dayInMon} ]; then
  echo "Invalid arguement [ Year Mon dayInMon ]" >&2;
  exit 1
fi

# Get Sysstat log 
for i in $(seq 1 ${_dayInMon}) 
do
  _date="$( printf -- '%02d' "${i}" )"
  echo "Doing on file ${_Mon}-${i}-${_Year}"
  sar -r -u -f /Backup2/sysstat/log/${_Mon}-${i}-2022 > /Backup2/sysstat/report/sysstatM/${_Mon}-${_date}.txt
done
