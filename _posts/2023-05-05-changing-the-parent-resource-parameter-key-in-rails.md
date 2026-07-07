---
layout: post
title: Changing the Parent Resource Parameter Key in Rails
date: '2023-05-05 11:50:45 +0000'
slug: changing-the-parent-resource-parameter-key-in-rails
subtitle: tweaking the parent resource parameter key
tags:
- ruby
- ruby-on-rails
- rails
- programming-blogs
description: |-
  Today I wanted to achieve the following:
  Change the key for the parent resource when accessed in the nested resources
  # instead of
  /collections/:collection_id/entries

  # wanted article_id
  /collections/:article_id/entries

  I also wanted to have the En...
image: ''
---

Today I wanted to achieve the following:

**Change the key for the parent resource when accessed in the nested resources**

```bash
# instead of
/collections/:collection_id/entries

# wanted article_id
/collections/:article_id/entries
```

I also wanted to have the EntriesController scoped within the `Collections` module:

```ruby
# instead of 
class EntriesController
...
end

# wanted
class Collections::EntriesController
...
end
```

## What did not worked

I first tried to use the `param` option for the `resources`. See documentation [here](https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources)

```ruby
resources :collections, only: %i(show) param: :article_id do
  resources :entries, only: %i(index), module: :collections
end
```

But it does not work.

If you run `rails routes -g collections` you will notice the following response:

```bash
# route helper 
collection_entries

# HTTP route
GET /collections/:collection_article_id/entries

# controller
Collections::EntriesController
```

Notice `collection_article_id` inside the route `/collections/:collection_article_id/entries` which is not what I wanted:

```diff
- /collections/:collection_article_id/entries
+ /collections/:article_id/entries
```

## Solution: use `as`

The option `as` allows to change the route helper and it seems that this way Rails will also change the name of the param key when using nested resources.

```ruby
resources :collections, only: %i(show) as: :articles do
  resources :entries, only: %i(index), module: :collections
end
```

Will generate:

```bash
# route helper 
article_entries

# HTTP route
GET /collections/:article_id/entries

# controller
Collections::EntriesController
```

I am not sure if this is a bug or not in how the `param` option works.
