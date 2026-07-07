---
layout: post
title: 'Ruby: Using .all? when the variable can be an empty array'
date: '2021-12-10 15:56:05 +0000'
slug: ruby-using-all-when-the-variable-can-be-an-empty-array
tags:
- ruby
- ruby-on-rails
- programming-tips
- til
- coding
description: |-
  Context
  You have an array of hashes and want to check if all elements are satisfying a condition.
  TIL
  You might want to do this in Ruby:
  objects.all? { _1[:amount] > 10 }

  In this case, you should remember according to with the documentation .all? mi...
image: "/assets/images/posts/ruby-using-all-when-the-variable-can-be-an-empty-array/lCgOk9Yur.png"
---

## Context

You have an array of hashes and want to check if all elements are satisfying a condition.

## TIL

You might want to do this in Ruby:

```ruby
objects.all? { _1[:amount] > 10 } 
```

In this case, you should remember according to [with the documentation](https://docs.ruby-lang.org/en/3.0.0/Enumerable.html) `.all?` might return true in this case:

```ruby
[].all? 
# returns true 
```  

So this thing might happen

```ruby
array = []

array.all? { _1[:amount] > 1}
# will return true

array.all? { _1[:this_key_does_not_exists] > 1}
# will return true
```

## Quick fix

Use 

```ruby 
array.present? && array.all? { _1[:key_does_not_exist] > 1}
```

Explanation: 

First check if the array is not empty and then try to apply the condition to all elements.
