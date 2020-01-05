---
layout: post
title: "Single Table Inheritance in Mongoid"
date: 2013-08-30 14:04
comments: true
categories: [Rails, Mongoid]
---

Single table inheritance is a software pattern described by Martin Fowler. STI is basically an idea of using a single table(colection in case of mongo) to reflect multiple models that inherit from a base model.

We use STI pattern when we are dealing with classes that have same attributes and behaviour. Rather than duplicate the same code over and over, STI helps us to use a common base model and write specific behaviours in its inherited class while keeeping data on a same table.

Mongoid supports inheritance in both root and embedded documents. In
scenarios where documents are inherited from their fields, relations, validations and scopes get copied down into their child documents, but not vice-versa.

A very simple example:

``` ruby
  class Employee
    include Mongoid::Document
    field :name, type: String
    field :employee_code, type: Integer
  end

  class FullTimeEmployee < Employee
    field status, type: String, default: "Temporary"
  end

  class InternEmployee < Employee
    field intern_period, type: Integer
  end
```

<!-- more -->

In the above example, both FullTimeEmployee and InternEmployee will be saved in the Employee collection. An additional attribute _type is automatically stored in order to make sure when loaded from the database the correct document is returned.

Following behaviour can be seen, much similar to Single Table Inheritance in ActiveRecord.

``` ruby
  emp1 = Employee.new
  emp2 = FullTimeEmployee.new
  emp3 = InternEmployee.new

  Employee.count
  #=> 3
  FullTimeEmployee.count
  #=> 1
  InternEmployee.count
  #=> 1
  emp1._type
  #=> "Employee"
  emp2._type
  #=> "FullTimeEmployee"
  emp3._type
  #=> "InternEmployee"

  Employee.where(name: "...")
  #=> Returns Employee documents and subclasses
  FullTimeEmployee.where(name: "...")
  #=> returns only FullTimeEmployee documents
```

An advance example:

``` ruby
  class Canvas
    include Mongoid::Document
    field :name, type: String
    embeds_many :shapes
  end

  class Browser < Canvas
    field :version, type: Integer
    scope :recent, where(:version.gt => 3)
  end

  class Firefox < Browser
  end

  class Shape
    include Mongoid::Document
    field :x, type: Integer
    field :y, type: Integer
    embedded_in :canvas
  end

  class Circle < Shape
    field :radius, type: Float
  end

  class Rectangle < Shape
    field :width, type: Float
    field :height, type: Float
  end
```

Canvas, Browser and Firefox will all save in the canvases collection.This also holds true for the embedded documents Circle, Rectangle, and Shape.

To query for subclasses within an embedded collection you need to leverage the _type attribute in each subclassed object. Canvas and Shape documents, would not have it, but Browser, Firefox, Circle, and Rectangle would. Keep in mind that _type is a string that stores the name of the document's class, and as such can only be used to query for a specific subclass, and not anything it is a subclass of.

If, for example, Rectangle was a subclass of Parallelogram which was in turn a subclass of Shape, you could search the Canvas's shapes collection for objects with a _type of "Parallelogram" but it would never return a Rectangle object, and vice-versa.

``` ruby
  # Returns all the Rectangle shapes in a previously found Canvas
  my_canvas.shapes.where(_type: "Rectangle")

  # Returns no entries (see above)
  my_canvas.shapes.where(_type: "Shape")

  # Returns all the Canvasas that have Circles
  Canvas.where("shapes._type"=>"Circle")

  # Returns no entries (see above)
  Canvas.where("shapes._type'=>"Shape")
```
