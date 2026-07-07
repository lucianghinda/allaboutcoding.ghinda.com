---
layout: post
title: 'Rails: Where to add logic for broadcasting turbo commands?'
date: '2023-11-22 12:43:10 +0000'
published: false
hashnode_draft_id: 6538ff5a924c3a000f5b65e0
---

Based on this answer:
{% include embed/tweet.html url="https://twitter.com/lucianghinda/status/1717114282943389896" %}
Here is my suggestion (and it might be a bit controversial). It starts with the assumption that `app/views` can contain more than html/haml/erb files. It can contain Ruby objects. For example both ViewComponents and Phlex do this. Let's assume the name of your controller is **GalaxiesController** I would then put the logic under: **app/views/broadcasts/galaxies/create.rb** under the namespace `Broadcasts::Galaxies::Create` with a method called `perform` Here is my logic: - I don't usually like Presenter as it seems a too big namespace - I like to namespace as much as possible all logic and then have matching folders everywhere. So If I am searching for Galaxies related logic I know I can find it in app/\*/galaxies - If the logic is only about create and only about one controller I will make that explicit in the name or the name + namespace - I would put it in views as this is a transformation applied to views - I choose the name of the method `perform` to match the job naming because I see this broadcasting as a kind of job-like activity that happens after the response is rendered

```ruby
class MyObject
    def method(keyword:)
    end
end
```
