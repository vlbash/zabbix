FROM ubuntu:18.04 
ENV TINI_VERSION v0.18.0
WORKDIR /tmp

COPY create.sql.gz .
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /sbin/tini

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y &&  DEBIAN_FRONTEND=noninteractive apt-get -y install wget apt-utils curl sudo
RUN wget https://repo.zabbix.com/zabbix/4.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.4-1+bionic_all.deb
    
RUN dpkg -i zabbix-release_4.4-1+bionic_all.deb

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get upgrade -y    
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install zabbix-server-pgsql zabbix-frontend-php zabbix-apache-conf php-pgsql zabbix-agent       
COPY create-db.sql /var/lib/postgresql
RUN service postgresql start 
RUN chown -R postgres:postgres /var/lib/postgresql 
RUN ls -la /var/lib/postgresql 
RUN su - postgres 



EXPOSE 80/TCP 443/TCP

WORKDIR /usr/share/zabbix

VOLUME ["/etc/ssl/apache2"]

COPY ["conf/etc/zabbix/apache.conf", "/etc/zabbix/"]
COPY ["conf/etc/zabbix/apache_ssl.conf", "/etc/zabbix/"]
COPY ["conf/etc/zabbix/web/zabbix.conf.php", "/etc/zabbix/web/"]
COPY ["conf/etc/php/7.2/apache2/conf.d/99-zabbix.ini", "/etc/php/7.2/apache2/conf.d/"]
COPY ["docker-entrypoint.sh", "/usr/bin/"]

ENTRYPOINT ["docker-entrypoint.sh"]
