---
layout: post
title: "ActiveRecord with Ruby alone"
date: 2012-10-30 23:06
comments: true
categories: [Ruby]
---

Active Record is the main tool that Rails developers use to communicate with and underlying database. Active Record does some wonderful things for a web developer looking for abstractions in  database setup, SQL connections and queries.  We can get a cool command line Ruby application or utility script for our daily tasks using Active Record going in about 5 minutes!

First of all, get the activerecord gem using

```
  gem install activerecord
```

At the top of Ruby program we need to require the Active Record gem previously installed.  Interacting with your database will be a pleasure now!

``` ruby
  require 'activerecord'
```

### Establishing a connection to database

``` ruby
  ActiveRecord::Base.establish_connection {
    adapter:  "mysql",
    host:     "localhost",
    username: "root",
    password: "password",
    database: "dbname"
  }
```

<!-- more -->

After successfull database connection we can create a class that inherits from ActiveRecord::Base whose objects map to database a table. Suppose we have users table with name field:

``` ruby
  class User < ActiveRecord::Base
    # this maps database table "users" to this Ruby class User
  end

  User.all # select all from users table
  usr = User.first # returns the first object fetched by SELECT * FROM users
  usr.name = 'zappy'
  usr.save # name zappy is set for usr and saved in db
```

Active Record objects don’t specify their attributes directly, but rather infer them from the table definition with which they’re linked. Adding, removing, and changing attributes and their type is done directly in the database. Any change is instantly reflected in the Active Record objects. The mapping that binds a given Active Record class to a certain database table will happen automatically in most common cases, but can be overwritten for the uncommon ones.

All the goodness available from ActiveRecord is documented [here](http://api.rubyonrails.org/classes/ActiveRecord/Base.html).

It should be noted that there are some conventions it assumes:

-	an Active Record class maps to a database table.
-	database table names, like variable names, have lowercase letters and underscores between the words.
-	table names are always plural.

If you want table names to be singular instead of plural, you can set the configuration parameter pluralize_table_names:
```ruby
  ActiveRecord::Base.pluralize_table_names = false
```

### Update:

Rails now (> V5) has a handy module we can include: `include ActiveModel::Model`
This allows to initialise with a hash, and use validations amongst other things.

Full documentation is [here](https://api.rubyonrails.org/classes/ActiveModel/Model.html).
