---
layout: post
title: How to decide to choose before_validation or before_save in Rails?
date: '2023-09-22 11:20:34 +0000'
published: false
hashnode_draft_id: 64e07895814e80000fc16f15
---

Let's explore the following objective:

* There is an Active Record model that has an attribute named `currency`
    
* We want to make sure that what is saved to DB is upper case, 3 letters string
    
* For this article let's say that the only point where this change should be done is in the AR model
    

There are at least 2 ways to achieve this that I am going to discuss in this article:

* using `before_validation`
    
* using `before_save`
    

Probably either one is fine, but I am going to try to explain a bit about what you should consider in a decision process

## Option A: using `before_validation`

## Option B: using `before_save`
