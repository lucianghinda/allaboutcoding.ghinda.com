---
layout: post
title: How to define constants in Ruby using Sorbet
date: '2024-08-18 09:47:41 +0000'
published: false
hashnode_draft_id: 66c0b44098c1e5718ffa9716
---

Let's talk about how to define Ruby constants using [Sorbet](https://sorbet.org).

## Basic types

The following objects from Ruby when used as value for constants does not need to be declared with their type as it will be infered by Sorbet:

* `Integer`
    
* `Float`
    
* `Numeric`
