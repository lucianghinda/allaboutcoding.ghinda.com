---
title: Archive
layout: default
permalink: /archive/
---

<section id="archive" class="container">
  <h1 class="my-3 text-3xl font-light tracking-tight text-gray-900 dark:text-white sm:text-4xl">
    Archive
  </h1>
  <hr class="h-1 mx-auto my-5 dark:border-white">

  {% for post in site.posts %}
    {% assign year = post.date | date: "%Y" %}
    {% if year != current_year %}
      {% unless forloop.first %}</ul>{% endunless %}
      {% assign current_year = year %}
      <h2 class="mt-8 mb-3 text-2xl font-bold text-stone-600 dark:text-stone-300">{{ year }}</h2>
      <ul>
    {% endif %}
    <li class="text-base list-inside pb-6">
      {% include post_link.html post=post %}
    </li>
    {% if forloop.last %}</ul>{% endif %}
  {% endfor %}
</section>
