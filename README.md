# Yet Another Docker Image with Zabbix Server

# Prerequisites

```
$ docker run -d --name zabbix-db \
    -e MARIADB_USER=<username> \
    -e MARIADB_PASS=<password> \
    million12/mariadb
```

# Build the Image

```
$ docker build -t <image> .
```

# Run Zabbix Server

```
$ docker run -d \
    -h <hostname> \
    --name zabbix \
    --link zabbix-db:db \
    -e DB_USER=<username> \
    -e DB_PASS=<password> \
    -v /etc/localtime:/etc/localtime:ro \
    -p 8080:80 \
    -p 10051:10051 \
    yadzbxs:0.1 /sbin/my_init
```

