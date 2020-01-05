---
layout: page
title: Blog Archives
---

<div>
  {% for post in site.posts reverse %}
    {% capture this_year %}{{ post.date | date: "%Y" }}{% endcapture %}
    {% unless year == this_year %}
      {% assign year = this_year %}
      <h2>{{ year }}</h2>
    {% endunless %}
    <article style="margin-left: 2rem">
      <h2><a href="{{ post.url | prepend:site.baseurl }}">{{post.title}}</a></h2>
      <time datetime="{{ post.date | datetime | date_to_xmlschema }}" pubdate>{{ post.date | date: "<span class='month'>%b</span> <span class='day'>%d</span>, <span class='year'>%Y</span>"}}</time>
    </article>
  {% endfor %}
</div>
