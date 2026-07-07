---
layout: post
title: If I start a new Rails app, I would pick these gems
subtitle: A list of gems that I would use in 2023 if I would start a new Rails app
date: '2023-02-08 08:00:35 +0000'
published: false
hashnode_draft_id: 63e3542d9da24c0008533f31
---

If I would start a new Rails app here are some gems that I would include from the beginning with a very short why explanation

[**Dry Validation**](https://dry-rb.org/gems/dry-validation)

I would choose this because:

* It is expressive and more powerful than strong params: does not only validations but also type coercion
    
* It uses underhood [dry-schema](https://dry-rb.org/gems/dry-schema) and thus params schemas can be re-used between models
    
* It makes defining more complex rules simple and for me it has a kind of explicitness that I like
    

A small warning: it takes a bit of time to get used with displaying in forms the errors from dry-validation when creating/updating a resource.
