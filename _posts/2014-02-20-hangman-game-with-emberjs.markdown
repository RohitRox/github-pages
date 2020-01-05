---
layout: post
title: "Hangman Game with EmberJs"
date: 2014-02-20 18:00
comments: true
categories: [EmberJs, Javascript]
---

I built hangman game with emberjs, [quick prevew](http://rohitrox.github.io/hangman-with-ember). The game deals with more of view stuffs than other parts, I would like to share some thoughts and tricks I learned during the process.

![hangman game with emberjs](/images/hangman-ember.png)

I am not an ember expert so the way I have done may not be the optimal way of doing things in ember. Instead of walking through each steps, the code is well commented you can easily walk through, here I will describe striking stuffs.

<!-- more -->

### View and Controller back-and-forth

As you can see in the UI we have buttons with alphabets through which we capture user input. For this, I created my own input view that extended from Ember.TextField.

``` coffeescript
  # app/views/hangman_input.coffee
  App.HangmanInputView = Ember.TextField.extend
    type: "button"
    resetted: false
    didInsertElement: ->
      @get('targetObject').on('reset', $.proxy(@reset, @));
    click: ->
      value = @get('value')
      controller = @get('targetObject')
      controller.send('submit', value)
      if @resetted
        @set('resetted', false)
      else
        @toggleProperty('disabled')
    reset: ->
      @set('disabled', false)
      @set('resetted', true)
```

We get the current controller via ``` @get('targetObject') ``` then we can call action of controller with send.

We also need to be able to trigger view action 'reset' from the controller. The reset action resets the the input panel.

The trick is well described [here](http://stackoverflow.com/questions/15991871/ember-js-how-to-trigger-view-method-from-controller) using Ember.Evented mixin.

## Controller properties sortable

I have set scores in the setupConctroller of IndexRoute. What I want to do it, for each game session I create a Score model and push it to scores but I want to be auto sorted by latest 'id'. For this we can do something like this

``` coffeescript
  # app/routes/index.coffee
  App.IndexRoute = Ember.Route.extend
    model: ->
      # ...
      score = @store.createRecord('score',{value: 0})
      # sort scores by id desc so that latest score comes on top in UI
      scores = Ember.ArrayProxy.createWithMixins Ember.SortableMixin,
        content: [controller.current_score]
        sortProperties: ['id']
        sortAscending: false
      controller.set('scores', scores)
```


## Helpers Gotchas

I wrote a helper to display the green bars that represents the life.

``` coffeescript
  # app/helpers/life_blocks.coffee
  Ember.Handlebars.registerHelper "life_blocks", (n) ->
    accum = ""
    i = 0
    n = @get(n)
    while i < n
      accum += '<div></div>'
      ++i
    accum
    new Handlebars.SafeString(accum)
```

And from template we could do something like

{% raw %}
``` html
  <div class="life">
    {{ life_blocks life }}
  </div>
```
{% endraw %}
life is a property in the controller.

Now what happens is by default life here is not bound to the life property in controller. So the trick is register helper with  'Ember.Handlebars.registerBoundHelper'


Rest others are pretty straight forward.

I have used brunch with tapas-with-ember. I found brunch better than grunt.

I would love to hear feedback and corrections where necessary.



