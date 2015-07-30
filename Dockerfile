FROM phusion/baseimage:0.9.16
MAINTAINER Zespre Schmidt <starbops@gmail.com>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Set up sshd.
COPY key.pub /tmp/key.pub
RUN \
    rm -f /etc/service/sshd/down && \
    /etc/my_init.d/00_regen_ssh_host_keys.sh && \
    cat /tmp/key.pub >> /root/.ssh/authorized_keys && \
    rm -f /tmp/key.pub

# Add zabbix user and group.
RUN groupadd -r zabbix && useradd -r -g zabbix zabbix

# Install zabbix
COPY assets /build/assets
RUN \
    apt-get -y update && \
    LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential \
        subversion \
        gcc \
        automake \
        make \
        #zabbix-frontend-php \
        apache2 \
        php5 \
        php5-gd \
        php5-mcrypt \
        php5-mysql \
        libapache2-mod-php5 \
        mysql-client \
        libmysqlclient-dev \
        openjdk-7-jdk \
        ntp && \
    tar zxvf /build/assets/zabbix-2.4.5.tar.gz -C /usr/local/src && \
    cd /usr/local/src/zabbix-2.4.5 && \
    patch -p0 < /build/assets/foreground.patch && \
    ./configure \
        --enable-server \
        --enable-agent \
        --with-mysql \
        --enable-java && \
        #--with-net-snmp \
        #--with-libcurl \
        #--with-libxml2 \
        #--with-openipmi && \
    make install

# Default environment variables.
ENV \
    JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-amd64/bin/java \
    JAVA=/usr/lib/jvm/java-1.7.0-openjdk-amd64/bin/java \
    DB_ADDRESS=127.0.0.1 \
    DB_USER=username \
    DB_PASS=password

# initialization scripts.
COPY scripts /build/scripts
COPY install /build/install
RUN /build/install

# Expose service ports.
EXPOSE 22 80 10050 10051 10052

# Set up OpenLDAP database and config directory in data volume.

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
