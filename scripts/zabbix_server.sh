#!/bin/sh

# Run zabbix server as zabbix user in foreground mode
exec /sbin/setuser zabbix \
    /usr/local/sbin/zabbix_server -f -c /usr/local/etc/zabbix_server.conf 2>&1
