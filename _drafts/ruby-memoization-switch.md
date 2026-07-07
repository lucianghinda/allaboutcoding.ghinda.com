---
layout: post
title: Ruby memoization switch
date: '2023-05-27 13:39:06 +0000'
published: false
hashnode_draft_id: 647206cb29412d000fb427aa
---

Memoization in Ruby is used in multiple places and sometimes can cause problems especially if the tests are not designed properly to test for conditions changes and assert if the result will match the new conditions.

Thus I started to experiment with always having a switch to put memoization on and off.

It can be something like this:

```ruby
class User
  def initialize(memoize: ENV.fetch("MEMOIZE", true))
    @memoize = memoize
  end

  def expensive
    return @_expensive if memoize? && defined?(@_expensive)

    @_expensive_call = long_running_task
  end

  private
    attr_reader :memoize

    def memoize? = !!memoize

    def long_running_task
    # ...
    end
end
```

This way I can just add an environment variable `MEMOIZE`
