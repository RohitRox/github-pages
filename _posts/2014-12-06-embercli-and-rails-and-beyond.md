---
layout: post
title: "Ember Cli and Rails And Beyond"
date: 2014-12-06 16:44
comments: true
categories: [EmberJs, Rails]
---

### Ember Cli and Rails Setup

Rails setup is pretty staright forward with ``` rails new .. ``` and new ember cli app with ``` ember new .. ```  but with following folder configuration

```
  | embercli-rails-app
  |-- rails
  |-- ember
```
Inside of main project folder we'll have a folder which will contain the rails code and another folder which will contain ember code only.

We would like to have coffeescript.

For coffeescript

```
  npm install --save-dev ember-cli-coffeescript
```

and renaming .js files to .coffee and correcting the js syntax to coffee will do the trick.

Make sure that ember app is all well by using ``` ember server ``` and visiting http://localhost:4200.

Before proceeding, it would be nice to have some tests.

Lets create a new test at 'ember/tests/integration/home-page-test.coffee'.

``` coffeescript
  `import Ember from 'ember'`
  `import startApp from 'cli-app/tests/helpers/start-app'`
  `import Ember from 'ember'`

  App = null

  module 'Integration - Home Page',
    setup: ->
      App = startApp()
    ,
    teardown: ->
      Ember.run(App, 'destroy')

  test 'Should have Welcome test', ->
    visit('/').then ->
      equal(find('h2#title').text(), 'Welcome to Ember.js');
```

Visit http://localhost:4200/tests to run the tests.

<!-- more -->

### Rails Api

Let's quickly build an api that can be consumed by our ember app. We are skipping out the tests.

```
  rails g model post title:string body:text
  rake db:create db:migrate db:seed
  rails g serializer post
```
We are going to make our api under api namespace so routes and controllers are as follows:


```ruby
  # config/routes.rb
  namespace :api do
    resources :posts
  end
```

```ruby
  # app/controllers/api/posts_controller.rb
  class Api::PostsController < ApplicationController
    def index
      render json: Post.all
    end

    def show
      render json: Post.find(params[:id])
    end
  end
```
Boot rails server and make sure api is working using curl command `curl http://0.0.0.0:3000/api/posts` and see if it outputs json data.

### Ember Data and stuffs

First, create ember model for Post model.

```
  ember generate model post title:string body:string
```

Then setup routes and templates.

``` coffeescript
  # app/router.coffee
  Router.map ->
    @resource 'posts'

```
{% raw %}
``` html
  # app/templates/posts.hbs
  <h3>Listing All Posts:</h3>
  <ul>
  {{ #each }}
    <li>{{ title }}</li>
  {{ /each }}
  </ul>
```
{% endraw %}
Finally, let's setup the adapter.

``` coffeescript
  # ember/app/adapters/application.coffee
  `import DS from 'ember-data'`

  ApplicationAdapter = DS.ActiveModelAdapter.extend
    namespace: "api"

  `export default ApplicationAdapter`
```

Now let's fire the ember server and visit http://localhost:4200/posts.
Nothing happens! In console we can see that there was request was made on url http://localhost:4200/api/posts.
We need a way to redirect this resource to rails app.

This can be fixed by one line using ember server with proxy enabled.
```
  ember server --proxy http://localhost:3000
```

### More Tests

Let's try to test this new posts page feature. In test we cannot hit rails server to get posts so we will use a tool called [Pretender](https://github.com/trek/pretender) to mock the request-response.

```
  npm install --save-dev ember-cli-pretender
  ember generate ember-cli-pretender
```

Our test setup and test would be something like below:

``` coffeescript
  # tests/integration/posts-page-test.coffee
  `import Ember from 'ember'`
  `import startApp from 'cli-app/tests/helpers/start-app'`
  `import Ember from 'ember'`
  `import Pretender from 'pretender'`

  App = null

  module 'Integration - Posts Page',
    setup: ->
      App = startApp()
      posts = [
        {
          id: 1,
          title: 'Posts 1'
        },
        {
          id: 2,
          title: 'Posts 2'
        }
      ]
      # pretender for faking ajax request
      server = new Pretender ->
        @get '/api/posts', (request) ->
          [200, {"Content-Type": "application/json"}, JSON.stringify({posts: posts})]
    ,
    teardown: ->
      Ember.run(App, 'destroy')

  test 'Should display posts', ->
    visit('/').then ->
      click('a').then ->
        equal(find('h3').text(), 'Listing All Posts:');
        equal(find('li:contains("Posts 1")').length, 1);
        equal(find('li:contains("Posts 2")').length, 1);

```
Visit http://localhost:4200/tests to run the tests.

### Integration and Deployment

We would like to compile and move the ember-cli produced css and js files to rails in production environment. This little script helps us to automate this task:

``` shell

  #!/bin/bash
  # Based on https://github.com/knomedia/ember-cli-rails/blob/master/build.sh

  function printMessage {
    color=$(tput setaf $1)
    message=$2
    reset=$(tput sgr0)
    echo -e "${color}${message}${reset}"
  }

  function boldMessage {
    color=$(tput setaf $1)
    message=$2
    reset=$(tput sgr0)
    echo -e "${color}*************************************${reset}"
    echo -e "${color}${message}${reset}"
    echo -e "${color}*************************************${reset}"
  }

  cd cli-app
  boldMessage 4 "Building Ember app"

  ember build --environment production
  cd ../rails/

  rm -rf public/ember-assets

  printMessage 4 "Copying ember build files to rails"
  cp -r ../cli-app/dist/ public/

  printMessage 4 "Swaping assets dir for ember-assets"
  mv public/assets public/ember-assets

  printMessage 4 "Replacing references s/assets/ember-assets/ in public/index.html"
  sed -i .bck s/assets/ember-assets/ public/index.html

  printMessage 4 "inserting csrf_meta_tags in head"
  sed -i .bck 's/<\/head>/<%= csrf_meta_tags %>&/' public/index.html

  printMessage 4 "inserting yield in body"
  sed -i .bck 's/<body>/&<%= yield %>/' public/index.html

  printMessage 4 "Replacing application.html.erb with index.html"
  mv public/index.html app/views/layouts/application.html.erb

  printMessage 4 "Cleaning Up"
  rm -rf public_bk/
  rm public/index.html.bck

  boldMessage 4 "Done"
```

Now, we can shutdown ember server and visit localhost:3000, we can still see our ember app there.

To deploy our app we need to deploy our rails app only. We can put out both frontend and backend in single repo or in different repo. I have put both in a single [repo](https://github.com/RohitRox/embercli-rails). Do ``` config.serve_static_assets = true ``` in production.rb We can deploy like any other rails app. I have deployed this app to [heroku](https://embercli-rails.herokuapp.com/posts). One gotcha is that heroku expects the app directory structure at the root of the repository. So to deploy we will have to push differently:
```
  $ git subtree push --prefix rails heroku master
```
