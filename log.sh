# Check log
#!/bin/bash
# It must contain an arg
if [ ! -n "$1" ]; then
  echo usage: ./log.sh APPID [date]
  exit 1
fi
date=`date +%Y%m%d`
# Check 2nd arg
if [ -n "$2" ]; then
  date=$2
fi
file=`find log/$date -type f -name $1`
# Check find command result
if [ ! 0 = "$?" ]; then
  echo check date
  exit 2
fi
# Check log file
if [ -f "$file" ]; then
  view $file
else
  echo check APPID
  exit 3
fi
