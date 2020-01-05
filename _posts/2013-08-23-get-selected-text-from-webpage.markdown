---
layout: post
title: "Get Selected text from a Web Page"
date: 2013-08-23 14:03
comments: true
categories: [Javascript, JQuery]
---

This is a quick tip you can use for getting the selected text from your webpage.

``` html
  <p>I am not selectable. You can test.</p>
  <div id="here">
      How about selecting me. Try me.
  </div>
```

``` javascript
  $(document).ready(function() {

    function getSelectedText(){
        var text = "";
        if (window.getSelection) {
            text = window.getSelection();
        } else if (document.getSelection) {
            text = document.getSelection();
        } else if (document.selection) {
            text = document.selection.createRange().text;
        }
        return text;
    }

    $('#here').bind("mouseup", function(){
        alert(getSelectedText());
    });

  });
```
