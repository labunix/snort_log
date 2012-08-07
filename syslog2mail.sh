#!/bin/bash
# Last Update	:	2012/08/08
# Author	:	labunix
# Description	:	syslog to mail
#		:	default target : snort
#		:	Usage : ./syslog2mail [d|h|m] 
#		:	d	1 days ago
#		:	h	1 hour ago
#		:	m	5 min ago 

function varclean() {
  unset MAILTO MYMSG MYLOG SYSLOG MYOPT MYLOG TARGET USAGE
  unset MYMINMSG MYMIN MYHOURMSG MYHOUR MYDAYMSG MYDAY
}

USAGE="Usage: $0 [d|h|m]"
# arg check
if [ "$#" -lt "1" ];then
  echo "$USAGE"
  varclean
  exit 1
fi

TARGET="snort"
MYLOG="/var/log/trapmail.log"
SYSLOG="/var/log/syslog"
MAILTO="root@`hostname -f`"

# you must be root
if [ `id -u` -ne "0" ] ;then
  echo "Sorry,Not Permit User!"
  varclean
  exit 1
fi

# 1 days ago
MYDAYMSG='1 days ago'
MYDAY=`env LANG=C date -d "${MYDAYMSG}" '+%b %d' | \
   awk '{if($2<10) print $1"  "$2+0" [0-9][0-9]\\\:[0-9][09]\\\:[0-9][0-9]" ;
              else print $1" "$2+0" [0-9][0-9]\\\:[0-9][09]\\\:[0-9][0-9]"}'`

# 1 hour ago
MYHOURMSG='1 hour ago'
MYHOUR=`env LANG=C date -d "${MYHOURMSG}" '+%T' | \
   awk -F\: '{print $1"\\\:[0-9][09]\\\:[0-9][0-9]"}'`

# 5 min ago
MYMINMSG='5 min ago'
MYMIN=`env LANG=C date -d "${MYMINMSG}" '+%T' | \
   awk -F\: '{print $1"\\\:"$2"\\\:[0-9][0-9]"}'`

case $@ in
d)
  MYOPT=$MYDAY;
  MYMSG="${MYDAYMSG}";
  ;;
h)
  MYOPT=$MYHOUR;
  MYMSG="${MYHOURMSG}"
  ;;
m)
  MYOPT=$MYMIN;
  MYMSG="${MYMINMSG}"
  ;;
*)
  echo "$USAGE"
  varclean
  exit 1
esac
# line not 0 check
if [ `wc -l < $SYSLOG` -eq "0" ];then
  varclean
  exit 1
fi

test -r ${SYSLOG} && \
  grep "^${MYOPT} `hostname -s` ${TARGET}.*\:" ${SYSLOG} > ${MYLOG}

# line not 0 check
test -r ${MYLOG} || exit 1
if [ `wc -l < ${MYLOG}` -eq "0" ];then
  varclean
  exit 1
fi

cat "$MYLOG" | mail -s "$TARGET $MYMSG report" "$MAILTO"
test -f "$MYLOG" && rm -f "$MYLOG"
varclean
exit 0
