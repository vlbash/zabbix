create database zabbix;
create user zabbix with encrypted password 'zabbix';
grant all privileges on database zabbix to zabbix;
