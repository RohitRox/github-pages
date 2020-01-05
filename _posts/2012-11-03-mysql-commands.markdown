---
layout: post
title: "MySql commands"
date: 2012-11-03 14:26
comments: true
categories: [MySQL]
---
This is a short-list of handy MySQL commands that I have to use time and time again, in my development machine as well as in servers and for importing and exporting databases.

Login to mysql console (from unix shell)
```shell
  $ mysql -u user -p
  # if host name is required
  $ mysql -h hostname -u user -p

```

Create a new database
``` shell
  mysql> create database databasename;
```

List all databases
``` shell
  mysql> show databases;
```

<!--more-->

Switch to a database
``` shell
  mysql> use database_name;
```

List tables
``` shell
  mysql> show tables;
```

See database's field formats.
``` shell
   mysql> describe table_name;
```

Drop a db.
``` shell
  mysql> drop database database_name;
```

Delete a table.
``` shell
  mysql> drop table table_name;
```

Show all data in a table.
``` shell
  mysql> SELECT * FROM table_name;
```

Returns the columns and column information pertaining to the designated table.
``` shell
  mysql> show columns from table_name;
```

Set a root password if there is on root password.
``` shell
  $ mysqladmin -u root password newpassword
```

Update a root password.
``` shell
  $ mysqladmin -u root -p oldpassword newpassword
```

Recover a MySQL root password.
Stop the MySQL server process. Start again with no grant tables. Login to MySQL as root. Set new password. Exit MySQL and restart MySQL server.
``` shell
  $ /etc/init.d/mysql stop
  $ mysqld_safe --skip-grant-tables &
  $ mysql -u root
  mysql> use mysql;
  mysql> update user set password=PASSWORD("newrootpassword") where User='root';
  mysql> flush privileges;
  mysql> quit
  $ /etc/init.d/mysql stop
  $ /etc/init.d/mysql start
```
Export a database for backup.
``` shell
  $ mysqldump -u user -p database_name > file.sql
```

Import a database
``` shell
  $ mysql -p -u username database_name < file.sql
```
Dump all databases
``` shell
  $ mysqldump -u root -password --opt > alldatabases.sql
```

