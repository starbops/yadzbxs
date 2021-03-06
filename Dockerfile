FROM phusion/baseimage:0.9.17
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

# Zabbix version
ENV ZABBIX_VERSION=2.4.6

# Install zabbix
COPY assets /build/assets
RUN \
    apt-get -y update && \
    LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential subversion gcc automake make \
        apache2 php5 php5-gd php5-mcrypt php5-mysql libapache2-mod-php5 \
        mysql-client libmysqlclient-dev \
        libsnmp-dev\
        libopenipmi-dev ipmitool \
        libssh2-1-dev \
        libxml2-dev \
        python-dev python-pip ntp && \
    tar zxvf /build/assets/zabbix-${ZABBIX_VERSION}.tar.gz -C /usr/local/src && \
    cd /usr/local/src/zabbix-${ZABBIX_VERSION} && \
    patch -p0 < /build/assets/foreground.patch && \
    ./configure \
        --enable-server \
        --with-mysql \
        --with-net-snmp \
        --with-openipmi \
        --with-ssh2 \
        --with-libxml2 && \
    make install

# Dependencies of Zabbix-related scripts
RUN \
    pip install click docker-py pyghmi slacker zabbix-client

# Default environment variables.
ENV \
    DB_USER=zabbix \
    DB_PASS=password

# initialization scripts.
COPY scripts /build/scripts
COPY install /build/install
RUN /build/install

# Expose service ports.
EXPOSE 22 80 10051

# Set up OpenLDAP database and config directory in data volume.

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
