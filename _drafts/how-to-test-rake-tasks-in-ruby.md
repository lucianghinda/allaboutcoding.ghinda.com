---
layout: post
title: How to test rake tasks in Ruby
date: '2023-06-28 09:50:28 +0000'
published: false
hashnode_draft_id: 649c02154d6e11000f45a572
---

I usually put all logic for my rake tasks into a PORO and do unit testing for that object. Most of my rake tasks are oneliners that pass arguments from the command line to an object. I found this strategy the best for me to work with rake tasks as I can only need to focus on simple Ruby objects.
