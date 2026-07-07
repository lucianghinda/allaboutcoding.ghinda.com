---
layout: post
title: What to raise when you want to implement an abstract method in Ruby?
date: '2023-10-22 06:47:06 +0000'
published: false
hashnode_draft_id: 6534a6cca98f1a0010f1af3f
---

## Context

You want to create a base class and then make sure that any subclass will implement a method.

You think about writing something like this:

```ruby
class Galaxy
  def describe
    raise NotImplementedError # or maybe NoMethodError
  end
end

class MilkyWay < Galaxy
  def describe
    puts "The Milky Way is the galaxy that contains our Solar System."
  end
end

class AndromedaGalaxy < Galaxy
end
```

And you want to make sure that also `AndromedaGalaxy` will implement description and not use only the `describe` method from `Galaxy`

## Problem

What kind of error should you raise in `Galaxy#describe`:

* Should it be `NoImplementedError` ?
    
* Or maybe `NoMethodError` ?
    

Looking at their definitions, no one seems to fit:

[![](https://cdn.hashnode.com/res/hashnode/image/upload/v1697952019630/d9e478dd-2036-487f-9000-e1208d7256b5.png)](https://docs.ruby-lang.org/en/master/NotImplementedError.html)

[![](https://cdn.hashnode.com/res/hashnode/image/upload/v1697952049447/9d018812-fa52-437b-8e14-7806143d54a7.png)](https://docs.ruby-lang.org/en/master/NoMethodError.html)

## Discussion

A couple of points to take into consideration when discussing this:

1. There is an ongoing discussion about implementing a new error called `NotImplementedYetError` - [see](https://bugs.ruby-lang.org/issues/18915)
    
2. You will notice that for example, Rails is using `NotImplementedError` - see for [example this](https://github.com/rails/rails/blob/23938052acd773fa24068debe56cd892cbf8d868/activerecord/lib/active_record/inheritance.rb)
    
3. There is even a [patch](https://bugs.ruby-lang.org/attachments/9575) proposed to update the documentation of `NotImplementedError` (not merged at the time of writing this article)
    

The main practical difference when choosing between `NotImplementedError` and `NoMethodError` can be summarised as:

* **Normal** `rescue StandardError` **or simple** `rescue` **(that does rescue StandardError) does NOT catch** `NotImplementedError`:
    

```ruby
begin
  raise NotImplementedError
rescue StandardError => e
  puts "If this catches NotImplementedError, you will see this message!"
end
# => not_implememted_vs_no_method_error.rb:2:in `<main>': NotImplementedError (NotImplementedError)

begin
  raise NotImplementedError
rescue
  puts "If this one catches NotImplementedError, you will see this message!"
end
# => not_implememted_vs_no_method_error.rb:9:in `<main>': NotImplementedError (NotImplementedError)
```

* **Normal** `rescue StandardError` **or simple** `rescue` **(that does rescue StandardError) DOES catch** `NoMethodError`
    

```ruby
begin
  raise NoMethodError
rescue StandardError => e
  puts "This catches NoMethodError"
end
# => This catches NoMethodError

begin
  raise NoMethodError
rescue
  puts "This also catches NoMethodError"
end
# This also catches NoMethodError
```

## Why is one catched and the other one not?

This is because of how they are defined. `NotImplementedError` ancestors are:

```ruby
[
  NotImplementedError,
  ScriptError,
  Exception,
  Object,
  PP::ObjectMixin,
  Kernel,
  BasicObject
]
```

and you can notice here that `StandardError` is not a superclass of NotImplementedError.

While ancestors of `NoMethodError` are:

```ruby
[
  NoMethodError,
  DidYouMean::Correctable,
  ErrorHighlight::CoreExt,
  NameError,
  StandardError,
  Exception,
  Object,
  PP::ObjectMixin,
  Kernel,
  BasicObject
]
```

and you can see here that `StandardError` is a superclass of `NoMethodError`

So choosing one over the other will affect how you can rescue from these errors or how you handle exceptions in your code.

Let's explore some solutions in this case!

## Solution A

Choose composition over inheritance. This means make that method that you want to re-use/re-define an object and inject that into your own model.

See example here:

```ruby
module RoadMovement
  def move
    puts "Moving on the road."
  end
end

module AirMovement
  def move
    puts "Flying in the sky."
  end
end

# Base class
class Vehicle
  def initialize(movement_type)
    @movement_type = movement_type
  end

  def move
    @movement_type.move
  end
end

# Use composition
vehicle = Vehicle.new(RoadMovement)
vehicle.move  # Output: Moving on the road.

airplane = Vehicle.new(AirMovement)
airplane.move  # Output: Flying in the sky.
```

## Solution B

Define your own class

```ruby

class AbstractMethodError < StandardError
  def initialize(method_name:, object_name:)
    super("You have to implement the method `#{method_name}` from object `#{object_name}` in a subclass")
  end
end

class Command
  def build
    raise AbstractMethodError.new(method_name: "build", object_name: self.class.name)
  end
end

class ListFiles < Command
end

begin
  ListFiles.new.build
rescue AbstractMethodError => e
  puts e.message
end

# => You have to implement the method `build` from object `ListFiles` in a subclass
```
