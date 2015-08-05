# Yet Another Docker Image with Zabbix Server

# Prerequisites

```
$ docker run -d --name zabbix-db \
    -e MARIADB_USER=<username> \
    -e MARIADB_PASS=<password> \
    -p 3306:3306 \
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
    -e DB_ADDRESS=<db_server> \
    -e DB_USER=<username> \
    -e DB_PASS=<password> \
    -v /etc/localtime:/etc/localtime:ro \
    -p 80:80 \
    -p 10051:10051 \
    yadzbxs:0.1 /sbin/my_init
```

