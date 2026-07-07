---
layout: post
title: 'Active Record: How to select rows based on the number of items in an array
  column (PostgreSQL)'
date: '2021-12-16 04:51:50 +0000'
slug: active-record-how-to-select-rows-based-on-the-number-of-items-in-an-array-column-postgresql
tags:
- ruby
- ruby-on-rails
- postgresql
- sql
- coding
description: "Context\nYou have a column in your table that is used as an  array ,
  like this: \n t.string 'ids', array: true\n\nAnd you want to select all records
  that have more than N elements in the array\nSolution\nIn PostgreSQL, you can use
  \ cardinality  to achieve ..."
image: ''
---

## Context

You have a column in your table that is used as an  [array](https://guides.rubyonrails.org/active_record_postgresql.html#array) , like this: 

```ruby
 t.string 'ids', array: true
```

And you want to select all records that have more than N elements in the array

## Solution

In PostgreSQL, you can use  [`cardinality`](https://www.postgresql.org/docs/current/functions-array.html)  to achieve this:

```
Model.where("cardinality(ids) > 5")
```
