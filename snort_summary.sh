#!/bin/bash
# Last Update	:	2012/08/11
# Author	:	labunix
# License	:	GNU Public License
# Description	:	snort summary report
#			See also about following signals.
#			"NOTES" Section in "man snort"
#

if [ `id -u` -ne "0" ];then
  echo "Sorry,Not Permit User!"
  exit 1
fi

# mail
SNORTMAIL=root@`hostname -f`

# log
SYSLOG=/var/log/syslog
SUMMARYLOG="/var/log/snort/snort_summary_`date +%Y%m%d`.log"

# date
THISTIME=`env LANG=C date '+%b *%-d %H:%M:'`
pkill -USR1 snort
sleep 2;

# at 1st, $THISTIME
echo "$THISTIME" > "$SUMMARYLOG"

# summary from syslog 
grep "^${THISTIME}.*snort" "$SYSLOG" | \
  sed s/".*snort\[[0-9]*\]\: "//g >> "$SUMMARYLOG"

# snort daemon status
/etc/init.d/snort status >> "$SUMMARYLOG"
sleep 2;

cat "$SUMMARYLOG" | mail -s "Snort Summary ${THISTIME}" "$SNORTMAIL"

unset SUMMARYLOG THISTIME SYSLOG
exit 0

