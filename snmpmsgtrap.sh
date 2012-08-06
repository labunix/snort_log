#!/bin/bash
# Last Update	:	2012/08/03
# Author	:	labunix
# Description	:	GNU General Public License
#
if [ "$#" -lt 1 ];then
  echo "Usage $0 [Message]"
  exit 1
fi
MYCOMMUNITY=`grep "^auth" /etc/snmp/snmptrapd.conf | awk '{print $NF}'`
SRCHOST="192.168.72.1"
DSTHOST="192.168.72.188"
snmptrap -v 1 -c $MYCOMMUNITY $DSTHOST .1.3.6.1.4.1.8072.99999 \
  $SRCHOST 6 1 '' .1.3.6.1.4.1.8072.99999.1 s "$@"
