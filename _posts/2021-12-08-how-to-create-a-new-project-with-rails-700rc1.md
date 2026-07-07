---
layout: post
title: How to create a new project with Rails 7.0.0.rc1
date: '2021-12-08 16:20:22 +0000'
slug: how-to-create-a-new-project-with-rails-700rc1
subtitle: Or with any pre-release version
tags:
- ruby
- ruby-on-rails
- newbie
- programming-languages
description: Quick tip about how to create a new rails project with a pre-release
  version of rails
image: "/assets/images/posts/how-to-create-a-new-project-with-rails-700rc1/p2cv4Or_3.png"
last_modified_at: '2021-12-08 16:22:34 +0000'
---

In case you want to start a new project with Rails 7.0.0.rc1 (or any other alpha or Rc release) here is how to do this very simple:

1. Install the new version of the gem with

```
gem install -v 7.0.0.rc1 rails
``` 

2. Create a new project by specifying the version like this:

```
rails _7.0.0.rc1_ new rails7_example
```

Done 👏 

Now you can start coding
