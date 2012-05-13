#!/bin/bash
# Name        : snort_deletelog.sh
# Description : snort rotate script
# Author      : labunix
# Last Update : 2012/05/12

# ローテーション日数nを指定
ROTATE=2

# root 権限を確認
if [ `id -u` -ne "0" ];then
  echo "Sorry,Not Permit User!"
  exit 1
fi

# Snort ログディレクトリの定義
SNORTLOG=/var/log/snort
test -d $SNORTLOG || exit 1

# 一時ファイル定義
SNORTTEMP=/tmp/snort_list.tmp
touch $SNORTTEMP || exit 1
chmod 600 $SNORTTEMP || exit 1

# n日以上経ったログを取得
find $SNORTLOG -name "tcpdump.log.*[0-9]" -mtime +$ROTATE \
  -exec ls -l {} \; > $SNORTTEMP

if [ -s $SNORTTEMP ];then
  echo "KeyDay:"`env LANG=C date --date "${ROTATE} days ago"` >> $SNORTTEMP
  cat $SNORTTEMP | mail -s "Snort tcpdump.log Delete" root
  find $SNORTLOG -name "tcpdump.log.*[0-9]" -mtime +$ROTATE \
    -exec rm -f {} \;
else
  echo "Do Nothing"
fi
rm -f $SNORTTEMP
unset SNORTTEMP
exit 0

