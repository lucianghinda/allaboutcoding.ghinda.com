---
layout: post
title: '3 New RuboCop Style Cops: SelectByKind, SelectByRange, PartitionInsteadOfDoubleSelect'
date: '2026-03-19 05:49:15 +0000'
slug: 3-new-rubocop-style-cops-selectbykind-selectbyrange-partitioninsteadofdoubleselect
tags:
- ruby
- ruby-on-rails
- rubocop
- quality
description: 'Three new RuboCop style cops in v1.85.0:  SelectByKind, SelectByRange,
  PartitionInsteadOfDoubleSelect: why to enable them and how auto-correct simpli'
image: "/assets/images/posts/3-new-rubocop-style-cops-selectbykind-selectbyrange-partitioninsteadofdoubleselect/25818b55-1ace-4496-bd27-7a82e26a1090.png"
last_modified_at: '2026-03-19 05:50:40 +0000'
---

While upgrading RuboCop in one project, I noticed three new style cops in `v1.85.0`. I took a close look at them and my recommendation is to enable them all.

Let's start.

## The 3 Cops

The cops are:

1.  `Style/SelectByKind` ([PR #14808](https://github.com/rubocop/rubocop/pull/14808))
    
2.  `Style/SelectByRange` ([PR #14810](https://github.com/rubocop/rubocop/pull/14810))
    
3.  `Style/PartitionInsteadOfDoubleSelect` ([PR #14923](https://github.com/rubocop/rubocop/pull/14923))
    

Each is marked as correctable so if you run this you can automatically apply the changes.

## 1) Style/SelectByKind

This one rewrites class/module filtering from `select`/`reject` to `grep`/`grep_v`.

```ruby
# before
array.select { |x| x.is_a?(Foo) }
array.reject { |x| x.is_a?(Foo) }

# after
array.grep(Foo)
array.grep_v(Foo)
```

From the PR discussion, two details mattered to me:

*   The name changed from `SelectByClass` to `SelectByKind`, because modules are valid too, not only classes.
    
*   There is historical context: `Enumerable#grep` has existed in Ruby for decades, and class matching via `===` is old Ruby behavior, not a new trick.
    

I am not saying `select { is_a? }` is bad code. I am arguing `grep(Foo)` signals intent faster once the team gets used to it.

### Why does `grep(Foo)` work at all?

`Enumerable#grep` filters by evaluating `pattern === element` for each element, where the pattern is always on the left. The left-hand operand decides what `===` means: `Class` defines it to call `is_a?`, `Range` defines it to call `cover?`, and `Regexp` defines it to call `match?`.

This is why `grep(Foo)`, `grep(1..10)`, and `grep(/pattern/)` all work the same way. The unifying idea is that `grep` is a pattern filter, and `===` is the protocol each pattern type implements.

> **One thing to watch:** if you are using `find { |x| x.is_a?(Foo) }`, do not rewrite it to `grep(Foo).first`. The `find` version stops at the first match. The `grep` version builds the entire result array first, then takes the first element. The cop intentionally excludes `find`/`detect` for exactly this reason.

## 2) Style/SelectByRange

This one rewrites range checks to `grep(range)` / `grep_v(range)`.

```ruby
# before
array.select { |x| (1..10).cover?(x) }
array.reject { |x| (1..10).cover?(x) }

# after
array.grep(1..10)
array.grep_v(1..10)
```

This PR was explicitly inspired by `SelectByKind`, and follows the same philosophy: if you are pattern-filtering, use Ruby's pattern-filtering API directly.

For me, this is a consistency win more than anything else. If your codebase already uses `grep` for regexp or class matching, range matching with `grep` fits naturally. So if you enable the first cop I shared you should also enable this one.

## 3) Style/PartitionInsteadOfDoubleSelect

This one is a bit more practical.

```ruby
# before
positives = array.select { |x| x > 0 }
negatives = array.reject { |x| x > 0 }

# after
positives, negatives = array.partition { |x| x > 0 }
```

The PR went beyond the obvious case. During review, it added support for:

*   `&:symbol` forms
    
*   mixed forms (`select(&:positive?)` + `reject { |x| x.positive? }`)
    
*   structural negation pairs (`select { expr }` with `select { !expr }`, and same for `reject`)
    

## To keep in mind: `===` Is Not Symmetric

There is one thing I want to make explicit because it is easy to get wrong and the mistake is silent in case you are new to Ruby.

`===` is a regular Ruby method called on the **left-hand object**. So `A === B` calls `A.===(B)`

```ruby
Integer === 42        # calls 42.is_a?(Integer)  → true
(1..10) === 5         # calls (1..10).cover?(5)   → true
/foo/   === "foobar"  # calls /foo/.match?("foobar") → true
```

If you reverse the order, you are calling `===` on a plain object: an integer instance, a string instance, a custom class instance. None of those override `===`. They fall through to `Object#===`, which is just `self == other`.

```ruby
42 === Integer        # 42 == Integer  → false (always)
5  === (1..10)        # 5 == (1..10)   → false (always)
"foobar" === /foo/    # "foobar" == /foo/ → false (always)
```

The part to pay attention is that Ruby will return false and not raise an error because those objects are implementing the `===` comparison. It is not just what you might expect it to be. You just get the wrong answer.

Here is the trap in a realistic scenario:

```ruby
data = [1, "hello", 2, "world", 3]

# correct
data.grep(Integer)                    # => [1, 2, 3]
data.select { |x| Integer === x }     # => [1, 2, 3]

# reversed: looks similar, silently broken
data.select { |x| x === Integer }     # => []
```

The reversed version returns an empty array every time, with no warning, as it is expected cause the object `x` is defining `===`.

You can find out that in these two cases there are two different methods executed:

```ruby
1.method(:===) # => #<Method: Integer#===(_)>
Integer.method(:===) # => #<Method: #<Class:Integer>(Module)#===(_)>
```

The method `Integer#===` is [defined](https://docs.ruby-lang.org/en/master/Integer.html#method-i-3D-3D) as an alias for `==` and says this:

> Returns whether self is numerically equal to other:

But the method from `Module#===` is [defined](https://docs.ruby-lang.org/en/master/Module.html#method-i-3D-3D-3D) as:

> Returns whether other is an instance of self, or is an instance of a subclass of self

There is one edge case where reversal accidentally works by default: when both sides are strings.

```ruby
"hello" === "hello"   # => true   (String#== compares values)
"hello" === "world"   # => false
```

This works because `String#==` compares string content. The moment you switch to a Regexp or a class, the reversal breaks.

```ruby
/hello/ === "hello world"    # => true   (Regexp#match?)
"hello world" === /hello/    # => false  (String#== sees a non-String, returns false)
```

`grep` protects you from this by always calling `pattern === element` with the pattern on the left. That is part of why reaching for `grep` is the right call, not just a style preference.

## Benchmarks I Ran

I wrote [three Ruby scripts](https://gist.github.com/lucianghinda/6016e7bb0fce4425d49182b26712ccb9) to sanity-check behavior and measure runtime:

*   `benchmark_select_by_kind.rb`
    
*   `benchmark_select_by_range.rb`
    
*   `benchmark_partition_instead_of_double_select.rb`
    

Each script first asserts semantic equivalence, then runs repeated benchmarks with [`benchmark-ips`](https://github.com/evanphx/benchmark-ips).

```bash
ruby benchmark_select_by_kind.rb
ruby benchmark_select_by_range.rb
ruby benchmark_partition_instead_of_double_select.rb
```

### Results on my machine

*   `SelectByKind`: `grep(UserRecord)` reached `4.2 i/s` vs `2.6 i/s` for `select { is_a? }` (about `1.62x` throughput).
    
*   `SelectByRange`: `grep(range)` and `grep_v(range)` reached `1.1 i/s` vs `0.9 i/s` for `cover?`\-based filters (about `1.17x` throughput).
    
*   `PartitionInsteadOfDoubleSelect`: `partition` reached `1.0 i/s` vs `0.6 i/s` for `select + reject` (`1.68x` throughput), because it walks once.
    

## Should You Enable Them?

My recommendation:

1.  **Enable** `Style/SelectByKind` - because it encodes idiomatic Ruby and keeps intent explicit.
    
2.  **Enable** `Style/SelectByRange` - because it keeps filtering style consistent across regex, class, and range patterns.
    
3.  **Enable** `Style/PartitionInsteadOfDoubleSelect` - because this one is both cleaner and genuinely more efficient.
    

Since these cops were added in `v1.85.0`, they may still be in *pending* status and not enabled by default. Here is the `.rubocop.yml` snippet to enable them explicitly:

```yaml
Style/SelectByKind:
  Enabled: true

Style/SelectByRange:
  Enabled: true

Style/PartitionInsteadOfDoubleSelect:
  Enabled: true
```

If your team is not used to [`grep`](https://docs.ruby-lang.org/en/master/Enumerable.html#method-i-grep) / [`grep_v`](https://docs.ruby-lang.org/en/master/Enumerable.html#method-i-grep_v), there will be a short learning curve. I still think it is worth it.

I might have missed edge cases in unusual enumerables. The performance gains are small in isolation so I think performance should not be the main metric why you should consider these cops. If you saw different benchmark behavior in your app, I would genuinely like to hear it.

## Resources

*   [PR #14808 - Add new `Style/SelectByKind` cop](https://github.com/rubocop/rubocop/pull/14808)
    
*   [PR #14810 - Add new `Style/SelectByRange` cop](https://github.com/rubocop/rubocop/pull/14810)
    
*   [PR #14923 - Add new `Style/PartitionInsteadOfDoubleSelect` cop](https://github.com/rubocop/rubocop/pull/14923)
    
*   [RuboCop 1.85.0 release notes](https://github.com/rubocop/rubocop/releases/tag/v1.85.0)
    
*   [benchmark-ips](https://github.com/evanphx/benchmark-ips)
    
*   [Ruby docs - `Enumerable#grep`](https://ruby-doc.org/core/Enumerable.html#method-i-grep)
    
*   [Ruby docs - `Enumerable#grep_v`](https://ruby-doc.org/core/Enumerable.html#method-i-grep_v)
    
*   [Ruby docs - `Enumerable#partition`](https://ruby-doc.org/core/Enumerable.html#method-i-partition)
    
*   [Ruby issue #14197 (`select` with pattern argument proposal)](https://bugs.ruby-lang.org/issues/14197)
    
*   [Ruby issue #11049 (`grep_v` addition)](https://bugs.ruby-lang.org/issues/11049)
