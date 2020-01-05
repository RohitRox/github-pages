---
layout: post
title: "Interacting to MySQL using Ruby"
date: 2012-10-30 00:58
comments: true
categories: [Ruby, MySQL]
---

This tutorials guides you to go straight into interacting with MySQL database using Ruby alone. No Rails.
It is assumed that MySQL has been installed in your computer.

Now let's get started:

First of all, lets begin with installing MySQL libraries via RubyGems

``` shell
  gem install mysql
```
There is [documentation](http://www.tmtm.org/en/mysql/ruby/) for the MySQL library online . So you can follow that.

Now let's fire irb.

``` ruby
  require 'mysql'
  db = Mysql.new('localhost', 'user', 'password', 'database')
```
<!-- more -->

If you are using something like Lampp you may end up with error like

` Mysql::Error: Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2) `

So you have to locate where your mysqld.sock is.

For Lamp users, it's in `/opt/lampp/var/mysql/mysql.sock`
For others you can find by using

```shell
  ps aux | grep mysql
```

Next,create symlink at '/var/run/mysqld/mysqld.sock' to location of mysql.sock by ln -s command.

``` shell
  sudo ln -s /opt/lampp/var/mysql/mysql.sock /var/run/mysqld/mysqld.sock
```

That's it. Now we are ready to go.
With successfull connection we can query to database.

``` ruby
  begin
    results = db.query "SELECT * FROM users"
    puts "Number of users #{results.num_rows}"
    results.each_hash do |row|
      puts "User #{row.id}: #{row.name}"
    end
    results.free
  ensure
    db.close
  end
```

The code is wrapped up in an exception handling block, to ensure that no matter what happens in the code. The database connection is closed.

The returned result is of `Mysql::Result` class.Check the [documentation](http://www.tmtm.org/en/mysql/ruby/) and scroll down to Mysql::Result for various methods available at your disposal.If you are familiar with other MySQL connectors, this should be a breeze.

Lastly, Mysql Ruby connector also supports prepared statements, so you can use goodness out of it.

``` ruby
  begin
    insert_new_user = db.prepare "INSERT INTO users (name, age, gender) VALUES (?, ? ,?)"
    insert_new_user.execute 'travis', '22', 'male'

    insert_new_user.close

    statement = db.prepare "SELECT * FROM users WHERE name = ?"
    statement.execute 'travis'
    statement.fetch
    statement.close
  ensure
    db.close
  end
```



