---
layout: post
title: Why use range literals for Active Record queries
date: '2023-07-11 13:02:44 +0000'
published: false
hashnode_draft_id: 64ad50e7f20d5e000fb823bc
---

As a followup to my previous article let me add two more examples that shows how using range literals with Active Record is better:

```ruby
start_of_interval = 1.hour.from_now
end_of_interval = 2.hours.from_now
```

You can write a query like this:

```ruby
BookedInterval.
  where("start >= ?", start_of_interval).
  where("start < ?", end_of_interval)
```

that will output the following SQL (with PostgreSQL):

```sql
SELECT
  "booked_intervals".*
FROM
  "booked_intervals"
WHERE 
  (START >= '2023-07-11 13:49:46.074922')
  AND
  (START < '2023-07-11 14:21:49.042853')
```

or you can write a query like this:

```ruby
BookedInterval.where(start: start_of_interval...end_of_interval)
```

that will generate the same SQL:

```sql
SELECT
  "booked_intervals".*
FROM
  "booked_intervals"
WHERE
  "booked_intervals"."start" >= '2023-07-11 13:49:46.074922'
  AND 
  "booked_intervals"."start" < '2023-07-11 14:21:49.042853'
```

### What's the difference?

First, using range literals with column name symbols will correctly namespace the column name.

Secondly, and this is more important, using the range literal
