---
layout: page
title: Categories
---

<div>
  {% for category in site.categories %}
    {% capture category_name %}{{ category | first }}{% endcapture %}
    <a href="#{{ category_name | slugify }}" class="post-tag" style="margin-bottom: 8px">{{ category_name }}</a>
  {% endfor %}
</div>

<div>
  {% for category in site.categories %}
    <div>
      {% capture category_name %}{{ category | first }}{% endcapture %}
      <h3 class="category-head" id="{{ category_name | slugify }}">{{ category_name }}</h3>
      {% for post in site.categories[category_name] %}
        <article style="margin-left: 2rem"  >
          <h4><a href="{{ post.url | prepend:site.baseurl }}">{{post.title}}</a></h4>
        </article>
      {% endfor %}
    </div>
  {% endfor %}
</div>
