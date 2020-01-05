---
layout: post
title: "Javascript Array Tricks"
date: 2013-09-05 12:07
comments: true
categories: [Javascript]
---
JavaScript, at its base, is a very simple language. Due to burst of Js framework usage, in which many new developers jumps right into, there are very useful basic JavaScript techniques and tricks which many people are unaware of.

Today I want share some tricks with Javascript Arrays, which many developers are not using.

### Cloning Array

``` javascript
  var a = [1,2,3];
  var b = a;
  // bad
  // why

  a.pop();
  console.log(b);
  //=> [1,2]

  var b = a.slice(0);
  a.pop();
  console.log(b);
  //=> [1,2,4]
  // Good :-)
```

<!-- more -->

### Sorting

``` javascript
  var a = [1,4,2,3];
  console.log(a.reverse());
  //=> [3,2,4,1]
  console.log(a.sort());
  //=> [1,2,3,4]

  // Sort is more powerful than we think
  // sort descending
  console.log(a.sort(function(a,b){  return (b-a); }));
  //=> [4,3,2,1]
```

 Array.sort() accepts an optional parameter in the form of a function, which accepts two paramameters. The array elements can sorted based on the relationship between each pair of elements "a" and "b" and the function's return value.

 The three possible return numbers are:

+ Less than 0: Sort "a" to be a lower index than "b"
+ Zero: "a" and "b" should be considered equal, and no sorting performed.
+ Greater than 0: Sort "b" to be a lower index than "a".

This enables us to to an array of objects also.

``` javascript
  var employees=[]
  employees[0]={name:"George", age:32, retiredate:"March 12, 2014"}
  employees[1]={name:"Edward", age:17, retiredate:"June 2, 2023"}
  employees[2]={name:"Christine", age:58, retiredate:"December 20, 2036"}
  employees[3]={name:"Sarah", age:62, retiredate:"April 30, 2020"}

  // Sort by employee age

  employees.sort(function(a, b){
    return a.age-b.age
  });

  // Sort by employee name

  employees.sort(function(a, b){
      var nameA=a.name.toLowerCase(), nameB=b.name.toLowerCase()
      if (nameA < nameB) //sort string ascending
          return -1
      if (nameA > nameB)
      return 1
      return 0 //default return value (no sorting)
    });

  // Sort by date (retirement date)

  employees.sort(function(a, b){
    var dateA=new Date(a.retiredate), dateB=new Date(b.retiredate)
        return dateA-dateB //sort by date ascending
    });
  });
```

We can even use it to randomize an array.

``` javascript
  //Randomize the order of the array:
  var myarray=[25, 8, "George", "John"]
  myarray.sort(function() {return 0.5 - Math.random()}) //Array elements now scrambled
```

###  Array Length for Truncation

``` javascript
  var a = b = [1, 2, 3];

  a = [];

  // caught by JavaScript's pass-objects-by-reference nature
  // :-(  a is still [1,2,3]

  a.length = 0;
  // :-) // a and b both []
```

### Array Merging

We can merge arrays with the push method.

``` javascript
  var a = [1,2,3];
  var b = [4,5];

  // Array.prototype.push.apply(mergeTo, mergeFrom);

  Array.prototype.push.apply(a, b);

  // a is [1,2,3,4,5]
```

### Checking existence of element

``` javascript
  a = [1,2,3];
  // use indexOf method, returns a value greater that -1 if the element existes
  if (arr.indexOf(3) > -1){
      console.log('exists');
  } else{
      console.log('does not exist');
  }
```

### Remove Array element by Index

``` javascript
  test = new Array();
  test[0] = 'Apple';
  test[1] = 'Ball';
  test[2] = 'Cat';
  test[3] = 'Dog';

  // array.splice(index,1);

  // lets remove index 2

  popped = test.splice(2,1);
  // test is ['Apple', 'Ball', 'Dog']
  // popped is ['Cat']
```

More about splice [here](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/splice).

