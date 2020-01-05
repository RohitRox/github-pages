---
layout: post
title: "Ruby Dynamic Methods"
date: 2013-07-02 11:27
comments: true
categories: [Ruby, Metaprogramming]
---

We define methods using ***def*** keywords which is fine for most of the cases.

But consider a situation where you have to create a series of methods all of which have the same basic structure and logic then it seems repititive and not dry.

Ruby, being a dynamic language, you can create methods on the fly.

So, what does that mean?

lets see this simplest example:

``` ruby

  class A
    define_method :a do
      puts "hello"
    end

    define_method :greeting do |message|
      puts message
    end
  end

  A.new.a #=> hello
  A.new.greeting 'Ram ram' #=> Ram ram

```

<!--more-->


The ***define_method*** defines an instance method in the receiver. The syntax and usage are self-explained in the example above.

lets see following example that may be useful in practical scenarios.

``` ruby

  class User

    ACTIVE = 0
    INACTIVE = 1
    PENDING = 2

    attr_accessor :status

    def active?
      status == ACTIVE
    end

    def inactive?
      status == User::INACTIVE
    end

    def pending?
      status == User::PENDING
    end

  end

  user = User.new
  user.status = 1

  user.inactive?
  #=> true
  user.active?
  #=> false

```

Refactored code using dynamic method definition:

``` ruby

  class User

    ACTIVE = 0
    INACTIVE = 1
    PENDING = 2

    attr_accessor :status

    [:active, :inactive, :pending].each do |method|
      define_method "#{method}?" do
        status == User.const_get(method.upcase)
      end
    end

  end

  user = User.new
  user.status = 1

  user.inactive?
  #=> true
  user.active?
  #=> false

```
We use define_method to define method dynamically.

We can also define instance methods with a class method, using this technique we can expose a class method that will generate the  instance methods. COOL !

Example:

``` ruby
  class User

    ACTIVE = 0
    INACTIVE = 1
    PENDING = 2

    attr_accessor :status

    def self.states(*args)
      args.each do |arg|
        define_method "#{arg}?" do
          self.status == User.const_get(arg.upcase)
        end
      end
    end

    states :active, :inactive, :pending
  end


```

Now, what about class methods. The simplest way is

``` ruby
    class A
      class << self
        define_method method_name do
          #...
        end
      end
    end

```
There are ***instance_eval*** and ***class_eval*** also, which are used for dynamic method definition. These methods allow you to evaluate arbitrary code in the context of a particular class or object. These methods can be very confusing sometimes. You can read [this](http://stackoverflow.com/questions/900419/how-to-understand-the-difference-between-class-eval-and-instance-eval) discussion and [this](http://www.ploughthroughruby.co.uk/2009/09/30/define_method-instance_eval-and-class_eval.html/) blog post and understand how they can be used.


From that discussion, we summerize

``` ruby
  Foo = Class.new
  Foo.class_eval do
    def class_bar
      "class_bar"
    end
  end
  Foo.instance_eval do
    def instance_bar
      "instance_bar"
    end
  end
  Foo.class_bar       #=> undefined method ‘class_bar’ for Foo:Class
  Foo.new.class_bar   #=> "class_bar"
  Foo.instance_bar       #=> "instance_bar"
  Foo.new.instance_bar   #=> undefined method ‘instance_bar’ for #<Foo:0x7dce8>
```

Note that, we don't use ***define_method*** inside *_eval, becasue it does not matter if you use define_method inside class_eval or instance_eval it would always create an instance method.

And, we get this:

``` ruby
  Foo = Class.new

  Foo.class_eval do
    define_method "class_bar" do
      "class_bar"
    end
  end

  Foo.instance_eval do
    define_method "instance_bar" do
      "instance_bar"
    end
  end

  Foo.class_bar #=> undefined
  Foo.new.class_bar #=> "class_bar"
  Foo.instance_bar #=> undefined
  Foo.new.instance_bar #=> "instance_bar"

```

Next, we can invoke methods dynamically. One way to invoke a method dynamically in ruby is to send a message to the object. We can send a message to a class either within the class definition itself, or by simply sending it to the class object like you’d send any other message. This can be accomplished by usin ***send***.

The simplest example could be:

``` ruby

  s= "hi man"

  p s.length #=> 6
  p s.include? "hi" #=> true

  p s.send(:length) #=> 6
  p s.send(:include?,"hi") #=> true

```

How can this be ever useful?

Lets see the following code( example taken from [here](http://www.funonrails.com/2011/12/dynamic-methods-inside-ruby-classes.html))


``` ruby

  class ApplicationController < ActionController::Base
    protect_from_forgery
    helper_method :current_staff, :current_employee, current_admin

    def authenticate_staff!(opts={})
      current_staff || not_authorized
    end

    def current_staff
      current_user if current_user.is_a? Staff
    end

    def authenticate_employee!(opts={})
      current_employee || not_authorized
    end

    def current_employee
      current_user if current_user.is_a? Employee
    end

    def authenticate_admin!(opts={})
      current_admin || not_authorized
    end

    def current_admin
      current_user if current_user.is_a? Admin
    end
  end

```

And refactored one:

``` ruby
  %w(Staff Employee Admin).each do |k|
    define_method "current_#{k.underscore}" do
      current_user if current_user.is_a?(k.constantize)
    end

    define_method "authenticate_#{k.underscore}!" do |opts={}|
      send("current_#{k.underscore}") || not_authorized
    end
  end
```

Dynamically defined methods can help guard against method definition mistakes, avoid repetitive codes and be concise and smart.

Happy Metaprogramming.
