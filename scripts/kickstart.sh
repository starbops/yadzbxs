#!/bin/sh -e

# Spam config file of zabbix server
cat <<EOF > /usr/local/etc/zabbix_server.conf
LogFile=/var/log/zabbix/zabbix_server.log
PidFile=/var/run/zabbix/zabbix_server.pid
DBHost=mysql
DBName=zabbix
DBUser=${DB_USER}
DBPassword=${DB_PASS}
EOF

# Bootstrap MySQL Database for zabbix if it is not exist
if ! mysql -h mysql -u ${DB_USER} -p${DB_PASS} -e 'use zabbix;'; then
    mysql -h mysql -u ${DB_USER} -p${DB_PASS} \
        -e "CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8;"
    mysql -h mysql -u ${DB_USER} -p${DB_PASS} \
        -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'%' IDENTIFIED BY '${DB_PASS}';"

    ZABBIX_SQL_DIR="/usr/local/src/zabbix-2.4.5/database/mysql/"
    mysql -h mysql -u ${DB_USER} -p${DB_PASS} zabbix < ${ZABBIX_SQL_DIR}/schema.sql
    mysql -h mysql -u ${DB_USER} -p${DB_PASS} zabbix < ${ZABBIX_SQL_DIR}/images.sql
    mysql -h mysql -u ${DB_USER} -p${DB_PASS} zabbix < ${ZABBIX_SQL_DIR}/data.sql
fi

# Spam config file for zabbix frontend
cat <<EOF > /usr/share/zabbix/conf/zabbix.conf.php
<?php
// Zabbix GUI configuration file
global \$DB;

\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = 'mysql';
\$DB['PORT']     = '0';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER']     = '${DB_USER}';
\$DB['PASSWORD'] = '${DB_PASS}';
// SCHEMA is relevant only for IBM_DB2 database
\$DB['SCHEMA'] = '';

\$ZBX_SERVER      = 'localhost';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = 'zabbix';

\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
?>
EOF

exit 0
