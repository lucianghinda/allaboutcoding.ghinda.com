---
layout: post
title: Why choose Minitest over RSpec
subtitle: How to think about when choosing Minitest over Spec
date: '2023-08-17 03:34:28 +0000'
published: false
hashnode_draft_id: 64dd8fc14e713e000f0fbcb5
---

I prefer Minitest over RSpec. It is probably a subjective choice that I will try to justify further in this article.

## Very little cognitive load

Minitest has a limited set of concepts or keywords that you need to remember. It has no DSL and it is very close to writing Ruby.

If you know Ruby you already know Minitest. This I think is the biggest power of Minitest, that it is just plain Ruby code.

So for example, if you are running a learning program to teach people Ruby or Ruby on Rails please pick Minitest. I saw a lot of times people trying to teach RSpec as the default choice and then the participant needs to both learn Ruby and a new big DSL that is RSpec. That makes the learning process harder and it also lowers the confidence of the participants in their test suite thus invalidating one of the biggest gains when using testing: to trust that if you break something your tests will catch it.

## Performance

Minitest is faster than RSpec. In real-life scenarios, it might not be very fast when compared (see [for example this bechmark](https://speakerdeck.com/palkan/rubyconfby-minsk-2017-run-test-run?slide=30)), but I think any gain counts when you are waiting for your test suite to finish.

## Tests Code Design/Architecture

This is the one that makes a big difference to me.

Because of its simplicity, Minitest invites you to write simple tests. You will also tend to keep them small as they look like Ruby code. And this will help a lot with maintaining the test suite over a long time.

What I saw a couple of times with RSpec, is that it invites people to write lengthy tests, with deep nested `describe` and `context` setups. That it makes it harder to read and parse what is happening there.

You can of course restrict RSpec to only one level of nesting for `describe/context` and also restrict using `let` /`let!` or `subject!` and so on but then it will be so similar with Minitest that maybe you want to consider Minitest instead :)
