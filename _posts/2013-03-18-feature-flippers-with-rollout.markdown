---
layout: post
title: "Feature flippers with rollout"
date: 2013-03-18 12:09
comments: true
categories: [Ruby, Rails]
---
Rollout gem comes handy when we need deploy a beta feature, may be to a selected group of users or some percentage of uses so that few users can try it out before it goes massive.

So lets rollout.

We'll be using redis as rollout's backend.

To setup, jusst add `gem 'rollout'` to Gemfile and run `bundle install`.

Now, we need to create a rollout setup file inside initializer.

Let's name it rollout_init.rb which looks like this:

```ruby

  $redis = Redis.new
  $rollout = Rollout.new($redis)
  $rollout.define_group(:admin) do |user|
    user.admin?
  end

```
Documentation suggests to use a global variables. So we create one with a new redis instance.
Then, we create rollout instance passsing that redis instance. We can configure rollout in many ways, here we are defining an admin group by passing a block and checking whether the user belongs to that group or not.
Complete documentation can be found [here](https://github.com/jamesgolick/rollout).

Next, we can now use handy rollout method like for example let's say we need to activate chat feature for admin group only.

``` ruby

  if $rollout.active? :chat, current_user

    ....

  end

```

<!--more-->


The ```$rollout.active?``` method accepts the name of the feature and the user and returns true or false.

This method is accessible in views as well as in controllers.
That's not all, if you restart your server now and look at the app, you may find out that the feature is unavailable to admin groups also, it is because by default the feature is deactivated to all groups or users. We can make a rake task or an interface for activating the feature to subset of users. Activating code looks like this:

``` ruby

  $rollout.activate_group(:chat, :admin)

```
This will activate the feature ( chat in our case ) for admin group.

Also we can activate the feature to all users or specific user or to some percentage.

``` ruby

  $rollout.activate_group( :chat, :all ) #activate to all, there is all group already by default

  $rollout.activate_user( :chat, User.find_by_email("admin@myapp.com") ) #activate to specific user

  $rollout.activate_percantage( :chat, 50 ) #activate to 50% of users

```

Each of these methods have deactivate version for deactivating the feature. You can also just call ``` $rollout.deactivate_all(:chat) ``` to deactivate the feature to all at once.
