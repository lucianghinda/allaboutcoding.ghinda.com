---
layout: post
title: The endless joy of Ruby
subtitle: Example of how to use the endless method in Ruby
date: '2023-06-22 05:51:50 +0000'
published: false
hashnode_draft_id: 637f7b360d2fc8df7addef19
---

I think that most styling guidelines suggest limiting the usage of the endless method.

I used it as much as possible in the last four months, and of course, there are some cases where it fits and somewhere I think I overdid it and maybe it does not fit that much.

First, I want to say that using a new feature is a matter of getting used to it. In the beginning, a new language construct might seem weird.

## Simple single-statement methods without params

The first use case is for simple single statements, like calling a method without any parameters, which is more like a computed property.

This is the most common case and the most recommended in the current style guides.

Here is a simple example:

```ruby
class User
  def full_name = "#{first_name} #{last_name}"
end
```

But it can also be used to add new simple computed attributes:

```ruby
class Membership
  def unconfirmed = !confirmed?
end

class Booking
  def confirmed? = confirmations.exists?(created_at: ...Time.current)

  def subscribed_via_account? = source == "account"
end
```

but can also be used to replace Rails scopes

```ruby
class Booking
  def start = booked_intervals.order(start_time: :asc).first
end
```

or to delegate execution to another object

```ruby
class Booking
  def notify_guests = Notifications::Booking.confirmed(guests).deliver_later
end
```

## Simple statement with params

This is just a short evolution of the first case, usually with only one param.

```ruby
class Booking
  def confirmed?(day) = booked_intervals.where(day: day).exists?
end
```

```ruby
class Booking
  def valid_token?(token) = Token.where(confirmation_token: token).valid.exists?
end
```

## With two params

I still think it is ok to have endless methods with two params, if they are still simple enough to grasp.

```ruby
class Booking
  def booked_between(start, finish) = booked_intervals.where(day: day).exists?
end
```

I think we can all agree that so far, the code - even if maybe for you look strange -- is it quite simple to read and understand.

## Cases that are a bit harder to parse

### Endless methods checking a condition with `==` or `===`

Here is an example:

```ruby
def subscribed_via_account? = source == "account"
```

I think it might be a bit confusing or hard to parse the `==` and the `=` from the endless method.

A better version of this would be:

```ruby
def subscribed_via_account? = (source == "account")
```

But here it dependes if you are ok with using

---

## An object with all methods endless

Here is where I think using endless methods shine. It allows you to create simple objects. Every method is a line. You can read it in an instant. It mostly feels like a just focusing on proper naming.

## When to use it

I think the main benefit of an endless method is that it helps a lot with naming.

I can see some clear cases where I can use them:

### When naming a long line

There are sometimes cases when it makes the core more readable if you take a single line statement and give it a name:
