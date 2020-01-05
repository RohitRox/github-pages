---
layout: post
title: "Canvas Images and Rails"
date: 2013-07-19 15:15
comments: true
categories: [Rails, Javascript]
---

With the introduction of Canvas, HTML5 has empower us to draw shapes, graphs, render texts, make gradients and patterns, manipulate images pixels, set an animations, even creating a stunning games!
All this stuffs occur on the client side in the browsers.
So let say you make an app that render some effects in a Canvas element and you want to allow user to take screenshot of the resut or save the result in your server for yourself.

Let's digg how can we do it and save that canvas as an image in ther server using Rails.

### Strategy 1 : Send canvas image as raw dataURL

The data URI scheme is a URI scheme that provides a way to include data in-line in web pages as if they were external resources. The ```canvas.toDataURL()``` method returns the image data of the canvas as Data URI. And the Data URI has the image data Encodes with MIME base64.

Let's see how it works. Copy and run this javascript snippet in your browser console. Somewhere at the bottom of the page you'll see a green circle.

``` javascript
  var canvas = document.createElement('canvas');
  var context = canvas.getContext('2d');
  var centerX = canvas.width / 2;
  var centerY = canvas.height / 2;
  var radius = 70;

  context.beginPath();
  context.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
  context.fillStyle = 'green';
  context.fill();
  context.lineWidth = 5;
  context.strokeStyle = '#003300';
  context.stroke();

  document.body.appendChild(canvas);
```
Now lets render that canvas as an image.

``` javascript
  var dataURL =  canvas.toDataURL('image/png');
  window.location = dataURL;
```

<!--more-->

As you can see, with that weird long url string something like ```data:image/png;base64,iVBORw0KGgoA...```, it render a png image. That long url is infact data uri which has image data encoded with MIME base64.

The format to be specific is *** data:[&lt;mime type&gt;][;charset=&lt;charset&gt;][;base64],&lt; encoded data &gt; ***.

Now, if we want to save that image in the server, we can just send that data uri as normal params and at the server, we can use ruby to decode that save that data as image file.

``` ruby
  require 'base64'

  data = params[:data_uri]
  # remove all extras except data
  image_data = Base64.decode64(data['data:image/png;base64,'.length .. -1])

  File.open("#{Rails.root}/public/uploads/somefilename.png", 'wb') do |f|
    f.write image_data
  end
```

### Strategy 2 : Send It as a Blob object

This method also use the dataURL but instead of send it as a raw text, we convert it to an image file object and send it.
For this we use the Blob object. Simply it's an object that represent a file-like object, so we create a blob object with the type PNG image, after we append this blob object to a FormData, and finally we send it through the jQuery Ajax Method.

Let's detail a bit what I say above, we already see how we get the dataURL from an object, the dataURL is only a raw text, so we need to decode it to a binary data, we already know that the type of the encoding in the dataURL is Base64, and for decode it using a JavaScript solution we use the predefined atob method, now after decoding it we get a binary data, and we need to convert it to an array where there element is a 8-bit unsigned integer values. Finally we have to put this array in a new Uint8Array object for pass it to our Blob object that represent our file, now let create a function that do this and convert our Canvas to a blob object:

``` javascript
  // Convert dataURL to Blob object
  function dataURLtoBlob(dataURL) {
    // Decode the dataURL
    var binary = atob(dataURL.split(',')[1]);
    // Create 8-bit unsigned array
    var array = [];
    for(var i = 0; i < binary.length; i++) {
        array.push(binary.charCodeAt(i));
    }
    // Return our Blob object
    return new Blob([new Uint8Array(array)], {type: 'image/png'});
  }
```

We can now create a new FormData object, put our file on it and send our data using Ajax.

``` javascript
  // Get our file
  var file= dataURLtoBlob(dataURL);
  // Create new form data
  var fd = new FormData();
  // Append our Canvas image file to the form data
  fd.append("image", file);
  // And send it
  $.ajax({
     url: "/screenshot",
     type: "POST",
     data: fd,
     processData: false,
     contentType: false,
  });
```

At controller:

``` ruby
  File.open("#{Rails.root}/public/uploads/somefilename.png", 'wb') do |f|
    f.write(params[:image].read)
  end
```

So, that's it.

This method is more appropriate and faster than the first one.

Those wondering how to mix this with carrierwave and paperclip, here are the links:

[Rails carrierwave base-64 encoded image upload](http://stackoverflow.com/questions/14900038/rails-carrierwave-iphone-base64-image-upload)

[Base64-encoded images with Paperclip](https://gist.github.com/WizardOfOgz/1012107)
