---
layout: post
title: How to get class name and module name in Ruby
date: '2022-10-06 04:07:03 +0000'
slug: how-to-get-class-name-and-module-name-in-ruby
tags:
- ruby
- ruby-on-rails
- learning
- coding
description: "How to get the class name\nTo get the class name:\nclass User\n  def
  call = puts self.class.name\nend\nUser.new.call #=> User\n\nThis will work even
  if the name is namespace inside a module: \nmodule Authenticated\n  class Visitor\n
  \   def call = puts self.cla..."
image: ''
last_modified_at: '2022-10-07 03:01:12 +0000'
---

# How to get the class name

To get the class name:

```ruby
class User
  def call = puts self.class.name
end
User.new.call #=> User
```

This will work even if the name is namespace inside a module: 

```ruby
module Authenticated
  class Visitor
    def call = puts self.class.name
  end
end
Authenticated::Visitor.new.call #=> Authenticated::Visitor
```

# How to get the module name

Will not work if you call `class.name`
```ruby
module Authenticated
  def self.call = puts self.class.name
end
Authenticated.call # will return Module!!
```

But Module defines an accessor named `name`
```ruby
module Visitors
  def self.call = puts self.name
end
Visitors.call # will return Visitors
```

Yes there is a constant `name` defined on a Module.

You can of course redefine that if you want:

```ruby
module Guest
  def self.name = "Another name"
  def self.call = puts self.name
end
Guest.call # will return "Another name"
```

# Bonus: How to get the current method name

Use `__method__` for that: 

```ruby
class Admin
  def call(...) = puts __method__
end
Admin.new.call # "call"
```
