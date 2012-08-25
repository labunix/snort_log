#!/bin/bash

if [ "`id -u`" -ne "0" ];then
  echo "Sorry! Not Permit User!"
  exit 1
fi

chown proxy:proxy -R /var/lib/squidguard/db/*
chown proxy:proxy -R /etc/squid/
find /var/lib/squidguard/db -type f | xargs chmod 644
find /var/lib/squidguard/db -type d | xargs chmod 755
sudo -u proxy /usr/bin/squidGuard -d -C all && \
sudo -u proxy /usr/sbin/squid -k reconfigure && \
sudo -u proxy /usr/sbin/squid -k check && \
echo "OK"
exit 0
