---
layout: post
title: "Adding a helper to silence logging in Rails console"
date: '2026-08-28 10:18:52 +0000'
slug: adding-a-helper-to-silence-logging-in-rails-console
tags:
- ruby
- rails
- rails-console
- logging
- irb
- developer-productivity
description: "Rails.application.console runs a block only when bin/rails console starts, never in web or job processes. Define disable_console_loggers! and enable_console_loggers! there once and stop pasting logger levels into every session."
image: "/assets/images/posts/adding-a-helper-to-silence-logging-in-rails-console/og.png"
last_modified_at: '2026-08-28 10:19:52 +0000'
note: >-
  I wrote this article. I used Grammarly to proofread it. 
---

While I was doing some back-and-forth work with Agents and copy/pasting things between the agents CLIs and Rails console, I kept putting the following code there: 

```ruby
ActiveRecord::Base.logger.level = Logger::ERROR; Rails.logger.level = Logger::ERROR
```

I only wanted the output I printed there so I could copy/paste it to agents. 

This works but also has some bug (or, better said, a redundant definition in a standard Rails app). But I pay the price for copy/pasting it in the Rails console while Rails has a hook specifically for this: `Rails.application.console` 

Here is what I ended up implementing: 
- a helper called `disable_console_loggers!` that will remove the noise from this logging
- a helper called `enable_console_loggers!`  as there are times when I want to see the SQL queries executed and the warnings, and I don’t want to restart the Rails console.

## The console hook 

Rails provides a way to register a block that runs only when `bin/rails console` is executed. It does not run in web or job processes, so it should be safe to put it there. 

For this, you can create an initializer, for example `config/initializers/console_helpers.rb` with content like: 


```ruby
Rails.application.console do
  def disable_console_loggers!
    @previous_log_levels ||= console_loggers.to_h { |logger| [logger, logger.level] }
    @previous_log_levels.each_key { |logger| logger.level = :error }
    "Console loggers silenced"
  end

  def enable_console_loggers!
    @previous_log_levels&.each { |logger, level| logger.level = level }
    @previous_log_levels = nil
    "Console loggers restored"
  end

  def console_loggers
    loggers = [Rails.logger]
    loggers << ActiveRecord::Base.logger if defined?(ActiveRecord::Base)
    loggers.compact.uniq
  end
end
```

And then you can execute this in any console session: 

```ruby
irb(main)> disable_console_loggers!
=> "Console loggers silenced"

irb(main)> enable_console_loggers!
=> "Console loggers restored"
```

## Why define a method inside that block?

First, a method defined in a block is actually defined on the `Object` object. 

For example, open `irb` and paste this: 

```ruby
Object.private_instance_methods.include?(:hello)
# => false 

def execute(&block)
  block.call
end

execute do
  def hello
    "Hello!"
  end
end

Object.private_instance_methods.include?(:hello)
# => true 

Object.instance_method(:hello).owner 
# => Object
```

And because inside `rails console` this exists: 

```ruby
rails(dev):001> self
=> main
rails(dev):002> self.class
=> Object
```

That means what you define in that block, which is executed only when the Rails console is started, will define a helper in that Rails console session. 

## Silence Active Record loggers for a single query or a block

If you want to silence Active Record logging for a single query or a code block, you can also use this: 

```ruby
ActiveRecord::Base.logger.silence do
  User.where(created_at: 1.week.ago..).count
end
```

