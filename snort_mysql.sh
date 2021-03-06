#!/bin/bash

if [ `id -u` -ne 0 ];then
  echo "Sorry,Not Permit User"
  exit 1
fi
chown root:root $0 || exit 1
chmod 700 $0 || exit 1

SQLLOG="/var/log/snort/snort_mysql_`date '+%Y%m%d'`.log"
SQLHTML="/var/log/snort/snort_mysql_`date '+%Y%m%d'`.html"
touch "$SQLLOG" || exit 2
touch "$SQLHTML" || exit 2

DBNAME="snort"
SQLMAIL="root@`hostname -f`"

SQLCOM="/var/log/snort/snort_mysql.sql"
touch "$SQLCOM" || exit 2
# 1st only
if ! [ -s "$SQLCOM" ];then
  echo '
select * from event order by cid desc limit 1;
select * from reference;
select * from reference_system;
select * from `schema`;
select * from sensor;
select * from sig_class;
select * from sig_reference;
select * from signature;
' > "$SQLCOM"
fi
test -f "$SQLCOM" && chmod 600 "$SQLCOM"
# echo -e "DEBUG:\n" cat "$SQLCOM"; exit 0

ACCOUNT=/var/log/snort/mysql.conf
touch "$ACCOUNT" || exit 2
if [ `wc -l < "$ACCOUNT"` -ne 1 ];then
  # at 1st only
  chmod 600 "$ACCOUNT" | exit 3

  echo -n "mysql_user:snort Input Password:"
  # no echo password
  stty -echo
  read FPASS
  stty echo
  echo ""

  echo -n "Retype Password:"
  # no echo password
  stty -echo
  read NPASS
  stty echo
  echo ""

  # password check
  if [ "$FPASS" == "$NPASS" ];then
    echo "$FPASS" >> "$ACCOUNT"
    unset FPASS NPASS
    chown root:root "$ACCOUNT" && chown 600 "$ACCOUNT"
  else
    echo "Not Password Match"
    unset FPASS NPASS
    exit 1
  fi

  # double change
  unset FPASS
  unset NPASS
  chown root:root "$ACCOUNT"

  # change read only
  chmod 400 "$ACCOUNT"
fi

#echo -e "DEBUG:\n";cat "$ACCOUNT";exit 0 

# main
mysql -u snort --password=`cat "$ACCOUNT"` -D "$DBNAME" < "$SQLCOM" > "$SQLLOG"

# to SystemMail
cat "$SQLLOG" | mail -s "snort mysql summary" "$SQLMAIL"

# to html
echo '<html><head><title>snort mysql table report</title></head>' > "$SQLHTML"
echo '<body><table border="1">' >> "$SQLHTML"
grep -v "^\$" "$SQLLOG" | sed s/"\t"/"\,"/g      | \
  sed s%"\,"%'<\/td><td>'%g                      | \
  sed s/"^"/'<tr><td>'/g                         | \
  sed s%"\$"%'</td></tr>'%g                      | \
  sed s%"^[A-z]"%'</table><table border="1">'%   | \
  sed s%"<tr>\|</td>"%"&\n"%g | sed s%"<td>"%"\t&"%g >> "$SQLHTML"
echo -e '</table>\n</html>' >> "$SQLHTML"

unset ACCOUNT DBNAME SQLCOM SQLLOG SQLMAIL SQLHTML
exit 0
