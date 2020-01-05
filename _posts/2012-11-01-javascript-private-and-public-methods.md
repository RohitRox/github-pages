---
layout: post
title: Javascript Private and Public methods
date: 2012-11-01 00:18
comments: true
categories: [Javascript]
---

## Objects and Classes

JavaScript is a prototype-based language which contains no class statement, such as is found in other object oriented languages. This is sometimes confusing for programmers accustomed to languages with a class statement. Instead, JavaScript uses functions as classes. Defining a class is as easy as defining a function. In the example below we define a new class called Person.
``` javascript
  function Person() { }
```
To create a new instance of an object new operator.
``` javascript
  my_person = new Person();
```
<!-- more -->
## Constructors

Every action declared in the class gets executed at the time of instantiation which can act like the constructor, used to set the object's properties or to call methods to prepare the object for use.
``` javascript
  function Person(first_name, last_name) {
    this.first_name = first_name;
    this.last_name = last_name;
    this.full_name = this.first_name + this.last_name;
    console.log(this.full_name + ' is instantiated.');
  }

```

## Methods

``` javascript
  // adding sayHello method to Person
  Person.prototype.sayHello = function()
  {
    alert ('Hello '+ this.full_name);
  };
```
## Private and Public

Common issue in JavaScript is that there is no true sense of private variables. However, we can use closures to somewhat simulate privacy.
``` javascript

  function Person(first_name, last_name) {

  var balance = 0.0;
  // balance is private and cannot be accessed from outside

  addBalance = function () {
  balance += 10;
  };
  // addBalance is private and cannot be accessed from outside

  this.first_name = first_name;
  this.last_name = last_name;
  this.full_name = this.first_name + this.last_name;
  // first_name, last_name, full_name  are public variables

  console.log(this.full_name + ' is instantiated.');

  this.viewBalance = function(){ alert(balance); }
  // viewBalance is public
  }

```
## Literal version fo creating Objects and defining Methods and Properties
``` javascript
  // Constructor version
  function myObject(){
    this.iAm = 'an object';
    this.whatAmI = function(){
      alert('I am ' + this.iAm);
    };
  };

  // Literal version
  var myObject = {
    iAm : 'an object',
    whatAmI : function(){
      alert('I am ' + this.iAm);
    }
  }
```
Literal is a preferred option for name spacing so that your JavaScript
code doesn’t interfere (or vice versa) with other scripts running on the
page and also if you are using this object as a single object and not requiring
more than one instance of the object, whereas Constructor function type
notation is preferred if you need to do some initial work before the object
is created or require multiple instances of the object where each instance
can be changed during the lifetime of the script.


For a literally notated object, you simply use it by referencing its variable name,whereas with constructor functions you need to instantiate (create a new instance of) the object first.


### Update:

JavaScript classes have been introduced in ECMAScript 2015, are primarily syntactical sugar over JavaScript's existing prototype-based inheritance. The class syntax however *does not* introduce a new object-oriented inheritance model to JavaScript.

Read more at [MDN web docs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes).
