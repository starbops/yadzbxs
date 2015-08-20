# Yet Another Docker Image with Zabbix Server

## Prerequisites

Choose one of the database as backend of Zabbix server.

## MariaDB

```
$ docker run -d --name zabbix-db \
    -e MARIADB_USER=<username> \
    -e MARIADB_PASS=<password> \
    million12/mariadb
```

## MySQL

```
$ docker run -d --name zabbix-db \
    -e MYSQL_ROOT_PASSWORD=<password> \
    orchardup/mysql
```

## Build the Image

```
$ docker build -t yadzbxs .
```

## Run Zabbix Server

Currently the Zabbix server will connect to its backend database through
hardcoded "mysql" link name. That is, the name of the database container is of
your choice, but the name of the link must be "mysql". Otherwise the Zabbix
server container will fail.

```
$ docker run -d \
    -h <hostname> \
    --name zabbix \
    --link zabbix-db:mysql \
    -e DB_USER=<username> \
    -e DB_PASS=<password> \
    -v /etc/localtime:/etc/localtime:ro \
    -p 8080:80 \
    -p 10051:10051 \
    yadzbxs /sbin/my_init
```

