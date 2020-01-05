---
layout: post
title: "Lets learn to knockout"
date: 2013-08-18 23:55
comments: true
categories: [Javascript, KnockoutJs]
---

Knockout.js is known for rapid and responsive UI development. Lets try it to build something today.
Lets see quick [demo](http://rohitrox.github.io/knockoutjs_projects) of what we are going to build.

[Download Source](https://github.com/RohitRox/knockoutjs_projects/archive/master.zip)

This is a basic table that is used in bills or receipts. We will try to add some magic to table like autocomplete, automatic information fill up of selected item and calculation of amounts with the help of knockout.

I will not describe what knockout.js is and why use it.
[Learn.knockout.js](http://learn.knockoutjs.com) has an excellent
tutorial for knockout js beginners. I strongly suggest to go through
learn.knockoutjs.com before proceeding.

I assume basic understanding of knockout js from here.

Let's setup the files first. Nothing fancy, I have just used jquery source file and knockout source js from their official websites and I have used twitter bootstrap prettifying stuffs.

I have initial table markup, which looks like as shown below:

``` html
  <div class="container">
    <div class="row">
      <div class="span12">
        <table class="table table-bordered">
          <thead>
            <tr>
              <th>Item</th>
              <th>Description</th>
              <th>Unit Price</th>
              <th>Quantity</th>
              <th>Amount</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><input class="span3"  /></td>
              <td><input class="span4" /></td>
              <td><input class="span1" /></td>
              <td><input class="span1" /></td>
              <td><input class="span1" /></td>
              <td><button class="btn">Remove</button></td>
            </tr>
          </tbody>
        </table>
        <p class="pull-left">
          <button class="btn">Add New Row</button>
          <button class="btn">Save</button>
        </p>
        <h4 class="pull-right">
          <strong>Grand Total: <span></span> </strong>
        </h4>
      </div>
    </div>
  </div>
```
Lets see what we have upto here and talk something about what we are trying to do to this table.

![knockout table 1](/images/knockout-table-1.png)

Lets summarize the behaviours we would like to have:

- Add a new row
- Suggest items in item field
- Fill up the item information (description and price) automatically
- Calculate the grand total as items are added
- A remove button to remove item and re-compute grand total automatically on removal

<!-- more -->

Lets assume that we are provided with items json like given below: (we'll not dicuss how come these jsons)

```js
  var items_json = [
    {sn: 1,'item_name':'Appy Fruit Juice', unit_price:45, description: 'Apple falvoured fruit juice', quantity: 2},
    {sn: 2,'item_name':'Cadbury Dairy Milk', unit_price:70, description: 'Cadbury Chocolate', quantity: 5},
    {sn: 3,'item_name':'Good Day Biscuit', unit_price:20, description: 'Biscuit', quantity: 10},
    {sn: 3,'item_name':'Tiger Crunch Biscuit', unit_price:10, description: 'Glucose biscuit with choco chips', quantity: 1}
  ];
```
The json is self explanatory, contains an array of items ( which we assume will be provided by some server-side operation ).

Now our first step, lets create the item model, comments are there to help you out.

``` javascript
  function Item(item){
    var self = this;
    // sets default value of name to ''
    self.item_name = '';
    // sets default description of name to '' but description is observable
    self.description = ko.observable('');
    self.unit_price= ko.observable(0);
    self.quantity = ko.observable(1);
    // automatic setting of attributes
    for(var k in item)
      self[k] = ko.observable(item[k]);
  }
```

Next, lets write out ItemViewModel.

``` javascript
  function ItemViewModel(data) {
    var self = this;
    // loop over the argument data and create a observableArray of new Item and assign array as items of ItemViewModel
    self.items = ko.observableArray(ko.utils.arrayMap(data, function(item) {
      return new Item(item);
    }));
  }
```

And finally, apply our bindings.

``` javascript
  $(function(){
    var view_instance = new ItemViewModel(items_json);
    ko.applyBindings(view_instance);
  });
```

For this to work, we first need to add data bindings to out table. Our table now becomes

``` html
  <table class="table table-bordered">
    <thead>
      <tr>
        <th>Item</th>
        <th>Description</th>
        <th>Unit Price</th>
        <th>Quantity</th>
        <th>Amount</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody data-bind='foreach: items'>
      <tr>
        <td><input class="span3" data-bind="value: item_name"/></td>
        <td><input class="span4" data-bind="value: description"></td>
        <td><input class="span1" data-bind="value: unit_price"></td>
        <td><input class="span1" data-bind="value: quantity"></td>
        <td><input class="span1"></td>
        <td><button class="btn">Remove</button></td>
      </tr>
    </tbody>
  </table>
```

Now, if we run in browser, we'll get the json data populated in the table. But still the amount field and grand total are empty. Lets fix them.

To compute those, we'll add amount method to Item model, that will calculate amout (price * quantity) for corresponding model and grand total method to ItemViewModel for calculating grand total of all items.

``` javascript
  function ItemViewModel (data) {
    var self = this;
    self.items = ko.observableArray(ko.utils.arrayMap(data, function(item) {
      return new Item(item);
    }));

    self.grand_total = function(){
      var sum = 0;
      self.items().forEach(function(i){
          sum += i.amount();
      });
      return sum;
    };
  }

  function Item(item){
    var self = this;
    self.item_name = '';
    self.description = ko.observable('');
    self.unit_price= ko.observable(0);
    self.quantity = ko.observable(1);

    for(var k in item)
      self[k] = ko.observable(item[k]);

    self.amount = ko.computed(function(){
      return self.quantity() * self.unit_price();
    });
  }
```

And the markup

``` html
  <table class="table table-bordered">
    <thead>
      ...
    </thead>
    <tbody data-bind='foreach: items'>
      <tr>
        <td><input class="span3" data-bind="value: item_name" /></td>
        <td><input class="span4" data-bind="value: description"></td>
        <td><input class="span1" data-bind="value: unit_price"></td>
        <td><input class="span1" data-bind="value: quantity"></td>
        <td><input class="span1" data-bind="value: amount()"></td>
        <td><button class="btn">Remove</button></td>
      </tr>
    </tbody>
  </table>
  <p class="pull-left">
    <button class="btn">Add New Row</button>
    <button class="btn">Save</button>
  </p>
  <h4 class="pull-right">
    <strong>Grand Total: <span data-bind="text: grand_total()"></span> </strong>
  </h4>
```

Note, grand_total is straight forward but amount is computed, an operation on quantity and unit_price, which are observables, this will do the magic of automatic managing the calculations of amount and grand total for us. You can try by changing values of price or quantity.

Also, note grand_total is called from outside the foreach binding, and thus will be found in ItemViewModel and amount is called inside the loop, thus will call the model method.

Now, lets do the add, remove and save part. For save, we wont do any server-side stuffs but alert the raw json output which would be sent to server.

We'll add these methods to ItemViewModel.

``` javascript
  self.addItem = function(){
    self.items.push(new Item());
  };

  self.removeItem = function(item){
    self.items.remove(item);
  };

  self.save = function(){
    alert(ko.toJSON(self));
  };
```
And markup:

``` html
  ...
  <button class="btn" data-bind="click: $root.removeItem">Remove</button>
  ...
  <button class="btn" data-bind="click: addItem">Add New Row</button>
  <button class="btn" data-bind="click: save">Save</button>
  ...
```
The post is getting too long, so I am just escaping other markups and presenting on ones where we need to change.
As the methods are in ItemViewModel, the add and save button would work, but remove button being inside the loop, will have to do $root.removeItem . Being called inside loop, removeItem will get the corresponding model as its argument.

Now, if we run in the browser, magicaly we have all the functionality. The items being observableArray, the table is automtically updated when items are added or deleted.

We have not written any click bindings, as we would normally do using jquery nor DOM manipulation, just few data-bind and knockout observables, knockout knocks it all out.

That's all for this post.

In next part, We'll add bootstrap's typeahead or autocomplete feature and implement technique for updating the information of item selected via autocomplete.
