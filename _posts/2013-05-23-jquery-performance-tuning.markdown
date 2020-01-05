---
layout: post
title: "Jquery Performance Tuning"
date: 2013-05-23 15:35
comments: true
categories: [JQuery]
---

After searching and digging a lot of artciles about improving jquery performance in web apps, I decided to make a list of best common performance tips and bect practices. We'll also reveal some of JQuery's hidden feature and how we can use them for performance tuning.

Lets divide this post into 4 main categoris.

  - Selector Performace
  - DOM Manipulation
  - Events
  - Digging into JQuery Secrets
  - General and All-Time performance tricks

<!--more-->

## Selector Performace

#### Know your selectors

You should be careful about using jquery selectors because all selectors are nor created equally. With benchmarks, we can see:

``` javascript
  $('#id, element'); // Id and Element selectors are the fastest
  // the reason is because it maps to a native JavaScript methods
  $('.class_name'); // Slower class selectors
  $(':hidden, [attribute=value]'); // Pseudo and Attribute selectors are the slowest

```

#### Optimize selectors for Sizzle’s ‘right to left’ model

JQuery as of now uses the Sizzle Javascript Selector Library which works a bit differently from the selector engine used in the past versions. Namely it uses a ‘right to left’ model rather than a ‘left to right’. Make sure that your right-most selector is really specific and any selectors on the left are more broad:

``` javascript
  var linkContacts = $('.contact-links div.side-wrapper'); // Good
  var linkContacts = $('a.contact-links .side-wrapper'); // Bad

```

#### Keep it Simple!

Avoid overly complex selectors. Unless you have an incredibly complex HTML document, it’s rare you’ll need any more than two or three qualifiers.

``` javascript
  $("body #page:first-child article.main p#intro em"); // Bad
  $("p#intro em"); // Good

```

#### Class selectors and Context

Always try to scope your selectors with id or element.

```js
  $('.active').show(); // bad
  $('#header .active').show(); // better
  $('.active', '#header').show(); // better
  $('#header').find('.active').show(); // fastest
  // .find() is faster because it directly uses native javascript methods to search inside the passsed context under the hood
  $('button.active'); // fastest
  // grabs all matches tags FIRST, then iterates through them to find matching classes
```

## DOM Manipulation

#### Cache and Chains to Avoid Reselection

Interacting with the DOM as little as possible will drastically speed up your applications.

``` javascript
  // Bad
  $('#sidebar .promo').hide();
  $('#sidebar .newPromo').show();
  $('#sidebar').after(somethingcool);

  // Good
  var sb = $('#sidebar');
  sb.find('.promo').hide();
  sb.find('.newPromo').show();
  sb.after(somethingcool);

  // Bad
  $("p").css("color", "blue");
  $("p").css("font-size", "1.2em");
  $("p").text("Text changed!");

  // Good
  $("p").css({ "color": "blue", "font-size": "1.2em"}).text("Text changed!");
```

####  Wrap everything in a single element when doing any kind of DOM insertion

DOM manipulation is very slow. Try to modify your HTML structure as little as possible.

``` javascript
  var menu = '<ul id="menu">';
  for (var i = 1; i < 100; i++) {
      menu += '<li>' + i + '</li>';
  }
  menu += '</ul>';
  $('#header').prepend(menu);

  // Instead of doing:

  $('#header').prepend('<ul id="menu"></ul>');
  for (var i = 1; i < 100; i++) {
      $('#menu').append('<li>' + i + '</li>');
  }
```

## Events

#### Leverage Event Delegation

Event listeners cost memory. In complex websites and apps it’s not uncommon to have a lot of event listeners floating around, and thankfully jQuery provides some really easy methods for handling event listeners efficiently through delegation.

When you have a lot of elements in a container and you want to assign an event to all of them – use delegation to handle it. Delegation provides you with the ability to bind only one event to a parent element and then check on what child the event acted (target). It’s very handy when you have a big table with a lot of data and you want to set events to the TDs. Grab the table, set the delegation event for all the TDs:

``` javascript

  $("table").delegate("td", "hover", function(){

    $(this).toggleClass("hover");

  });

```

## Digging into JQuery Secrets

#### Element Creation

The following snippet is enough what I mean:

``` javascript

  var myDiv = jQuery('<div/>', {
    id: 'my-new-element',
    class: 'foo',
    css: {
      color: 'red',
      backgrondColor: '#FFF',
      border: '1px solid #CCC'
    },
    click: function() {
      alert('Clicked!');
    },
    html: jQuery('<a/>', {
      href: '#',
      click: function() {
        // do something
        return false;
      }
    })
  });

```

#### Writing own selectors

If you have selectors that you use often in your script – extend jQuery object $.expr[':'] and write your own selector.
In the following example We create a selector above_the_fold that returns a set of elements that are not visible:

``` javascript

  $.extend($.expr[':'], {
    above_the_fold: function(el) {
      return $(el).offset().top < $(window).scrollTop() + $(window).height();
    }
  });
  var nonVisibleElements = $('div:above_the_fold'); // Select the elements

```


#### CSS Hooks

The [CSS hooks API](http://api.jquery.com/jQuery.cssHooks/) was introduced to give developers the ability to get and set particular CSS values. Using it, you can hide browser specific implementations and expose a unified interface for accessing particular properties.

``` javascript

  $.cssHooks['borderRadius'] = {
    get: function(elem, computed, extra){
      // Depending on the browser, read the value of
      // -moz-border-radius, -webkit-border-radius or border-radius
    },
    set: function(elem, value){
      // Set the appropriate CSS3 property
    }
  };

  // Use it without worrying which property the browser actually understands:
  $('#rect').css('borderRadius',5);

```

What is even better, is that people have already built a rich [library of supported CSS hooks](https://github.com/brandonaaron/jquery-cssHooks) that you can use for free in your next project.


## General And All time tricks

<!--more-->


#### Use HTML5

You may wonder how jquery performance and HTML5 are related but the new HTML 5 standard comes with new tags and a lighter DOM structure in mind. Lighter DOM structure and different tags diferent purpose for means less elements to traverse for jQuery.


#### DOM isn't your database

Traversing DOM to retrieve information stored in .text(), .html() is not optimal approach. Use html5 data to attach any kind of information in DOM. With the recent updates to the jQuery data() method, HTML5 data attributes are pulled automatically and are available as entries.

``` html
  <div id="d1" data-role="page" data-page_hash="H4jk8s00">
  </div>

```

``` javascript
  $("#d1").data("role"); //page
  $("#d1").data("page_hash"); //H4jk8s00
```


#### Append style tag when styling 15 or more elements

When styling a few elements it is best to simply use jQuery’s css() method, however when styling 15 or more elements it is more efficient to append a style tag to the DOM instead of applying css to each items.

``` javascript
  $('<style type="text/css"> div.activated { color: red; } </style>').appendTo('head');

```

##### Always use the latest version

JQuery is always in constant development and improvement. The latest version always contains more bug fixes and performance improvements so it is always wise to keep upto date with the latest versions.

#### Combine jQuery with raw Javascript where needed

``` javascript
  $('#someAnchor').click(function() {
    alert( $(this).attr('id') );
  });

  $('#someAnchor').click(function() {
    alert( this.id );
  });

```

#### Load the framework from Google Code

I urge everyone to use the Google AJAX Libraries content delivery network to serve jQuery to users directly from Google’s network of datacenters. Doing so has several advantages over hosting jQuery on your server(s): decreased latency, increased parallelism, and better caching.

The only disadvantage is that if the connection to the CDN were to fail, our site would be left with no jQuery library which could be a big deal if we run a jQuery intensive website. If it happens then there should be some mechanism to fetch the library from other source or from our own locally hosted location. Fortunately, you can easily reference a backup. You can have a copy of jQuery on your server, and use a little bit of JavaScript to load it only if the Google one doesn’t load for some reason.
This little snippet, found in HTML5 Boilerplate, will do just that:

``` html
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script>
  <script>window.jQuery || document.write('<script src="js/libs/jquery-1.9.0.min.js"><\/script>')</script>
```
