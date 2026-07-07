---
layout: post
title: Order of params for positional arguments
date: '2024-06-04 14:17:26 +0000'
published: false
hashnode_draft_id: 65278f515c7510000f60d80f
---

## Context

Let's assume you have to create or change a method in Ruby that has a list of positional arguments.

For the sake of this discussion let's assume we want to create a method called `log` that will take 3 arguments:

* `message` the message to be logged
    
* `object` the object that will provide more context depending on the level
    
* `level` the level of the log that can be `:info` or `:debug`
    

## Problem

What would be a good order for the arguments?

Which one of the following would be a good choice:

```ruby
# Option A
def log(message, object, level)
end

# Option B
def log(object, message, level)
end

# Option C
def log(level, object, message)
end

# Option D
def log(level, message, object)
end
```

## Discussion

### The order of the arguments is a dependency and adds mental overhead

We should first consider that using positional arguments created a dependency on their order.

That means that someone else who looks at your method call would have to open the method to understand what each argument means, or, in case the method was called with variables, rely on the names of the variables.

```ruby
# Assume we have a method like this

def log(message, object, level)
end

# That means it should always be called like this: 
log("This is a message", MyOwnClass, :info)

# or using variables
log(error_message, user, :info)

# Reversing the order of the parameters
# will either throw an error (depending on the implementation)
# or (worse) log the wrong message about the wrong object
log(:info, "This is a message", MyOwnClass)
```

### The order will be dependent on the context

There is no good heuristic that can be universally valid for all projects.

So it will really depend on the context.

## Solution

### Ideal solution

First, there is an obvious solution here:

* Use keyword arguments so the order of the parameters provided when the method is called would not matter anymore
    

Example:

```ruby
# This 
def log(message:, object:, level:)
end

# can be called in any way like
log(message: "This is a message", object: user, level: :info)
log(object: user, message: "This is a message", level: :info)
log(level: :info, message: "This is a message", object: user)
#...
```

### How to think about the solution

Picking a solution means thinking about what are we improving or optimising for. This is mostly about how will this be used.

I will try to get through some possible scenarios and explain some choices.

#### Using the `log` method mostly inside objects to log things about the current object

I plan to use these inside objects to log messages about the current object.

Then probably the object will most of the time be sent as `self` so it might make sense to put this first.

Why first?

1. Because it is more probable that I will change the content of the message or the level. Thus I want to have the things that change less on the left side and things that change often on the right side. It also makes the diff easier to follow because the change is at the end of the line.
    
2. I also read this as "I send a message to log about current self with level info the message
    

```ruby
def log(object, level, message) 
end

class MyObject
  def a_method
    logger.write(self, :info, "message")
  end
end
```

```diff
class MyObject
  def a_method
-    log(self, :info, "message")
+    log(self, :info, "new message")
  end
end

class MyObject
  def a_method
-    log(self, :info, "new message")
+    log(self, :info, "yet another new message")
  end
end
```

You can of course also choose to put this first:

```ruby
def log(message, object, level) 
end

class MyObject
  def a_method
    log("message", self, :info)
  end
end
```

#### Using the `log` method to write messages about other objects

What changes

### Partial solution: rename the `log` to `write` to make it clear about the message

## Ideas

More ideas about:

* changing the name to write might change the order
    
* explore
