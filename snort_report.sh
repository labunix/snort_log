#!/bin/bash
# Last Update	:	2012/08/17
# Author	:	labunix
# License	:	GNU General Public License
# Description	:	Temp Password from snort.conf
#			env MYSQL_PWD
#			env PGPASSWORD
#
# Get "[mysql|postgresql]" "password" from snort.conf
# Format:
# output database: log, [mysql|postgresql], user=snort dbname=snort password=XXXX host=localhost

if [ `id -u` -ne 0 ];then
  echo "Sorry,Not Permit User!"
  exit 1
fi

chmod 500 $0
chown root:root $0

MYSQL_PGSQL=$(grep "^ *output database" /etc/snort/snort.conf | \
  sed s/","/" "/g | awk '{print $4}')

DBLOG="/var/log/snort_${MYSQL_PGSQL}.html"
DBCOM='select * from signature;'
MAILTO="root@`hostname -f`"
touch "$DBLOG" || exit 1

case "$MYSQL_PGSQL" in
mysql)
  echo "${DBCOM}" | sudo -u snort \
  env MYSQL_PWD=$(grep "^ *output database" /etc/snort/snort.conf | \
    sed s/"^ *output database.*password="//g | awk '{print $1}') \
  mysql -u snort -D snort -h localhost -H > "${DBLOG}"
  # echo "For DEBUG MYSQL_PWD=${MYSQL_PWD}"
  ;;
postgresql)
  echo "${DBCOM}" | sudo -u snort \
  env PGPASSWORD=$(grep "^ *output database" /etc/snort/snort.conf | \
    sed s/"^ *output database.*password="//g | awk '{print $1}') \
  psql -U snort -d snort -h localhost -H > "${DBLOG}"
  # echo "For DEBUG PGPASSWORD=${PGPASSWORD}"
  ;;
*)
  echo "Error: No output database Settings."
  ;;
esac

w3m -no-proxy -dump -cols 80 "${DBLOG}" | \
  mail -s "Snort db Signature Report `env LANG=C date '+%Y/%m/%d %H:%M%S'`" \
  "${MAILTO}"

chown snort:adm "$DBLOG"
chmod 750 "$DBLOG"
unset DBCOM DBLOG MYSQL_PGSQL MAILTO
exit 0
