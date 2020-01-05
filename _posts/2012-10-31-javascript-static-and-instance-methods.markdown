---
layout: post
title: "Javascript Static and Instance methods"
date: 2012-10-31 23:05
comments: true
categories: [Javascript]
---

Custom JavaScript objects can have instance methods (function that are associated with a particular JavaScript object), but like other Object-Oriented languages, they can also have *static* methods, that is functions that are associated with the JavaScript class that created an object, as opposed to the object itself. This is useful in cases where a function (a.k.a. a method) will not be different in different object instances.
<!-- more -->
An instance method could be added to this class in one of two ways, either inside the constructor or through the class prototype.
``` javascript
  function Calculator() {
    // instance method in constructor
    this.multiply = function(val1 , val2) {
      return (val1*val2);
    }
  }

  // instance method via prototype
  Calculator.prototype.add = function(val1 , val2) {
    return (val1+val2);
  }

  // calling
  var calc = new Calculator();
  alert( calc.multiply(4,3) );
  alert( calc.add(4,3) );
```
However, it shouldn’t really be necessary to create an object to use the multiply or add method, since the method isn’t dependent on the state of the object for its execution. The method can be moved to the class to clean up this code a bit. First the class definition is created, which looks almost identical to the instance method declaration above, with the exception of the prototype keyword being removed:

``` javascript
  function Calculator() {
    ...
  }

  Calculator.multiply = function(val1 , val2) {
    return (val1*val2);
  }
```
Now the multiply method can be called through the class itself, instead of an instance of the class, like so:
``` javascript
  alert( Calculator.multiply(4,3) );
```
