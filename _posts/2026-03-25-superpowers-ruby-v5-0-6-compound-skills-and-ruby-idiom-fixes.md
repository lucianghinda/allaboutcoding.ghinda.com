---
layout: post
title: 'superpowers-ruby v5.0.6: compound skills and Ruby idiom fixes'
date: '2026-03-25 11:21:36 +0000'
slug: superpowers-ruby-v5-0-6-compound-skills-and-ruby-idiom-fixes
tags:
- ruby
- ruby-on-rails
- llm
- ai
description: superpowers-ruby v5.0.6 adds a Compound Skill adapted from compound-engineering-plugin
  to capture reusable Rails solutions in docs/solutions and prese
image: "/assets/images/posts/superpowers-ruby-v5-0-6-compound-skills-and-ruby-idiom-fixes/f18ee4f5-14fc-4ef4-bfba-067c25f799bd.png"
last_modified_at: '2026-03-25 11:21:36 +0000'
---

Here are some additions I did for [superpowers-ruby](https://github.com/lucianghinda/superpowers-ruby) collection of plugins and skills. A fork from the well known superpowers plugin where I added some skills from [compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) which I think you should install it as it is.

## The compound skill

I found that the compound skill from the folks at Every solves the problem of redisovering the same solution in various forms. The idea is simple: right after you and your agent fix something - while the context is still fresh - you capture what you actually did into a structured learning doc in docs/solutions/.

Next time you hit the same class of problem, the agent learns and uses it.

I think this is one of the most useful skills to add to a Ruby/Rails project. When you are working on a Rails app, you accumulate a lot of tribal knowledge - about how your specific setup works, what N+1 patterns are common in your models, how your Stimulus controllers are wired. The compound skill makes that knowledge persistent and searchable.

I [adapted the skill](https://github.com/lucianghinda/superpowers-ruby/tree/main/skills/superpowers-compound) for superpowers-ruby from the original [compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin). The changes were mostly about conventions, reducing the frontmatter to name and description only, rewriting the description to be trigger-first, and compressing the content from 1901 to 690 words. The core idea is entirely from the Every team and I want to give them full credit for it.

## The companion: compound-refresh

The second skill is [superpowers:compound-refresh](https://github.com/lucianghinda/superpowers-ruby/tree/main/skills/superpowers-compound-refresh). This one runs after refactors, Rails upgrades, or migrations - when the learnings you captured might have drifted from how the code actually works now. Based on the same skill from [compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin).

It has two modes. In interactive mode, it asks you one question at a time and leads with a recommendation. In autonomous mode (mode:autonomous), it processes everything without asking, marks ambiguous cases as stale, and generates a full report at the end.

There are four outcomes for each learning doc: Keep, Update, Replace, or Archive. The hardest distinction to get right is Update vs Replace - if you find yourself rewriting the solution section, that is Replace, not Update.

I also added a Common Mistakes section to this skill because I found during testing that agents would Archive learnings when the referenced files were gone - even when the problem domain was still active. The file being gone does not mean the problem went away.

## Ruby skill improvements

I also revisited the ruby skill itself.

The original description started with "Ruby language conventions, idioms, and modern features (3.x+) for writing idiomatic Ruby code. Covers error handling patterns..." - and I found this was causing a problem.

When agents see a description that summarizes the content, they use it as confirmation they already know the topic. They answer from training memory instead of loading the skill body. For general Ruby questions this is fine, but the skill contains opinionated conventions that agents do not know by default - like the Weirich raise/fail distinction.

Here is what I mean. Ask an agent "should I use raise or fail?" without loading the skill and you get:

▎ "They are aliases in Ruby. Use whichever you prefer."

That is technically true. But the Weirich convention says: use fail when raising a new exception, reserve raise only for re-raising a caught one. It is a semantic signal to readers about intent. Agents only know this if they read the skill.

I rewrote the description to start with "Use when..." and added raise vs fail as a keyword so the skill surfaces for the exact questions it uniquely answers. I also added an Overview section and a Common Mistakes table

*   including rescue Exception which catches SignalException and NoMemoryError and should almost never be used.
    

## Ruby commit message skill

The release also includes a smaller addition: a skill for writing Ruby-style git commit messages (PR #1). It covers tense, length limits, subject/body separation, and conventions for referencing Ruby classes, methods, and modules in commit subjects.

You can find all of this in superpowers-ruby v5.0.6. If you try the compound skills on a Ruby or Rails project and find something that does not work well, I would be glad to hear about it.

## Resources

*   [superpowers-ruby v5.0.6](https://github.com/lucianghinda/superpowers-ruby)
    
*   [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) — the original compound skill this was adapted from
    
*   [Jesse Vincent's superpowers](https://github.com/obra/superpowers) — the base this project is built on
